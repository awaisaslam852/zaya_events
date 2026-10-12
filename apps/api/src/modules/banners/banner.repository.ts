import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const bannerRepository = {
  list(where: Prisma.BannerWhereInput, skip: number, take: number) {
    return prisma.$transaction([
      prisma.banner.findMany({ where, orderBy: { sortOrder: 'asc' }, skip, take }),
      prisma.banner.count({ where }),
    ]);
  },
  findById(id: string) {
    return prisma.banner.findFirst({ where: { id, ...notDeleted } });
  },
  create(data: Prisma.BannerCreateInput) {
    return prisma.banner.create({ data });
  },
  update(id: string, data: Prisma.BannerUpdateInput) {
    return prisma.banner.update({ where: { id }, data });
  },
};
