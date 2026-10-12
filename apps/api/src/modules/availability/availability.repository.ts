import {
  AvailabilityResourceType,
  AvailabilitySlotStatus,
  Prisma,
} from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const availabilityRepository = {
  overlapping(params: {
    resourceType: AvailabilityResourceType;
    resourceId: string;
    startAt: Date;
    endAt: Date;
    excludeId?: string;
  }) {
    return prisma.availability.findMany({
      where: {
        ...notDeleted,
        resourceType: params.resourceType,
        resourceId: params.resourceId,
        id: params.excludeId ? { not: params.excludeId } : undefined,
        startAt: { lt: params.endAt },
        endAt: { gt: params.startAt },
        OR: [{ isBlocked: true }, { status: { in: [AvailabilitySlotStatus.UNAVAILABLE, AvailabilitySlotStatus.RESERVED] } }],
      },
    });
  },
  list(params: {
    resourceType: AvailabilityResourceType;
    resourceId: string;
    from?: Date;
    to?: Date;
    skip: number;
    take: number;
  }) {
    const where: Prisma.AvailabilityWhereInput = {
      ...notDeleted,
      resourceType: params.resourceType,
      resourceId: params.resourceId,
      ...(params.from || params.to
        ? {
            startAt: params.to ? { lte: params.to } : undefined,
            endAt: params.from ? { gte: params.from } : undefined,
          }
        : {}),
    };
    return prisma.$transaction([
      prisma.availability.findMany({ where, orderBy: { startAt: 'asc' }, skip: params.skip, take: params.take }),
      prisma.availability.count({ where }),
    ]);
  },
  create(data: Prisma.AvailabilityCreateInput) {
    return prisma.availability.create({ data });
  },
  update(id: string, data: Prisma.AvailabilityUpdateInput) {
    return prisma.availability.update({ where: { id }, data });
  },
  find(id: string) {
    return prisma.availability.findFirst({ where: { id, ...notDeleted } });
  },
  softDelete(id: string) {
    return prisma.availability.update({ where: { id }, data: { deletedAt: new Date() } });
  },
  reserve(params: {
    resourceType: AvailabilityResourceType;
    resourceId: string;
    startAt: Date;
    endAt: Date;
    bookingId: string;
  }) {
    return prisma.availability.create({
      data: {
        resourceType: params.resourceType,
        resourceId: params.resourceId,
        startAt: params.startAt,
        endAt: params.endAt,
        status: AvailabilitySlotStatus.RESERVED,
        isBlocked: true,
        source: 'internal',
        bookingId: params.bookingId,
      },
    });
  },
};
