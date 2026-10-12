import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const listingRepository = {
  list(where: Prisma.ListingWhereInput, skip: number, take: number) {
    return prisma.$transaction([
      prisma.listing.findMany({
        where,
        include: { category: true, vendor: true, packages: { where: notDeleted } },
        orderBy: { createdAt: 'desc' },
        skip,
        take,
      }),
      prisma.listing.count({ where }),
    ]);
  },
  findById(id: string) {
    return prisma.listing.findFirst({
      where: { id, ...notDeleted },
      include: { category: true, vendor: true, packages: { where: notDeleted } },
    });
  },
  create(data: Prisma.ListingCreateInput) {
    return prisma.listing.create({
      data,
      include: { category: true, packages: true },
    });
  },
  update(id: string, data: Prisma.ListingUpdateInput) {
    return prisma.listing.update({
      where: { id },
      data,
      include: { category: true, packages: { where: notDeleted } },
    });
  },
};
