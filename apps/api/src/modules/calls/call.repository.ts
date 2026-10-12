import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const callRepository = {
  create(data: Prisma.CallCreateInput) {
    return prisma.call.create({ data });
  },
  findById(id: string) {
    return prisma.call.findFirst({
      where: { id, ...notDeleted },
      include: {
        caller: { select: { id: true, firstName: true, lastName: true, phone: true } },
        callee: { select: { id: true, firstName: true, lastName: true, phone: true } },
      },
    });
  },
  list(userId: string | null, skip: number, take: number, q?: string) {
    const search: Prisma.CallWhereInput | undefined = q
      ? {
          OR: [
            { channelName: { contains: q, mode: 'insensitive' } },
            { caller: { email: { contains: q, mode: 'insensitive' } } },
            { callee: { email: { contains: q, mode: 'insensitive' } } },
          ],
        }
      : undefined;
    const where: Prisma.CallWhereInput = {
      ...notDeleted,
      AND: [
        ...(userId ? [{ OR: [{ callerId: userId }, { calleeId: userId }] }] : []),
        ...(search ? [search] : []),
      ],
    };
    return prisma.$transaction([
      prisma.call.findMany({
        where,
        include: {
          caller: { select: { id: true, firstName: true, lastName: true } },
          callee: { select: { id: true, firstName: true, lastName: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take,
      }),
      prisma.call.count({ where }),
    ]);
  },
  update(id: string, data: Prisma.CallUpdateInput) {
    return prisma.call.update({ where: { id }, data });
  },
};
