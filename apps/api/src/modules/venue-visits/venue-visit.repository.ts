import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const venueVisitRepository = {
  list(where: Prisma.VenueVisitWhereInput, skip: number, take: number) {
    return prisma.$transaction([
      prisma.venueVisit.findMany({
        where,
        include: { venue: true, representative: true, customer: true },
        orderBy: { scheduledAt: 'asc' },
        skip,
        take,
      }),
      prisma.venueVisit.count({ where }),
    ]);
  },
  findById(id: string) {
    return prisma.venueVisit.findFirst({
      where: { id, ...notDeleted },
      include: { venue: true, representative: true, customer: true },
    });
  },
  create(data: Prisma.VenueVisitCreateInput) {
    return prisma.venueVisit.create({ data, include: { venue: true } });
  },
  update(id: string, data: Prisma.VenueVisitUpdateInput) {
    return prisma.venueVisit.update({
      where: { id },
      data,
      include: { venue: true, representative: true },
    });
  },
};
