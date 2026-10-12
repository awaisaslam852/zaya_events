import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const accommodationRepository = {
  list(where: Prisma.AccommodationWhereInput, skip: number, take: number) {
    return prisma.$transaction([
      prisma.accommodation.findMany({ where, include: { vendor: true }, orderBy: { createdAt: 'desc' }, skip, take }),
      prisma.accommodation.count({ where }),
    ]);
  },
  findById(id: string) {
    return prisma.accommodation.findFirst({
      where: { id, ...notDeleted },
      include: { vendor: true, availability: { where: notDeleted } },
    });
  },
  create(data: Prisma.AccommodationCreateInput) {
    return prisma.accommodation.create({ data });
  },
  update(id: string, data: Prisma.AccommodationUpdateInput) {
    return prisma.accommodation.update({ where: { id }, data });
  },
};
