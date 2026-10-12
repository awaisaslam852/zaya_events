import { BookingStatus, BookingType, Prisma } from '@prisma/client';
import { NotFoundError } from '../../lib/errors.js';
import { notDeleted, paginated, skipTake } from '../../lib/common.js';
import { prisma } from '../../lib/prisma.js';
import { flightsProvider } from '../../integrations/index.js';
import type { FlightOffer } from '../../integrations/flights/provider.js';
import type { z } from 'zod';
import type { flightBookSchema, flightCancelSchema, flightListQuery } from './flight.schema.js';

function offerToFlightShape(offer: FlightOffer) {
  return {
    id: offer.offerId,
    carrierCode: offer.carrierCode,
    flightNumber: offer.flightNumber,
    origin: offer.origin,
    destination: offer.destination,
    departureAt: offer.departureAt,
    arrivalAt: offer.arrivalAt,
    cabin: { class: offer.cabin },
    priceAmount: offer.priceAmount,
    currency: offer.currency,
    seatsLeft: offer.seatsLeft,
    providerRef: offer.offerId,
  };
}

function isOffer(value: unknown): value is FlightOffer {
  return Boolean(value && typeof value === 'object' && 'offerId' in value);
}

export const flightService = {
  async list(query: z.infer<typeof flightListQuery>) {
    if (query.origin && query.destination && query.date) {
      const offers = await flightsProvider.search({
        origin: query.origin,
        destination: query.destination,
        departureDate: query.date,
        adults: 1,
      });
      const { skip, take } = skipTake(query);
      return paginated(offers.slice(skip, skip + take).map(offerToFlightShape), offers.length, query);
    }
    const { skip, take } = skipTake(query);
    const where = { ...notDeleted };
    const [items, total] = await Promise.all([
      prisma.flight.findMany({ where, skip, take, orderBy: { departureAt: 'asc' } }),
      prisma.flight.count({ where }),
    ]);
    return paginated(items, total, query);
  },

  async get(id: string) {
    const offer = await flightsProvider.getOffer(id);
    if (offer) {
      return offerToFlightShape(offer);
    }
    const row = await prisma.flight.findFirst({
      where: { OR: [{ id }, { providerRef: id }], ...notDeleted },
    });
    if (!row) {
      throw new NotFoundError('Flight not found');
    }
    return row;
  },

  async book(userId: string, flightId: string, input: z.infer<typeof flightBookSchema>) {
    const offer = await flightsProvider.getOffer(flightId);
    const persisted = offer
      ? null
      : await prisma.flight.findFirst({ where: { OR: [{ id: flightId }, { providerRef: flightId }], ...notDeleted } });
    if (!offer && !persisted) {
      throw new NotFoundError('Flight not found');
    }
    const passengers = Array.from({ length: input.passengers }, (_, index) => ({
      firstName: 'Guest',
      lastName: `${index + 1}`,
    }));
    const bookId = offer?.offerId ?? persisted?.providerRef ?? flightId;
    let ticket;
    try {
      ticket = await flightsProvider.book(bookId, passengers);
    } catch (error) {
      if (!persisted) {
        throw error;
      }
      ticket = {
        pnr: `LOC${Date.now()}`,
        offerId: bookId,
        status: 'PENDING' as const,
        totalAmount: Number(persisted.priceAmount),
        currency: persisted.currency,
      };
    }
    const source = offer ?? persisted;
    const departureAt = new Date(isOffer(source) ? source.departureAt : String(source?.departureAt));
    const arrivalAt = new Date(isOffer(source) ? source.arrivalAt : String(source?.arrivalAt));
    let flightRow = persisted;
    if (!flightRow) {
      flightRow = await prisma.flight.create({
        data: {
          carrierCode: isOffer(source) ? source.carrierCode : 'ZZ',
          flightNumber: isOffer(source) ? source.flightNumber : '0000',
          origin: isOffer(source) ? source.origin : 'XXX',
          destination: isOffer(source) ? source.destination : 'YYY',
          departureAt,
          arrivalAt,
          cabin: { class: isOffer(source) ? source.cabin : 'ECONOMY' } as Prisma.InputJsonValue,
          priceAmount: ticket.totalAmount,
          currency: ticket.currency,
          seatsLeft: isOffer(source) ? source.seatsLeft : 0,
          providerRef: flightId,
        },
      });
    }
    const booking = await prisma.booking.create({
      data: {
        bookingNumber: `FL-${Date.now()}`,
        type: BookingType.FLIGHT,
        status: BookingStatus.PENDING,
        customerId: userId,
        eventId: input.eventId,
        startAt: flightRow.departureAt,
        endAt: flightRow.arrivalAt,
        guestCount: input.passengers,
        currency: flightRow.currency,
        subtotalAmount: ticket.totalAmount,
        totalAmount: ticket.totalAmount,
      },
    });
    await prisma.flightBooking.create({
      data: {
        userId,
        flightId: flightRow.id,
        bookingId: booking.id,
        passengerJson: { count: input.passengers, pnr: ticket.pnr },
        pnr: ticket.pnr,
        totalAmount: ticket.totalAmount,
        currency: ticket.currency,
        status: BookingStatus.PENDING,
      },
    });
    return { ...booking, pnr: ticket.pnr };
  },

  async cancel(userId: string, bookingId: string, _input: z.infer<typeof flightCancelSchema>) {
    const row = await prisma.flightBooking.findFirst({
      where: { bookingId, userId, deletedAt: null },
    });
    if (!row?.pnr) {
      throw new NotFoundError('Flight booking not found');
    }
    const cancelled = await flightsProvider.cancel(row.pnr);
    await prisma.flightBooking.update({
      where: { id: row.id },
      data: { status: BookingStatus.CANCELLED },
    });
    await prisma.booking.update({
      where: { id: bookingId },
      data: { status: BookingStatus.CANCELLED },
    });
    return cancelled;
  },
};
