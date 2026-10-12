import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const honeymoonRepository = {
  list(where: Prisma.HoneymoonPackageWhereInput, skip: number, take: number) {
    return prisma.$transaction([
      prisma.honeymoonPackage.findMany({
        where,
        include: { vendor: true },
        orderBy: { createdAt: 'desc' },
        skip,
        take,
      }),
      prisma.honeymoonPackage.count({ where }),
    ]);
  },
  findById(id: string) {
    return prisma.honeymoonPackage.findFirst({ where: { id, ...notDeleted }, include: { vendor: true } });
  },
  create(data: Prisma.HoneymoonPackageCreateInput) {
    return prisma.honeymoonPackage.create({ data });
  },
  update(id: string, data: Prisma.HoneymoonPackageUpdateInput) {
    return prisma.honeymoonPackage.update({ where: { id }, data });
  },
};
