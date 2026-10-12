import { Role, UserStatus, type Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const customerRepository = {
  list(where: Prisma.UserWhereInput, skip: number, take: number) {
    return prisma.$transaction([
      prisma.user.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        select: {
          id: true,
          email: true,
          phone: true,
          firstName: true,
          lastName: true,
          displayName: true,
          avatarKey: true,
          status: true,
          locale: true,
          country: true,
          createdAt: true,
          lastLoginAt: true,
          _count: { select: { bookings: true, events: true } },
        },
      }),
      prisma.user.count({ where }),
    ]);
  },
  findById(id: string) {
    return prisma.user.findFirst({
      where: { id, role: Role.CUSTOMER, ...notDeleted },
      include: {
        events: { where: notDeleted, take: 30, orderBy: { eventDate: 'desc' }, include: { category: { select: { id: true, name: true } } } },
        bookings: {
          where: notDeleted,
          take: 40,
          orderBy: { createdAt: 'desc' },
          include: {
            vendor: { select: { id: true, businessName: true } },
            listing: { select: { id: true, title: true, coverKey: true } },
            venue: { select: { id: true, name: true, coverKey: true } },
            car: { select: { id: true, name: true, coverKey: true } },
            accommodation: { select: { id: true, name: true } },
            honeymoon: { select: { id: true, name: true } },
          },
        },
        payments: { where: notDeleted, take: 30, orderBy: { createdAt: 'desc' } },
        venueVisits: { where: notDeleted, take: 20, include: { venue: { select: { id: true, name: true } } } },
        favorites: { where: notDeleted, take: 20 },
      },
    });
  },
  setStatus(id: string, status: UserStatus) {
    return prisma.user.update({ where: { id }, data: { status } });
  },
};
