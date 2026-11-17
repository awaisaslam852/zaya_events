import { AvailabilityResourceType, BookingType, Role, type Prisma } from '@prisma/client';
import { adminScope, assertCountryAllowed, publicCatalogCountry, recordCountry, viaVendorCountry } from '../../lib/admin-scope.js';
import { currencyForCountry } from '../../lib/countries.js';
import { ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { findVendorForUser, notDeleted, paginated, skipTake } from '../../lib/common.js';
import { availabilityRepository } from '../availability/availability.repository.js';
import { bookingService } from '../bookings/booking.service.js';
import { accommodationRepository } from './accommodation.repository.js';
import type { z } from 'zod';
import type {
  accommodationBody,
  accommodationBookSchema,
  accommodationListQuery,
  accommodationPatch,
} from './accommodation.schema.js';

export const accommodationService = {
  async list(query: z.infer<typeof accommodationListQuery>, user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] }) {
    const { skip, take } = skipTake(query);
    let vendorId = query.vendorId;
    if (user?.role === Role.VENDOR) {
      const vendor = await findVendorForUser(user.id);
      vendorId = vendor.id;
    }
    const where: Prisma.AccommodationWhereInput = {
      ...notDeleted,
      ...(user?.role === Role.ADMIN ? viaVendorCountry(adminScope(user)) : {}),
      ...(user?.role !== Role.ADMIN && user?.role !== Role.VENDOR ? publicCatalogCountry(query.country) : {}),
      ...(vendorId ? { vendorId } : {}),
      ...(user?.role === Role.ADMIN || user?.role === Role.VENDOR ? {} : { isPublished: true }),
      ...(query.city ? { city: query.city } : {}),
      ...(query.type ? { type: query.type } : {}),
      ...(query.minGuests ? { maxGuests: { gte: query.minGuests } } : {}),
    };
    const [items, total] = await accommodationRepository.list(where, skip, take);
    return paginated(items, total, query);
  },
  async get(id: string, user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] }) {
    const row = await accommodationRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Accommodation not found');
    }
    if (user?.role === Role.ADMIN) {
      assertCountryAllowed(adminScope(user), recordCountry(row));
    }
    return row;
  },
  async calendar(id: string, from?: Date, to?: Date) {
    await this.get(id);
    const [items] = await availabilityRepository.list({
      resourceType: AvailabilityResourceType.ACCOMMODATION,
      resourceId: id,
      from,
      to,
      skip: 0,
      take: 500,
    });
    return { items };
  },
  async create(userId: string, input: z.infer<typeof accommodationBody>) {
    const vendor = await findVendorForUser(userId);
    const { country: _ignoredCountry, ...rest } = input;
    const country = vendor.country || 'AE';
    return accommodationRepository.create({
      vendor: { connect: { id: vendor.id } },
      ...rest,
      country,
      currency: currencyForCountry(country, input.currency),
    });
  },
  async update(
    userId: string,
    role: Role,
    id: string,
    input: z.infer<typeof accommodationPatch>,
    user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] },
  ) {
    const row = await this.get(id, user ?? { id: userId, role });
    if (role !== Role.ADMIN) {
      const vendor = await findVendorForUser(userId);
      if (row.vendorId !== vendor.id) {
        throw new ForbiddenError();
      }
    }
    const { country: _ignoredCountry, ...patch } = input;
    return accommodationRepository.update(id, {
      ...patch,
      country: row.vendor?.country ?? row.country,
    });
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
    await accommodationRepository.update(id, { deletedAt: new Date(), isPublished: false });
    return { deleted: true };
  },
  async book(userId: string, id: string, input: z.infer<typeof accommodationBookSchema>) {
    await this.get(id);
    return bookingService.create(userId, {
      type: BookingType.ACCOMMODATION,
      accommodationId: id,
      eventId: input.eventId,
      startAt: input.startAt,
      endAt: input.endAt,
      guestCount: input.guestCount,
      notes: input.notes,
    });
  },
};
