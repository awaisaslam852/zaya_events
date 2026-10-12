import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const bookingRepository = {
  list(where: Prisma.BookingWhereInput, skip: number, take: number) {
    return prisma.$transaction([
      prisma.booking.findMany({
        where,
        include: { vendor: true, venue: true, listing: true, car: true, accommodation: true, honeymoon: true, customer: { select: { id: true, firstName: true, lastName: true, email: true, phone: true } } },
        orderBy: { createdAt: 'desc' },
        skip,
        take,
      }),
      prisma.booking.count({ where }),
    ]);
  },
  findById(id: string) {
    return prisma.booking.findFirst({
      where: { id, ...notDeleted },
      include: {
        vendor: true,
        venue: true,
        listing: true,
        car: true,
        accommodation: true,
        honeymoon: true,
        customer: { select: { id: true, firstName: true, lastName: true, email: true, phone: true, status: true } },
        statusHistory: { orderBy: { createdAt: 'asc' } },
        payments: true,
        invoices: true,
        commissions: true,
      },
    });
  },
  create(data: Prisma.BookingCreateInput) {
    return prisma.booking.create({ data });
  },
};
