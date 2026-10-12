import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const payoutRepository = {
  list(where: Prisma.PayoutWhereInput, skip: number, take: number) {
    return prisma.$transaction([
      prisma.payout.findMany({ where, include: { vendor: true }, orderBy: { createdAt: 'desc' }, skip, take }),
      prisma.payout.count({ where }),
    ]);
  },
  findById(id: string) {
    return prisma.payout.findFirst({ where: { id, ...notDeleted }, include: { vendor: true } });
  },
  create(data: Prisma.PayoutCreateInput) {
    return prisma.payout.create({ data, include: { vendor: true } });
  },
  update(id: string, data: Prisma.PayoutUpdateInput) {
    return prisma.payout.update({ where: { id }, data, include: { vendor: true } });
  },
};
