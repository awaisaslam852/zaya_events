import { AvailabilityResourceType, BookingType, FavoriteResourceType, Role, type Prisma } from '@prisma/client';
import { ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { findVendorForUser, notDeleted, paginated, skipTake } from '../../lib/common.js';
import { prisma } from '../../lib/prisma.js';
import { availabilityRepository } from '../availability/availability.repository.js';
import { bookingService } from '../bookings/booking.service.js';
import { mapsProvider } from '../../integrations/index.js';
import { venueRepository } from './venue.repository.js';
import type { z } from 'zod';
import type { venueBody, venueInquirySchema, venueListQuery, venuePackageBody, venuePatch } from './venue.schema.js';

export const venueService = {
  async list(query: z.infer<typeof venueListQuery>, user?: { id: string; role: Role }) {
    const { skip, take } = skipTake(query);
    const where: Prisma.VenueWhereInput = {
      ...notDeleted,
      ...(user?.role === Role.ADMIN ? {} : { isPublished: true }),
      ...(query.city ? { city: query.city } : {}),
      ...(query.vendorId ? { vendorId: query.vendorId } : {}),
      ...(query.minCapacity ? { capacityMax: { gte: query.minCapacity } } : {}),
      ...(query.maxCapacity ? { capacityMin: { lte: query.maxCapacity } } : {}),
    };
    const [items, total] = await venueRepository.list(where, skip, take);
    const map = query.city ? (await mapsProvider.geocode(query.city))[0] ?? null : null;
    const nearby = query.city ? await mapsProvider.places(`wedding venue ${query.city}`) : [];
    return paginated(items.map((item) => ({ ...item, map, nearby })), total, query);
  },
  async get(id: string) {
    const row = await venueRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Venue not found');
    }
    return row;
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
    return venueRepository.create({
      vendor: { connect: { id: vendor.id } },
      ...input,
    });
  },
  async update(userId: string, role: Role, id: string, input: z.infer<typeof venuePatch>) {
    const venue = await this.get(id);
    if (role !== Role.ADMIN) {
      const vendor = await findVendorForUser(userId);
      if (venue.vendorId !== vendor.id) {
        throw new ForbiddenError();
      }
    }
    return venueRepository.update(id, input);
  },
  async addPackage(userId: string, role: Role, venueId: string, input: z.infer<typeof venuePackageBody>) {
    await this.update(userId, role, venueId, {});
    return venueRepository.addPackage(venueId, input);
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
  async remove(userId: string, role: Role, id: string) {
    const venue = await this.get(id);
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
