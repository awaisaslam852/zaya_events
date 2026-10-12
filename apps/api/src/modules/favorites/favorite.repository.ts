import { FavoriteResourceType, type Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const favoriteRepository = {
  list(where: Prisma.FavoriteWhereInput, skip: number, take: number) {
    return prisma.$transaction([
      prisma.favorite.findMany({ where, orderBy: { createdAt: 'desc' }, skip, take }),
      prisma.favorite.count({ where }),
    ]);
  },
  find(userId: string, resourceType: FavoriteResourceType, resourceId: string) {
    return prisma.favorite.findFirst({
      where: { userId, resourceType, resourceId, ...notDeleted },
    });
  },
  create(data: Prisma.FavoriteCreateInput) {
    return prisma.favorite.create({ data });
  },
  softDelete(id: string) {
    return prisma.favorite.update({ where: { id }, data: { deletedAt: new Date() } });
  },
};
