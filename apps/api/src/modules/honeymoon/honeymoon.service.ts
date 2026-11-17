import { BookingType, Role, type Prisma } from '@prisma/client';
import { adminScope, assertCountryAllowed, publicVendorCountry, recordCountry, viaVendorCountry } from '../../lib/admin-scope.js';
import { currencyForCountry } from '../../lib/countries.js';
import { ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { findVendorForUser, notDeleted, paginated, skipTake } from '../../lib/common.js';
import { bookingService } from '../bookings/booking.service.js';
import { honeymoonRepository } from './honeymoon.repository.js';
import type { z } from 'zod';
import type { honeymoonBody, honeymoonInquirySchema, honeymoonListQuery, honeymoonPatch } from './honeymoon.schema.js';

export const honeymoonService = {
  async list(query: z.infer<typeof honeymoonListQuery>, user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] }) {
    const { skip, take } = skipTake(query);
    let vendorId: string | undefined;
    if (user?.role === Role.VENDOR) {
      vendorId = (await findVendorForUser(user.id)).id;
    }
    const where: Prisma.HoneymoonPackageWhereInput = {
      ...notDeleted,
      ...(user?.role === Role.ADMIN ? viaVendorCountry(adminScope(user)) : {}),
      ...(user?.role !== Role.ADMIN && user?.role !== Role.VENDOR ? publicVendorCountry(query.country) : {}),
      ...(user?.role === Role.ADMIN || user?.role === Role.VENDOR ? {} : { isPublished: true }),
      ...(vendorId ? { vendorId } : {}),
    };
    const [items, total] = await honeymoonRepository.list(where, skip, take);
    return paginated(items, total, query);
  },
  async get(id: string, user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] }) {
    const row = await honeymoonRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Honeymoon package not found');
    }
    if (user?.role === Role.ADMIN) {
      assertCountryAllowed(adminScope(user), recordCountry(row));
    }
    return row;
  },
  async create(userId: string, input: z.infer<typeof honeymoonBody>) {
    const vendor = await findVendorForUser(userId);
    return honeymoonRepository.create({
      vendor: { connect: { id: vendor.id } },
      ...input,
      currency: currencyForCountry(vendor.country, input.currency),
    });
  },
  async update(
    userId: string,
    role: Role,
    id: string,
    input: z.infer<typeof honeymoonPatch>,
    user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] },
  ) {
    const row = await this.get(id, user ?? { id: userId, role });
    if (role !== Role.ADMIN) {
      const vendor = await findVendorForUser(userId);
      if (row.vendorId !== vendor.id) {
        throw new ForbiddenError();
      }
    }
    return honeymoonRepository.update(id, input);
  },
  async remove(
    userId: string,
    role: Role,
    id: string,
    user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] },
  ) {
    const row = await this.get(id, user ?? { id: userId, role });
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
