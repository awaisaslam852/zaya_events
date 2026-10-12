import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const commissionRepository = {
  listLedger(where: Prisma.CommissionWhereInput, skip: number, take: number) {
    return prisma.$transaction([
      prisma.commission.findMany({
        where,
        include: { vendor: true, booking: true },
        orderBy: { createdAt: 'desc' },
        skip,
        take,
      }),
      prisma.commission.count({ where }),
    ]);
  },
  listRates() {
    return prisma.commissionRate.findMany({ where: notDeleted, orderBy: { createdAt: 'desc' } });
  },
  createRate(data: Prisma.CommissionRateCreateInput) {
    return prisma.commissionRate.create({ data });
  },
  updateRate(id: string, data: Prisma.CommissionRateUpdateInput) {
    return prisma.commissionRate.update({ where: { id }, data });
  },
};
