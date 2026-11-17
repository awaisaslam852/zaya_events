import { AvailabilityResourceType, BookingType, FavoriteResourceType, Role, type Prisma } from '@prisma/client';
import { adminScope, assertCountryAllowed, publicCatalogCountry, recordCountry, viaVendorCountry } from '../../lib/admin-scope.js';
import { currencyForCountry } from '../../lib/countries.js';
import { ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { findVendorForUser, notDeleted, paginated, skipTake } from '../../lib/common.js';
import { prisma } from '../../lib/prisma.js';
import { availabilityRepository } from '../availability/availability.repository.js';
import { bookingService } from '../bookings/booking.service.js';
import { mapsProvider } from '../../integrations/index.js';
import { reviewService } from '../reviews/review.service.js';
import { venueRepository } from './venue.repository.js';
import type { z } from 'zod';
import type {
  venueBody,
  venueInquirySchema,
  venueListQuery,
  venuePackageBody,
  venuePackagePatch,
  venuePatch,
} from './venue.schema.js';

export const venueService = {
  async list(query: z.infer<typeof venueListQuery>, user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] }) {
    const { skip, take } = skipTake(query);
    let vendorId = query.vendorId;
    if (user?.role === Role.VENDOR) {
      const vendor = await findVendorForUser(user.id);
      vendorId = vendor.id;
    }
    const where: Prisma.VenueWhereInput = {
      ...notDeleted,
      ...(user?.role === Role.ADMIN ? viaVendorCountry(adminScope(user)) : {}),
      ...(user?.role !== Role.ADMIN && user?.role !== Role.VENDOR ? publicCatalogCountry(query.country) : {}),
      ...(user?.role === Role.ADMIN || user?.role === Role.VENDOR ? {} : { isPublished: true }),
      ...(query.city ? { city: query.city } : {}),
      ...(vendorId ? { vendorId } : {}),
      ...(query.minCapacity ? { capacityMax: { gte: query.minCapacity } } : {}),
      ...(query.maxCapacity ? { capacityMin: { lte: query.maxCapacity } } : {}),
    };
    const [items, total] = await venueRepository.list(where, skip, take);
    const map = query.city ? (await mapsProvider.geocode(query.city))[0] ?? null : null;
    const nearby = query.city ? await mapsProvider.places(`wedding venue ${query.city}`) : [];
    return paginated(items.map((item) => ({ ...item, map, nearby })), total, query);
  },
  async get(id: string, user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] }) {
    const row = await venueRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Venue not found');
    }
    if (user?.role === Role.ADMIN) {
      assertCountryAllowed(adminScope(user), recordCountry(row));
    }
    const reviews = await reviewService.publicFor({ venueId: row.id });
    return { ...row, reviews };
  },
  async calendar(id: string, from?: Date, to?: Date) {
    await this.get(id);
    const [items] = await availabilityRepository.list({
      resourceType: AvailabilityResourceType.VENUE,
      resourceId: id,
      from,
      to,
      skip: 0,
      take: 500,
    });
    return { items };
  },
  async create(userId: string, input: z.infer<typeof venueBody>) {
    const vendor = await findVendorForUser(userId);
    const { country: _ignoredCountry, ...rest } = input;
    const country = vendor.country || 'AE';
    const currency = currencyForCountry(country, input.currency);
    return venueRepository.create({
      vendor: { connect: { id: vendor.id } },
      ...rest,
      country,
      currency,
      startingPrice: input.startingPrice ?? 0,
      pricingModel: input.pricingModel ?? 'HYBRID',
    });
  },
  async update(
    userId: string,
    role: Role,
    id: string,
    input: z.infer<typeof venuePatch>,
    user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] },
  ) {
    const venue = await this.get(id, user ?? { id: userId, role });
    if (role !== Role.ADMIN) {
      const vendor = await findVendorForUser(userId);
      if (venue.vendorId !== vendor.id) {
        throw new ForbiddenError();
      }
    }
    const { country: _ignoredCountry, ...patch } = input;
    const country = venue.vendor?.country ?? venue.country;
    const updated = await venueRepository.update(id, {
      ...patch,
      country,
      ...(input.currency ? { currency: currencyForCountry(country, input.currency) } : {}),
    });
    const startingPrice = Number(input.startingPrice ?? updated.startingPrice ?? 0);
    if (startingPrice > 0 && (updated.packages?.length ?? 0) === 0) {
      await venueRepository.addPackage(id, {
        name: { en: 'Venue hire', ar: 'إيجار القاعة' },
        description: {
          en: 'Standard venue hire for the event date.',
          ar: 'إيجار القاعة لتاريخ المناسبة.',
        },
        priceAmount: startingPrice,
        currency: updated.currency,
        guestCountMin: updated.capacityMin,
        guestCountMax: updated.capacityMax,
        durationHours: 4,
        pricingUnit: updated.pricingModel === 'PER_GUEST' ? 'GUEST' : 'EVENT',
      });
      return this.get(id, user ?? { id: userId, role });
    }
    return updated;
  },
  async addPackage(
    userId: string,
    role: Role,
    venueId: string,
    input: z.infer<typeof venuePackageBody>,
    user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] },
  ) {
    const venue = await this.get(venueId, user ?? { id: userId, role });
    if (role !== Role.ADMIN) {
      const vendor = await findVendorForUser(userId);
      if (venue.vendorId !== vendor.id) {
        throw new ForbiddenError();
      }
    }
    return venueRepository.addPackage(venueId, {
      ...input,
      currency: currencyForCountry(venue.country, input.currency ?? venue.currency),
    });
  },
  async updatePackage(
    userId: string,
    role: Role,
    venueId: string,
    packageId: string,
    input: z.infer<typeof venuePackagePatch>,
    user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] },
  ) {
    const venue = await this.get(venueId, user ?? { id: userId, role });
    if (role !== Role.ADMIN) {
      const vendor = await findVendorForUser(userId);
      if (venue.vendorId !== vendor.id) {
        throw new ForbiddenError();
      }
    }
    const row = await venueRepository.findPackage(packageId);
    if (!row || row.venueId !== venueId) {
      throw new NotFoundError('Package not found');
    }
    return venueRepository.updatePackage(packageId, {
      ...input,
      ...(input.currency ? { currency: currencyForCountry(venue.country, input.currency) } : {}),
    });
  },
  async removePackage(
    userId: string,
    role: Role,
    venueId: string,
    packageId: string,
    user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] },
  ) {
    const venue = await this.get(venueId, user ?? { id: userId, role });
    if (role !== Role.ADMIN) {
      const vendor = await findVendorForUser(userId);
      if (venue.vendorId !== vendor.id) {
        throw new ForbiddenError();
      }
    }
    const row = await venueRepository.findPackage(packageId);
    if (!row || row.venueId !== venueId) {
      throw new NotFoundError('Package not found');
    }
    await venueRepository.removePackage(packageId);
    return { deleted: true };
  },
  async inquire(userId: string, venueId: string, input: z.infer<typeof venueInquirySchema>) {
    await this.get(venueId);
    return bookingService.create(
      userId,
      {
        type: BookingType.VENUE,
        venueId,
        venuePackageId: input.venuePackageId,
        eventId: input.eventId,
        startAt: input.startAt,
        endAt: input.endAt,
        guestCount: input.guestCount,
        notes: input.notes,
      },
      true,
    );
  },
  async remove(
    userId: string,
    role: Role,
    id: string,
    user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] },
  ) {
    const venue = await this.get(id, user ?? { id: userId, role });
    if (role !== Role.ADMIN) {
      const vendor = await findVendorForUser(userId);
      if (venue.vendorId !== vendor.id) {
        throw new ForbiddenError();
      }
    }
    await venueRepository.update(id, { deletedAt: new Date(), isPublished: false });
    return { deleted: true };
  },
  async toggleFavorite(userId: string, venueId: string) {
    await this.get(venueId);
    const existing = await prisma.favorite.findFirst({
      where: { userId, resourceType: FavoriteResourceType.VENUE, resourceId: venueId, deletedAt: null },
    });
    if (existing) {
      await prisma.favorite.update({ where: { id: existing.id }, data: { deletedAt: new Date() } });
      return { favorited: false };
    }
    await prisma.favorite.create({
      data: { userId, resourceType: FavoriteResourceType.VENUE, resourceId: venueId },
    });
    return { favorited: true };
  },
};
