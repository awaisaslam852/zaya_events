import { BookingType, Role, type Prisma } from '@prisma/client';
import { ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { findVendorForUser, notDeleted, paginated, skipTake } from '../../lib/common.js';
import { bookingService } from '../bookings/booking.service.js';
import { honeymoonRepository } from './honeymoon.repository.js';
import type { z } from 'zod';
import type { honeymoonBody, honeymoonInquirySchema, honeymoonListQuery, honeymoonPatch } from './honeymoon.schema.js';

export const honeymoonService = {
  async list(query: z.infer<typeof honeymoonListQuery>, user?: { id: string; role: Role }) {
    const { skip, take } = skipTake(query);
    const where: Prisma.HoneymoonPackageWhereInput = {
      ...notDeleted,
      ...(user?.role === Role.ADMIN ? {} : { isPublished: true }),
    };
    const [items, total] = await honeymoonRepository.list(where, skip, take);
    return paginated(items, total, query);
  },
  async get(id: string) {
    const row = await honeymoonRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Honeymoon package not found');
    }
    return row;
  },
  async create(userId: string, input: z.infer<typeof honeymoonBody>) {
    const vendor = await findVendorForUser(userId);
    return honeymoonRepository.create({ vendor: { connect: { id: vendor.id } }, ...input });
  },
  async update(userId: string, role: Role, id: string, input: z.infer<typeof honeymoonPatch>) {
    const row = await this.get(id);
    if (role !== Role.ADMIN) {
      const vendor = await findVendorForUser(userId);
      if (row.vendorId !== vendor.id) {
        throw new ForbiddenError();
      }
    }
    return honeymoonRepository.update(id, input);
  },
  async remove(userId: string, role: Role, id: string) {
    const row = await this.get(id);
    if (role !== Role.ADMIN) {
      const vendor = await findVendorForUser(userId);
      if (row.vendorId !== vendor.id) {
        throw new ForbiddenError();
      }
    }
    await honeymoonRepository.update(id, { deletedAt: new Date(), isPublished: false });
    return { deleted: true };
  },
  async inquire(userId: string, id: string, input: z.infer<typeof honeymoonInquirySchema>) {
    await this.get(id);
    return bookingService.create(
      userId,
      {
        type: BookingType.HONEYMOON,
        honeymoonId: id,
        eventId: input.eventId,
        startAt: input.startAt,
        endAt: input.endAt,
        notes: input.notes,
      },
      true,
    );
  },
};
