import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const carRepository = {
  list(where: Prisma.CarWhereInput, skip: number, take: number) {
    return prisma.$transaction([
      prisma.car.findMany({ where, include: { vendor: true }, orderBy: { createdAt: 'desc' }, skip, take }),
      prisma.car.count({ where }),
    ]);
  },
  findById(id: string) {
    return prisma.car.findFirst({
      where: { id, ...notDeleted },
      include: { vendor: true, availability: { where: notDeleted } },
    });
  },
  create(data: Prisma.CarCreateInput) {
    return prisma.car.create({ data });
  },
  update(id: string, data: Prisma.CarUpdateInput) {
    return prisma.car.update({ where: { id }, data });
  },
};
