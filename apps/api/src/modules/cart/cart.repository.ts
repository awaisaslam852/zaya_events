import { type Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';

export const cartRepository = {
  list(where: Prisma.CartItemWhereInput) {
    return prisma.cartItem.findMany({ where, orderBy: { createdAt: 'desc' } });
  },
  count(where: Prisma.CartItemWhereInput) {
    return prisma.cartItem.count({ where });
  },
  findById(id: string) {
    return prisma.cartItem.findFirst({ where: { id } });
  },
  create(data: Prisma.CartItemCreateInput) {
    return prisma.cartItem.create({ data });
  },
  softDelete(id: string) {
    return prisma.cartItem.update({ where: { id }, data: { deletedAt: new Date() } });
  },
  softDeleteMany(ids: string[]) {
    return prisma.cartItem.updateMany({
      where: { id: { in: ids } },
      data: { deletedAt: new Date() },
    });
  },
};
