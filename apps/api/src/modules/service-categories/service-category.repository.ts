import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const serviceCategoryRepository = {
  list(includeInactive: boolean, skip: number, take: number, q?: string) {
    const where = {
      ...notDeleted,
      ...(includeInactive ? {} : { isActive: true }),
      ...(q ? { slug: { contains: q, mode: 'insensitive' as const } } : {}),
    };
    return prisma.$transaction([
      prisma.serviceCategory.findMany({ where, orderBy: { sortOrder: 'asc' }, skip, take }),
      prisma.serviceCategory.count({ where }),
    ]);
  },
  findById(id: string) {
    return prisma.serviceCategory.findFirst({ where: { id, ...notDeleted } });
  },
  findBySlug(slug: string) {
    return prisma.serviceCategory.findFirst({ where: { slug, ...notDeleted } });
  },
  create(data: Prisma.ServiceCategoryCreateInput) {
    return prisma.serviceCategory.create({ data });
  },
  update(id: string, data: Prisma.ServiceCategoryUpdateInput) {
    return prisma.serviceCategory.update({ where: { id }, data });
  },
};
