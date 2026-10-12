import { BookingStatus, BookingType, Prisma } from '@prisma/client';
import { NotFoundError } from '../../lib/errors.js';
import { notDeleted, paginated, skipTake } from '../../lib/common.js';
import { prisma } from '../../lib/prisma.js';
import { hotelsProvider, mapsProvider } from '../../integrations/index.js';
import type { HotelOffer } from '../../integrations/hotels/provider.js';
import type { z } from 'zod';
import type { hotelBookSchema, hotelCancelSchema, hotelListQuery } from './hotel.schema.js';

function offerShape(offer: HotelOffer) {
  return {
    id: offer.hotelId,
    name: offer.name,
    description: offer.description,
    city: offer.city,
    country: offer.country,
    address: offer.address,
    latitude: offer.latitude,
    longitude: offer.longitude,
    starRating: offer.starRating,
    amenities: offer.amenities,
    providerRef: offer.hotelId,
  };
}

export const hotelService = {
  async list(query: z.infer<typeof hotelListQuery>) {
    const geo = query.city ? await mapsProvider.geocode(`${query.city}${query.country ? `, ${query.country}` : ''}`) : [];
    const offers = await hotelsProvider.search({
      city: query.city,
      country: query.country,
      q: query.q,
      checkIn: query.checkIn,
      checkOut: query.checkOut,
    });
    const { skip, take } = skipTake(query);
    const items = offers.slice(skip, skip + take).map((offer) => ({
      ...offerShape(offer),
      map: geo[0] ?? null,
    }));
    if (items.length > 0) {
      return paginated(items, offers.length, query);
    }
    const where: Prisma.HotelWhereInput = {
      ...notDeleted,
      ...(query.city ? { city: { contains: query.city, mode: 'insensitive' } } : {}),
      ...(query.country ? { country: { contains: query.country, mode: 'insensitive' } } : {}),
    };
    const [rows, total] = await Promise.all([
      prisma.hotel.findMany({ where, skip, take, orderBy: { createdAt: 'desc' } }),
      prisma.hotel.count({ where }),
    ]);
    return paginated(rows.map((row) => ({ ...row, map: geo[0] ?? null })), total, query);
  },

  async get(id: string) {
    const offer = await hotelsProvider.getHotel(id);
    if (offer) {
      const rooms = await hotelsProvider.roomTypes(id);
      return { ...offerShape(offer), rooms };
    }
    const row = await prisma.hotel.findFirst({
      where: { OR: [{ id }, { providerRef: id }], ...notDeleted },
    });
    if (!row) {
      throw new NotFoundError('Hotel not found');
    }
    return row;
  },

  async rooms(id: string, query: { checkIn?: string; checkOut?: string }) {
    await this.get(id);
    return hotelsProvider.roomTypes(id, query);
  },

  async book(userId: string, hotelId: string, input: z.infer<typeof hotelBookSchema>) {
    const offer = await hotelsProvider.getHotel(hotelId);
    const rooms = await hotelsProvider.roomTypes(hotelId);
    const roomId = input.roomId ?? rooms[0]?.roomId;
    if (!roomId) {
      throw new NotFoundError('No room types available');
    }
    const ticket = await hotelsProvider.book({
      hotelId,
      roomId,
      checkIn: input.checkIn.toISOString(),
      checkOut: input.checkOut.toISOString(),
      rooms: input.rooms,
      guests: input.guests,
    });
    let hotel = await prisma.hotel.findFirst({
      where: { OR: [{ id: hotelId }, { providerRef: hotelId }], ...notDeleted },
    });
    if (!hotel && offer) {
      hotel = await prisma.hotel.create({
        data: {
          name: offer.name as Prisma.InputJsonValue,
          description: offer.description as Prisma.InputJsonValue,
          city: offer.city,
          country: offer.country,
          address: offer.address as Prisma.InputJsonValue,
          latitude: offer.latitude,
          longitude: offer.longitude,
          starRating: offer.starRating,
          amenities: offer.amenities as Prisma.InputJsonValue,
          providerRef: offer.hotelId,
        },
      });
    }
    if (!hotel) {
      throw new NotFoundError('Hotel not found');
    }
    const booking = await prisma.booking.create({
      data: {
        bookingNumber: `HT-${Date.now()}`,
        type: BookingType.HOTEL,
        status: BookingStatus.PENDING,
        customerId: userId,
        eventId: input.eventId,
        startAt: input.checkIn,
        endAt: input.checkOut,
        guestCount: input.guests,
        currency: ticket.currency,
        subtotalAmount: ticket.totalAmount,
        totalAmount: ticket.totalAmount,
      },
    });
    await prisma.hotelBooking.create({
      data: {
        userId,
        hotelId: hotel.id,
        bookingId: booking.id,
        checkIn: input.checkIn,
        checkOut: input.checkOut,
        rooms: input.rooms,
        guests: input.guests,
        roomType: { roomId } as Prisma.InputJsonValue,
        confirmation: ticket.confirmation,
        totalAmount: ticket.totalAmount,
        currency: ticket.currency,
      },
    });
    return { ...booking, confirmation: ticket.confirmation };
  },

  async cancel(userId: string, bookingId: string, _input: z.infer<typeof hotelCancelSchema>) {
    const row = await prisma.hotelBooking.findFirst({
      where: { bookingId, userId, deletedAt: null },
    });
    if (!row?.confirmation) {
      throw new NotFoundError('Hotel booking not found');
    }
    const cancelled = await hotelsProvider.cancel(row.confirmation);
    await prisma.hotelBooking.update({
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
