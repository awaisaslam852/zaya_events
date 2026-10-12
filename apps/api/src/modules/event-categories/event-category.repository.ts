import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const eventCategoryRepository = {
  list(includeInactive: boolean, skip: number, take: number, q?: string) {
    const where = {
      ...notDeleted,
      ...(includeInactive ? {} : { isActive: true }),
      ...(q ? { slug: { contains: q, mode: 'insensitive' as const } } : {}),
    };
    return prisma.$transaction([
      prisma.eventCategory.findMany({ where, orderBy: { sortOrder: 'asc' }, skip, take }),
      prisma.eventCategory.count({ where }),
    ]);
  },
  findById(id: string) {
    return prisma.eventCategory.findFirst({ where: { id, ...notDeleted } });
  },
  findBySlug(slug: string) {
    return prisma.eventCategory.findFirst({ where: { slug, ...notDeleted } });
  },
  create(data: Prisma.EventCategoryCreateInput) {
    return prisma.eventCategory.create({ data });
  },
  update(id: string, data: Prisma.EventCategoryUpdateInput) {
    return prisma.eventCategory.update({ where: { id }, data });
  },
};
