import { randomInt, randomUUID } from 'node:crypto';
import { AppError } from '../../lib/errors.js';
import type {
  FlightBookingResult,
  FlightOffer,
  FlightPassenger,
  FlightSearchQuery,
  FlightsProvider,
} from './provider.js';

const BASE: FlightOffer[] = [
  {
    offerId: 'mock-flt-dxb-lhr-1',
    carrierCode: 'EK',
    flightNumber: 'EK001',
    origin: 'DXB',
    destination: 'LHR',
    departureAt: '2026-11-12T08:15:00.000Z',
    arrivalAt: '2026-11-12T12:45:00.000Z',
    cabin: 'ECONOMY',
    seatsLeft: 9,
    priceAmount: 2450,
    currency: 'AED',
    provider: 'mock',
  },
  {
    offerId: 'mock-flt-dxb-cdg-1',
    carrierCode: 'AF',
    flightNumber: 'AF655',
    origin: 'DXB',
    destination: 'CDG',
    departureAt: '2026-11-12T01:40:00.000Z',
    arrivalAt: '2026-11-12T06:55:00.000Z',
    cabin: 'BUSINESS',
    seatsLeft: 4,
    priceAmount: 6120,
    currency: 'AED',
    provider: 'mock',
  },
  {
    offerId: 'mock-flt-auh-ist-1',
    carrierCode: 'EY',
    flightNumber: 'EY191',
    origin: 'AUH',
    destination: 'IST',
    departureAt: '2026-12-02T14:20:00.000Z',
    arrivalAt: '2026-12-02T18:05:00.000Z',
    cabin: 'ECONOMY',
    seatsLeft: 16,
    priceAmount: 980,
    currency: 'AED',
    provider: 'mock',
  },
];

const bookings = new Map<string, FlightBookingResult>();

export class MockFlightsProvider implements FlightsProvider {
  async search(query: FlightSearchQuery): Promise<FlightOffer[]> {
    const origin = query.origin.toUpperCase();
    const destination = query.destination.toUpperCase();
    const date = query.departureDate;
    return BASE.filter((offer) => offer.origin === origin && offer.destination === destination).map((offer) => ({
      ...offer,
      offerId: `${offer.offerId}-${date}`,
      departureAt: `${date}T${offer.departureAt.slice(11)}`,
      arrivalAt: `${date}T${offer.arrivalAt.slice(11)}`,
      cabin: query.cabin ?? offer.cabin,
    }));
  }

  async getOffer(offerId: string): Promise<FlightOffer | null> {
    const base = BASE.find((offer) => offerId.startsWith(offer.offerId));
    if (!base) {
      return null;
    }
    return { ...base, offerId };
  }

  async book(offerId: string, passengers: FlightPassenger[]): Promise<FlightBookingResult> {
    const offer = await this.getOffer(offerId);
    if (!offer) {
      throw new AppError(404, 'FLIGHT_OFFER_NOT_FOUND', 'Flight offer is no longer available');
    }
    if (passengers.length < 1) {
      throw new AppError(422, 'PASSENGERS_REQUIRED', 'At least one passenger is required');
    }
    const pnr = `ZAYA${randomInt(100000, 999999)}`;
    const result: FlightBookingResult = {
      pnr,
      offerId,
      status: 'TICKETED',
      totalAmount: offer.priceAmount * passengers.length,
      currency: offer.currency,
      raw: { mock: true, passengers },
    };
    bookings.set(pnr, result);
    return result;
  }

  async cancel(pnr: string): Promise<{ pnr: string; status: 'CANCELLED' }> {
    const existing = bookings.get(pnr);
    if (!existing) {
      bookings.set(pnr, {
        pnr,
        offerId: randomUUID(),
        status: 'CANCELLED',
        totalAmount: 0,
        currency: 'AED',
      });
    } else {
      bookings.set(pnr, { ...existing, status: 'CANCELLED' });
    }
    return { pnr, status: 'CANCELLED' };
  }
}
