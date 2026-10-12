import { FavoriteResourceType, type Prisma } from '@prisma/client';
import { NotFoundError } from '../../lib/errors.js';
import { notDeleted, paginated, skipTake } from '../../lib/common.js';
import { prisma } from '../../lib/prisma.js';
import { hotelsProvider } from '../../integrations/index.js';
import { favoriteRepository } from './favorite.repository.js';
import type { z } from 'zod';
import type { favoriteBody, favoriteListQuery } from './favorite.schema.js';

const uuidRe = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function hotelWhere(id: string): Prisma.HotelWhereInput {
  return uuidRe.test(id) ? { OR: [{ id }, { providerRef: id }], ...notDeleted } : { providerRef: id, ...notDeleted };
}

async function persistHotel(id: string) {
  const existing = await prisma.hotel.findFirst({
    where: hotelWhere(id),
  });
  if (existing) {
    return existing;
  }
  const offer = await hotelsProvider.getHotel(id);
  if (!offer) {
    return null;
  }
  return prisma.hotel.create({
    data: {
      name: offer.name as Prisma.InputJsonValue,
      description: offer.description as Prisma.InputJsonValue,
      city: offer.city,
      country: offer.country,
      address: offer.address as Prisma.InputJsonValue,
      latitude: offer.latitude,
      longitude: offer.longitude,
      starRating: offer.starRating,
      amenities: offer.amenities as Prisma.InputJsonValue,
      providerRef: offer.hotelId,
    },
  });
}

async function assertTarget(type: FavoriteResourceType, id: string): Promise<string> {
  if (type === FavoriteResourceType.HOTEL) {
    const hotel = await persistHotel(id);
    if (!hotel) {
      throw new NotFoundError('Favorite target not found');
    }
    return hotel.id;
  }
  const found =
    type === FavoriteResourceType.VENUE
      ? await prisma.venue.findFirst({ where: { id, ...notDeleted } })
      : type === FavoriteResourceType.LISTING
        ? await prisma.listing.findFirst({ where: { id, ...notDeleted } })
        : type === FavoriteResourceType.VENDOR
          ? await prisma.vendor.findFirst({ where: { id, ...notDeleted } })
          : type === FavoriteResourceType.CAR
            ? await prisma.car.findFirst({ where: { id, ...notDeleted } })
            : type === FavoriteResourceType.ACCOMMODATION
              ? await prisma.accommodation.findFirst({ where: { id, ...notDeleted } })
              : await prisma.honeymoonPackage.findFirst({ where: { id, ...notDeleted } });
  if (!found) {
    throw new NotFoundError('Favorite target not found');
  }
  return found.id;
}

async function withTargets<T extends { resourceType: FavoriteResourceType; resourceId: string }>(items: T[]) {
  const ids = (type: FavoriteResourceType) =>
    items.filter((item) => item.resourceType === type).map((item) => item.resourceId);
  const [venues, listings, vendors, cars, stays, honeymoons, hotels] = await Promise.all([
    prisma.venue.findMany({ where: { id: { in: ids(FavoriteResourceType.VENUE) } } }),
    prisma.listing.findMany({ where: { id: { in: ids(FavoriteResourceType.LISTING) } } }),
    prisma.vendor.findMany({ where: { id: { in: ids(FavoriteResourceType.VENDOR) } } }),
    prisma.car.findMany({ where: { id: { in: ids(FavoriteResourceType.CAR) } } }),
    prisma.accommodation.findMany({ where: { id: { in: ids(FavoriteResourceType.ACCOMMODATION) } } }),
    prisma.honeymoonPackage.findMany({ where: { id: { in: ids(FavoriteResourceType.HONEYMOON) } } }),
    prisma.hotel.findMany({ where: { id: { in: ids(FavoriteResourceType.HOTEL) } } }),
  ]);
  const index = <R extends { id: string }>(rows: R[]) => Object.fromEntries(rows.map((row) => [row.id, row]));
  const venueById = index(venues);
  const listingById = index(listings);
  const vendorById = index(vendors);
  const carById = index(cars);
  const stayById = index(stays);
  const honeymoonById = index(honeymoons);
  const hotelById = index(hotels);
  return items.map((item) => {
    const target =
      item.resourceType === FavoriteResourceType.VENUE
        ? venueById[item.resourceId]
        : item.resourceType === FavoriteResourceType.LISTING
          ? listingById[item.resourceId]
          : item.resourceType === FavoriteResourceType.VENDOR
            ? vendorById[item.resourceId]
            : item.resourceType === FavoriteResourceType.CAR
              ? carById[item.resourceId]
              : item.resourceType === FavoriteResourceType.ACCOMMODATION
                ? stayById[item.resourceId]
                : item.resourceType === FavoriteResourceType.HOTEL
                  ? hotelById[item.resourceId]
                  : honeymoonById[item.resourceId];
    const named = target as { name?: unknown; title?: unknown; businessName?: unknown; city?: string; providerRef?: string | null } | undefined;
    return {
      ...item,
      name: named?.name ?? named?.title ?? named?.businessName ?? null,
      city: named?.city ?? null,
      providerRef: named?.providerRef ?? null,
    };
  });
}

export const favoriteService = {
  async list(userId: string, query: z.infer<typeof favoriteListQuery>) {
    const { skip, take } = skipTake(query);
    const [items, total] = await favoriteRepository.list(
      { userId, ...notDeleted, ...(query.resourceType ? { resourceType: query.resourceType } : {}) },
      skip,
      take,
    );
    return paginated(await withTargets(items), total, query);
  },
  async add(userId: string, input: z.infer<typeof favoriteBody>) {
    const resourceId = await assertTarget(input.resourceType, input.resourceId);
    const existing = await favoriteRepository.find(userId, input.resourceType, resourceId);
    if (existing) {
      const [hydrated] = await withTargets([existing]);
      return hydrated;
    }
    const created = await favoriteRepository.create({
      user: { connect: { id: userId } },
      resourceType: input.resourceType,
      resourceId,
    });
    const [hydrated] = await withTargets([created]);
    return hydrated;
  },
  async remove(userId: string, input: z.infer<typeof favoriteBody>) {
    let resourceId = input.resourceId;
    if (input.resourceType === FavoriteResourceType.HOTEL) {
      const hotel = await prisma.hotel.findFirst({
        where: hotelWhere(input.resourceId),
      });
      if (hotel) {
        resourceId = hotel.id;
      }
    }
    const existing = await favoriteRepository.find(userId, input.resourceType, resourceId);
    if (!existing) {
      throw new NotFoundError('Favorite not found');
    }
    await favoriteRepository.softDelete(existing.id);
    return { deleted: true };
  },
};
