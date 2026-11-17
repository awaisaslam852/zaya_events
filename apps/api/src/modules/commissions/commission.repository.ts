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
  listPolicies(countries?: string[]) {
    return prisma.countryCommissionPolicy.findMany({
      where: countries ? { country: { in: countries } } : undefined,
      orderBy: { country: 'asc' },
    });
  },
  findPolicy(country: string) {
    return prisma.countryCommissionPolicy.findUnique({ where: { country } });
  },
  upsertPolicy(
    country: string,
    data: { hqShareRate?: number; defaultVendorRate?: number },
  ) {
    return prisma.countryCommissionPolicy.upsert({
      where: { country },
      create: {
        country,
        hqShareRate: data.hqShareRate ?? 30,
        defaultVendorRate: data.defaultVendorRate ?? 12,
      },
      update: {
        ...(data.hqShareRate !== undefined ? { hqShareRate: data.hqShareRate } : {}),
        ...(data.defaultVendorRate !== undefined ? { defaultVendorRate: data.defaultVendorRate } : {}),
      },
    });
  },
};
