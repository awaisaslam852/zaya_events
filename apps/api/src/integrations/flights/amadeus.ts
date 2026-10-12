import { integrationsConfig } from '../config.js';
import { logger } from '../../lib/logger.js';
import { MockFlightsProvider } from './mock.js';
import type { FlightBookingResult, FlightOffer, FlightPassenger, FlightSearchQuery, FlightsProvider } from './provider.js';

type Token = { access: string; exp: number };

export class AmadeusFlightsProvider implements FlightsProvider {
  private token: Token | null = null;
  private readonly fallback = new MockFlightsProvider();
  private readonly cache = new Map<string, { offer: FlightOffer; raw: unknown }>();

  private ready(): boolean {
    return Boolean(integrationsConfig.AMADEUS_CLIENT_ID && integrationsConfig.AMADEUS_CLIENT_SECRET);
  }

  private host(): string {
    return integrationsConfig.AMADEUS_HOSTNAME === 'production'
      ? 'https://api.amadeus.com'
      : 'https://test.api.amadeus.com';
  }

  private async auth(): Promise<string> {
    if (this.token && this.token.exp > Date.now() + 30_000) {
      return this.token.access;
    }
    const body = new URLSearchParams({
      grant_type: 'client_credentials',
      client_id: integrationsConfig.AMADEUS_CLIENT_ID,
      client_secret: integrationsConfig.AMADEUS_CLIENT_SECRET,
    });
    const response = await fetch(`${this.host()}/v1/security/oauth2/token`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body,
    });
    if (!response.ok) {
      throw new Error(`Amadeus auth failed (${response.status})`);
    }
    const json = (await response.json()) as { access_token: string; expires_in: number };
    this.token = { access: json.access_token, exp: Date.now() + json.expires_in * 1000 };
    return this.token.access;
  }

  private mapOffer(raw: Record<string, unknown>): FlightOffer | null {
    const itineraries = raw.itineraries as Array<{ segments?: Array<Record<string, unknown>> }> | undefined;
    const segment = itineraries?.[0]?.segments?.[0];
    if (!segment) {
      return null;
    }
    const departure = segment.departure as { iataCode?: string; at?: string } | undefined;
    const arrival = segment.arrival as { iataCode?: string; at?: string } | undefined;
    const price = raw.price as { grandTotal?: string; currency?: string } | undefined;
    const offerId = String(raw.id ?? '');
    const cabinRaw = ((segment.cabin ?? 'ECONOMY') as string).toUpperCase().replace('-', '_');
    const cabin =
      cabinRaw === 'PREMIUM_ECONOMY' || cabinRaw === 'BUSINESS' || cabinRaw === 'FIRST' ? cabinRaw : 'ECONOMY';
    return {
      offerId,
      carrierCode: String(segment.carrierCode ?? segment.operating ?? 'XX'),
      flightNumber: `${segment.carrierCode ?? ''}${segment.number ?? ''}`.replace(/\s/g, '') || offerId,
      origin: String(departure?.iataCode ?? ''),
      destination: String(arrival?.iataCode ?? ''),
      departureAt: departure?.at ?? new Date().toISOString(),
      arrivalAt: arrival?.at ?? new Date().toISOString(),
      cabin,
      seatsLeft: Number((raw.numberOfBookableSeats as number | undefined) ?? 9),
      priceAmount: Number(price?.grandTotal ?? 0),
      currency: String(price?.currency ?? 'AED'),
      provider: 'amadeus',
    };
  }

  async search(query: FlightSearchQuery): Promise<FlightOffer[]> {
    if (!this.ready()) {
      return this.fallback.search(query);
    }
    try {
      const token = await this.auth();
      const params = new URLSearchParams({
        originLocationCode: query.origin.toUpperCase(),
        destinationLocationCode: query.destination.toUpperCase(),
        departureDate: query.departureDate,
        adults: String(query.adults ?? 1),
        currencyCode: 'AED',
        max: '20',
      });
      if (query.returnDate) {
        params.set('returnDate', query.returnDate);
      }
      if (query.cabin) {
        params.set('travelClass', query.cabin);
      }
      const response = await fetch(`${this.host()}/v2/shopping/flight-offers?${params.toString()}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!response.ok) {
        throw new Error(`Amadeus search failed (${response.status})`);
      }
      const json = (await response.json()) as { data?: Array<Record<string, unknown>> };
      const offers: FlightOffer[] = [];
      for (const raw of json.data ?? []) {
        const offer = this.mapOffer(raw);
        if (offer) {
          this.cache.set(offer.offerId, { offer, raw });
          offers.push(offer);
        }
      }
      return offers.length > 0 ? offers : this.fallback.search(query);
    } catch (error) {
      logger.warn({ err: error }, 'Amadeus search failed; using catalog fallback');
      return this.fallback.search(query);
    }
  }

  async getOffer(offerId: string): Promise<FlightOffer | null> {
    const cached = this.cache.get(offerId);
    if (cached) {
      return cached.offer;
    }
    return this.fallback.getOffer(offerId);
  }

  async book(offerId: string, passengers: FlightPassenger[]): Promise<FlightBookingResult> {
    if (!this.ready()) {
      return this.fallback.book(offerId, passengers);
    }
    const cached = this.cache.get(offerId);
    if (!cached) {
      return this.fallback.book(offerId, passengers);
    }
    try {
      const token = await this.auth();
      const travelers = passengers.map((passenger, index) => ({
        id: String(index + 1),
        dateOfBirth: passenger.dateOfBirth ?? '1990-01-01',
        name: { firstName: passenger.firstName, lastName: passenger.lastName },
        gender: 'UNSPECIFIED',
      }));
      const response = await fetch(`${this.host()}/v1/booking/flight-orders`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          data: {
            type: 'flight-order',
            flightOffers: [cached.raw],
            travelers,
          },
        }),
      });
      if (!response.ok) {
        throw new Error(`Amadeus book failed (${response.status})`);
      }
      const json = (await response.json()) as { data?: { id?: string; associatedRecords?: Array<{ reference?: string }> } };
      const pnr = json.data?.associatedRecords?.[0]?.reference ?? json.data?.id ?? `AMA-${offerId}`;
      return {
        pnr,
        offerId,
        status: 'TICKETED',
        totalAmount: cached.offer.priceAmount,
        currency: cached.offer.currency,
        raw: json.data,
      };
    } catch (error) {
      logger.warn({ err: error }, 'Amadeus book failed; using catalog booking');
      return this.fallback.book(offerId, passengers);
    }
  }

  async cancel(pnr: string): Promise<{ pnr: string; status: 'CANCELLED' }> {
    if (this.ready() && !pnr.startsWith('PNR-') && !pnr.startsWith('mock')) {
      try {
        const token = await this.auth();
        await fetch(`${this.host()}/v1/booking/flight-orders/${encodeURIComponent(pnr)}`, {
          method: 'DELETE',
          headers: { Authorization: `Bearer ${token}` },
        });
      } catch (error) {
        logger.warn({ err: error, pnr }, 'Amadeus cancel failed');
      }
    }
    return this.fallback.cancel(pnr);
  }
}
