import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const paymentRepository = {
  list(where: Prisma.PaymentWhereInput, skip: number, take: number) {
    return prisma.$transaction([
      prisma.payment.findMany({ where, include: { booking: true }, orderBy: { createdAt: 'desc' }, skip, take }),
      prisma.payment.count({ where }),
    ]);
  },
  findById(id: string) {
    return prisma.payment.findFirst({ where: { id, ...notDeleted }, include: { booking: true, invoice: true } });
  },
  findByProviderRef(providerRef: string) {
    return prisma.payment.findFirst({ where: { providerRef, ...notDeleted } });
  },
  create(data: Prisma.PaymentCreateInput) {
    return prisma.payment.create({ data });
  },
  update(id: string, data: Prisma.PaymentUpdateInput) {
    return prisma.payment.update({ where: { id }, data });
  },
};
