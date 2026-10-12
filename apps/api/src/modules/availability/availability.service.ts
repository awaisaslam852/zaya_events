import { AvailabilityResourceType, AvailabilitySlotStatus, Role } from '@prisma/client';
import { AppError, ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { paginated, skipTake } from '../../lib/common.js';
import { prisma } from '../../lib/prisma.js';
import { availabilityRepository } from './availability.repository.js';
import type { z } from 'zod';
import type { availabilityListQuery, availabilityUpsertSchema } from './availability.schema.js';

async function assertCanManage(
  userId: string,
  role: Role,
  resourceType: AvailabilityResourceType,
  resourceId: string,
): Promise<void> {
  if (role === Role.ADMIN) {
    return;
  }
  if (role !== Role.VENDOR) {
    throw new ForbiddenError();
  }
  const vendor = await prisma.vendor.findFirst({ where: { userId, deletedAt: null } });
  if (!vendor) {
    throw new ForbiddenError();
  }
  const owned = await resourceOwnedByVendor(vendor.id, resourceType, resourceId);
  if (!owned) {
    throw new ForbiddenError();
  }
}

async function resourceOwnedByVendor(
  vendorId: string,
  resourceType: AvailabilityResourceType,
  resourceId: string,
): Promise<boolean> {
  switch (resourceType) {
    case AvailabilityResourceType.VENUE: {
      const row = await prisma.venue.findFirst({ where: { id: resourceId, vendorId, deletedAt: null } });
      return Boolean(row);
    }
    case AvailabilityResourceType.LISTING: {
      const row = await prisma.listing.findFirst({ where: { id: resourceId, vendorId, deletedAt: null } });
      return Boolean(row);
    }
    case AvailabilityResourceType.CAR: {
      const row = await prisma.car.findFirst({ where: { id: resourceId, vendorId, deletedAt: null } });
      return Boolean(row);
    }
    case AvailabilityResourceType.ACCOMMODATION: {
      const row = await prisma.accommodation.findFirst({
        where: { id: resourceId, vendorId, deletedAt: null },
      });
      return Boolean(row);
    }
    case AvailabilityResourceType.HONEYMOON: {
      const row = await prisma.honeymoonPackage.findFirst({
        where: { id: resourceId, vendorId, deletedAt: null },
      });
      return Boolean(row);
    }
    case AvailabilityResourceType.REPRESENTATIVE: {
      const row = await prisma.representative.findFirst({
        where: { id: resourceId, vendorId, deletedAt: null },
      });
      return Boolean(row);
    }
    default:
      return false;
  }
}

export function slotsOverlap(startA: Date, endA: Date, startB: Date, endB: Date): boolean {
  return startA < endB && startB < endA;
}

export async function assertNoOverlap(params: {
  resourceType: AvailabilityResourceType;
  resourceId: string;
  startAt: Date;
  endAt: Date;
  excludeId?: string;
}): Promise<void> {
  if (params.endAt <= params.startAt) {
    throw new AppError(422, 'INVALID_RANGE', 'endAt must be after startAt');
  }
  const hits = await availabilityRepository.overlapping(params);
  if (hits.length > 0) {
    throw new AppError(409, 'AVAILABILITY_OVERLAP', 'This time range overlaps an existing unavailable or reserved slot');
  }
}

export const availabilityService = {
  async list(query: z.infer<typeof availabilityListQuery>) {
    const { skip, take } = skipTake(query);
    const [items, total] = await availabilityRepository.list({
      resourceType: query.resourceType,
      resourceId: query.resourceId,
      from: query.from,
      to: query.to,
      skip,
      take,
    });
    return paginated(items, total, query);
  },

  async create(userId: string, role: Role, input: z.infer<typeof availabilityUpsertSchema>) {
    await assertCanManage(userId, role, input.resourceType, input.resourceId);
    await assertNoOverlap({
      resourceType: input.resourceType,
      resourceId: input.resourceId,
      startAt: input.startAt,
      endAt: input.endAt,
    });
    return availabilityRepository.create({
      resourceType: input.resourceType,
      resourceId: input.resourceId,
      startAt: input.startAt,
      endAt: input.endAt,
      status: input.status,
      isBlocked: input.isBlocked || input.status !== AvailabilitySlotStatus.AVAILABLE,
      source: input.source,
      notes: input.notes,
      priceOverride: input.priceOverride,
    });
  },

  async update(userId: string, role: Role, id: string, input: z.infer<typeof availabilityUpsertSchema>) {
    const existing = await availabilityRepository.find(id);
    if (!existing) {
      throw new NotFoundError('Availability slot not found');
    }
    await assertCanManage(userId, role, existing.resourceType, existing.resourceId);
    await assertNoOverlap({
      resourceType: input.resourceType,
      resourceId: input.resourceId,
      startAt: input.startAt,
      endAt: input.endAt,
      excludeId: id,
    });
    return availabilityRepository.update(id, {
      startAt: input.startAt,
      endAt: input.endAt,
      status: input.status,
      isBlocked: input.isBlocked,
      source: input.source,
      notes: input.notes,
      priceOverride: input.priceOverride,
    });
  },

  async remove(userId: string, role: Role, id: string) {
    const existing = await availabilityRepository.find(id);
    if (!existing) {
      throw new NotFoundError('Availability slot not found');
    }
    await assertCanManage(userId, role, existing.resourceType, existing.resourceId);
    await availabilityRepository.softDelete(id);
    return { deleted: true };
  },

  assertNoOverlap,
  reserve: availabilityRepository.reserve,
};
