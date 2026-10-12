import { integrationsConfig } from '../config.js';
import { logger } from '../../lib/logger.js';
import { MockHotelsProvider } from './mock.js';
import type { HotelBookingResult, HotelOffer, HotelRoomType, HotelSearchQuery, HotelsProvider } from './provider.js';

export class BookingComHotelsProvider implements HotelsProvider {
  private readonly fallback = new MockHotelsProvider();
  private readonly cache = new Map<string, HotelOffer>();

  private ready(): boolean {
    return Boolean(integrationsConfig.BOOKINGCOM_API_KEY);
  }

  private headers(): Record<string, string> {
    return {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${integrationsConfig.BOOKINGCOM_API_KEY}`,
      ...(integrationsConfig.BOOKINGCOM_AFFILIATE_ID
        ? { 'X-Affiliate-Id': integrationsConfig.BOOKINGCOM_AFFILIATE_ID }
        : {}),
    };
  }

  private mapHotel(raw: Record<string, unknown>): HotelOffer {
    const hotelId = String(raw.id ?? raw.hotel_id ?? raw.accommodation_id ?? '');
    const name = String(raw.name ?? raw.hotel_name ?? 'Hotel');
    const city = String((raw.city as { name?: string } | undefined)?.name ?? raw.city ?? '');
    const country = String((raw.country as { code?: string } | undefined)?.code ?? raw.country ?? 'AE');
    const location = raw.location as { latitude?: number; longitude?: number } | undefined;
    const offer: HotelOffer = {
      hotelId,
      name: { en: name, ar: name },
      description: {
        en: String(raw.description ?? 'Partner hotel'),
        ar: String(raw.description ?? 'فندق شريك'),
      },
      city,
      country,
      address: { en: String(raw.address ?? city), ar: String(raw.address ?? city) },
      latitude: Number(location?.latitude ?? raw.latitude ?? 0) || undefined,
      longitude: Number(location?.longitude ?? raw.longitude ?? 0) || undefined,
      starRating: Number(raw.stars ?? raw.star_rating ?? 4),
      amenities: Array.isArray(raw.amenities) ? (raw.amenities as string[]) : ['wifi'],
      provider: 'bookingcom',
    };
    this.cache.set(hotelId, offer);
    return offer;
  }

  async search(query: HotelSearchQuery): Promise<HotelOffer[]> {
    if (!this.ready()) {
      return this.fallback.search(query);
    }
    try {
      const checkIn = query.checkIn ?? new Date(Date.now() + 7 * 86400000).toISOString().slice(0, 10);
      const checkOut = query.checkOut ?? new Date(Date.now() + 9 * 86400000).toISOString().slice(0, 10);
      const response = await fetch('https://demandapi.booking.com/3.1/accommodations/search', {
        method: 'POST',
        headers: this.headers(),
        body: JSON.stringify({
          booker: { country: (query.country ?? 'ae').toLowerCase(), platform: 'mobile' },
          checkin: checkIn,
          checkout: checkOut,
          city: query.city,
          guests: { number_of_rooms: query.rooms ?? 1, number_of_adults: query.guests ?? 2 },
        }),
      });
      if (!response.ok) {
        throw new Error(`Booking.com search failed (${response.status})`);
      }
      const json = (await response.json()) as { data?: Array<Record<string, unknown>>; accommodations?: Array<Record<string, unknown>> };
      const rows = json.data ?? json.accommodations ?? [];
      const offers = rows.map((row) => this.mapHotel(row)).filter((row) => row.hotelId);
      return offers.length > 0 ? offers : this.fallback.search(query);
    } catch (error) {
      logger.warn({ err: error }, 'Booking.com search failed; using catalog fallback');
      return this.fallback.search(query);
    }
  }

  async getHotel(hotelId: string): Promise<HotelOffer | null> {
    if (this.cache.has(hotelId)) {
      return this.cache.get(hotelId) ?? null;
    }
    if (!this.ready()) {
      return this.fallback.getHotel(hotelId);
    }
    try {
      const response = await fetch('https://demandapi.booking.com/3.1/accommodations/details', {
        method: 'POST',
        headers: this.headers(),
        body: JSON.stringify({ accommodations: [hotelId] }),
      });
      if (!response.ok) {
        throw new Error(`Booking.com details failed (${response.status})`);
      }
      const json = (await response.json()) as { data?: Array<Record<string, unknown>> };
      const raw = json.data?.[0];
      return raw ? this.mapHotel(raw) : this.fallback.getHotel(hotelId);
    } catch (error) {
      logger.warn({ err: error }, 'Booking.com details failed');
      return this.fallback.getHotel(hotelId);
    }
  }

  async roomTypes(
    hotelId: string,
    query?: Pick<HotelSearchQuery, 'checkIn' | 'checkOut' | 'rooms' | 'guests'>,
  ): Promise<HotelRoomType[]> {
    if (!this.ready()) {
      return this.fallback.roomTypes(hotelId, query);
    }
    try {
      const response = await fetch('https://demandapi.booking.com/3.1/accommodations/availability', {
        method: 'POST',
        headers: this.headers(),
        body: JSON.stringify({
          accommodations: [hotelId],
          checkin: query?.checkIn,
          checkout: query?.checkOut,
          guests: { number_of_rooms: query?.rooms ?? 1, number_of_adults: query?.guests ?? 2 },
        }),
      });
      if (!response.ok) {
        throw new Error(`Booking.com availability failed (${response.status})`);
      }
      const json = (await response.json()) as { data?: Array<{ products?: Array<Record<string, unknown>> }> };
      const products = json.data?.[0]?.products ?? [];
      if (products.length === 0) {
        return this.fallback.roomTypes(hotelId, query);
      }
      return products.map((product, index) => ({
        roomId: String(product.id ?? `room-${index}`),
        name: { en: String(product.name ?? 'Room'), ar: String(product.name ?? 'غرفة') },
        occupancy: Number(product.occupancy ?? 2),
        priceAmount: Number((product.price as { total?: number } | undefined)?.total ?? product.price ?? 0),
        currency: String((product.price as { currency?: string } | undefined)?.currency ?? 'AED'),
        refundable: Boolean(product.refundable ?? true),
      }));
    } catch (error) {
      logger.warn({ err: error }, 'Booking.com rooms failed');
      return this.fallback.roomTypes(hotelId, query);
    }
  }

  async book(input: {
    hotelId: string;
    roomId: string;
    checkIn: string;
    checkOut: string;
    rooms: number;
    guests: number;
  }): Promise<HotelBookingResult> {
    if (!this.ready()) {
      return this.fallback.book(input);
    }
    try {
      const response = await fetch('https://demandapi.booking.com/3.1/orders/create', {
        method: 'POST',
        headers: this.headers(),
        body: JSON.stringify(input),
      });
      if (!response.ok) {
        throw new Error(`Booking.com order failed (${response.status})`);
      }
      const json = (await response.json()) as { data?: { id?: string; total?: number; currency?: string } };
      return {
        confirmation: json.data?.id ?? `BCOM-${Date.now()}`,
        hotelId: input.hotelId,
        roomId: input.roomId,
        status: 'CONFIRMED',
        totalAmount: Number(json.data?.total ?? 0),
        currency: json.data?.currency ?? 'AED',
        raw: json.data,
      };
    } catch (error) {
      logger.warn({ err: error }, 'Booking.com book failed; using catalog booking');
      return this.fallback.book(input);
    }
  }

  async cancel(confirmation: string): Promise<{ confirmation: string; status: 'CANCELLED' }> {
    if (this.ready() && !confirmation.startsWith('mock') && !confirmation.startsWith('HTL-')) {
      try {
        await fetch('https://demandapi.booking.com/3.1/orders/cancel', {
          method: 'POST',
          headers: this.headers(),
          body: JSON.stringify({ order: confirmation }),
        });
      } catch (error) {
        logger.warn({ err: error, confirmation }, 'Booking.com cancel failed');
      }
    }
    return this.fallback.cancel(confirmation);
  }
}
