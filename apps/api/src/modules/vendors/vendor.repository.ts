import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const vendorRepository = {
  list(where: Prisma.VendorWhereInput, skip: number, take: number) {
    return prisma.$transaction([
      prisma.vendor.findMany({
        where,
        include: {
          user: { select: { id: true, email: true, firstName: true, lastName: true, phone: true, status: true } },
          _count: { select: { listings: true, bookings: true, cars: true, venues: true, accommodations: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take,
      }),
      prisma.vendor.count({ where }),
    ]);
  },
  findById(id: string) {
    return prisma.vendor.findFirst({
      where: { id, ...notDeleted },
      include: {
        user: { select: { id: true, email: true, firstName: true, lastName: true, phone: true, status: true } },
        listings: { where: notDeleted, take: 40, include: { category: { select: { id: true, name: true } } } },
        cars: { where: notDeleted, take: 20 },
        venues: { where: notDeleted, take: 20 },
        accommodations: { where: notDeleted, take: 20 },
        honeymoonPackages: { where: notDeleted, take: 20 },
        representatives: { where: notDeleted },
        payouts: { where: notDeleted, take: 20, orderBy: { createdAt: 'desc' } },
      },
    });
  },
  findByUserId(userId: string) {
    return prisma.vendor.findFirst({ where: { userId, ...notDeleted } });
  },
  create(data: Prisma.VendorCreateInput) {
    return prisma.vendor.create({ data });
  },
  update(id: string, data: Prisma.VendorUpdateInput) {
    return prisma.vendor.update({ where: { id }, data });
  },
};
