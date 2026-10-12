import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const eventRepository = {
  list(where: Prisma.EventWhereInput, skip: number, take: number) {
    return prisma.$transaction([
      prisma.event.findMany({
        where,
        include: { category: true },
        orderBy: { eventDate: 'asc' },
        skip,
        take,
      }),
      prisma.event.count({ where }),
    ]);
  },
  findById(id: string) {
    return prisma.event.findFirst({
      where: { id, ...notDeleted },
      include: {
        category: true,
        bookings: {
          where: notDeleted,
          include: {
            vendor: true,
            venue: true,
            listing: true,
            car: true,
            accommodation: true,
            honeymoon: true,
            payments: true,
            flightBooking: { include: { flight: true } },
            hotelBooking: { include: { hotel: true } },
          },
          orderBy: { createdAt: 'desc' },
        },
        visits: {
          where: notDeleted,
          include: { venue: true, representative: true },
          orderBy: { scheduledAt: 'asc' },
        },
      },
    });
  },
  create(data: Prisma.EventCreateInput) {
    return prisma.event.create({ data, include: { category: true } });
  },
  update(id: string, data: Prisma.EventUpdateInput) {
    return prisma.event.update({ where: { id }, data, include: { category: true } });
  },
};
