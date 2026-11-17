import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const venueRepository = {
  list(where: Prisma.VenueWhereInput, skip: number, take: number) {
    return prisma.$transaction([
      prisma.venue.findMany({
        where,
        include: { packages: { where: notDeleted }, vendor: true },
        orderBy: { createdAt: 'desc' },
        skip,
        take,
      }),
      prisma.venue.count({ where }),
    ]);
  },
  findById(id: string) {
    return prisma.venue.findFirst({
      where: { id, ...notDeleted },
      include: { packages: { where: notDeleted }, vendor: true, availability: { where: notDeleted } },
    });
  },
  create(data: Prisma.VenueCreateInput) {
    return prisma.venue.create({ data, include: { packages: true } });
  },
  update(id: string, data: Prisma.VenueUpdateInput) {
    return prisma.venue.update({ where: { id }, data, include: { packages: { where: notDeleted } } });
  },
  addPackage(venueId: string, data: Prisma.VenuePackageCreateWithoutVenueInput) {
    return prisma.venuePackage.create({ data: { ...data, venue: { connect: { id: venueId } } } });
  },
  findPackage(id: string) {
    return prisma.venuePackage.findFirst({ where: { id, ...notDeleted } });
  },
  updatePackage(id: string, data: Prisma.VenuePackageUpdateInput) {
    return prisma.venuePackage.update({ where: { id }, data });
  },
  removePackage(id: string) {
    return prisma.venuePackage.update({ where: { id }, data: { deletedAt: new Date(), isActive: false } });
  },
};
