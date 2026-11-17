import { BookingType, type Prisma } from '@prisma/client';
import { AppError, ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { mediaPublicUrl, notDeleted } from '../../lib/common.js';
import { currencyForCountry } from '../../lib/countries.js';
import { quoteVenueAmount, quoteVenueCurrency } from '../../lib/venue-pricing.js';
import { prisma } from '../../lib/prisma.js';
import { bookingService } from '../bookings/booking.service.js';
import { hotelService } from '../hotels/hotel.service.js';
import { cartRepository } from './cart.repository.js';
import type { z } from 'zod';
import type { cartAddSchema, cartCheckoutSchema } from './cart.schema.js';

type Snapshot = {
  title: { en: string; ar: string };
  imageUrl: string;
  city: string;
  unitAmount: number;
  currency: string;
};

function asText(value: unknown, fallback = ''): string {
  if (typeof value === 'string' && value.trim()) {
    return value.trim();
  }
  if (value && typeof value === 'object') {
    const map = value as Record<string, unknown>;
    const en = typeof map.en === 'string' ? map.en : '';
    const ar = typeof map.ar === 'string' ? map.ar : '';
    return en || ar || fallback;
  }
  return fallback;
}

function localizedTitle(value: unknown, fallback: string): { en: string; ar: string } {
  if (value && typeof value === 'object') {
    const map = value as Record<string, unknown>;
    const en = asText(map.en, fallback);
    const ar = asText(map.ar, en);
    return { en, ar };
  }
  const text = asText(value, fallback);
  return { en: text, ar: text };
}

function spanDays(startAt: Date, endAt?: Date) {
  return Math.max(1, Math.ceil(((endAt ?? startAt).getTime() - startAt.getTime()) / 86_400_000));
}

function money(value: unknown) {
  const amount = Number(value ?? 0);
  return Number.isFinite(amount) ? Math.round(amount * 100) / 100 : 0;
}

async function snapshotFor(
  type: BookingType,
  resourceId: string,
  startAt: Date,
  endAt?: Date,
  guestCount?: number,
): Promise<Snapshot> {
  if (type === BookingType.VENUE) {
    const venue = await prisma.venue.findFirst({
      where: { id: resourceId, ...notDeleted },
      include: { packages: { where: notDeleted }, vendor: true },
    });
    if (!venue) {
      throw new NotFoundError('Venue not found');
    }
    return {
      title: localizedTitle(venue.name, 'Venue'),
      imageUrl: mediaPublicUrl(venue.coverKey),
      city: venue.city,
      unitAmount: quoteVenueAmount({
        startingPrice: venue.startingPrice,
        pricingModel: venue.pricingModel,
        capacityMin: venue.capacityMin,
        packages: venue.packages,
        guestCount,
      }),
      currency: quoteVenueCurrency(
        { currency: venue.currency, packages: venue.packages },
        currencyForCountry(venue.country ?? venue.vendor?.country, venue.packages[0]?.currency),
      ),
    };
  }
  if (type === BookingType.LISTING) {
    const listing = await prisma.listing.findFirst({
      where: { id: resourceId, ...notDeleted },
      include: { vendor: true, packages: { where: notDeleted } },
    });
    if (!listing) {
      throw new NotFoundError('Listing not found');
    }
    return {
      title: localizedTitle(listing.title, 'Listing'),
      imageUrl: mediaPublicUrl(listing.coverKey),
      city: listing.city ?? '',
      unitAmount: money(listing.packages[0]?.priceAmount ?? listing.startingPrice),
      currency: currencyForCountry(listing.country ?? listing.vendor?.country, listing.currency),
    };
  }
  if (type === BookingType.CAR) {
    const car = await prisma.car.findFirst({ where: { id: resourceId, ...notDeleted }, include: { vendor: true } });
    if (!car) {
      throw new NotFoundError('Car not found');
    }
    return {
      title: localizedTitle(car.name, `${car.make} ${car.model}`),
      imageUrl: mediaPublicUrl(car.coverKey),
      city: car.vendor?.city ?? '',
      unitAmount: money(car.dailyRate) * spanDays(startAt, endAt),
      currency: currencyForCountry(car.vendor?.country, car.currency),
    };
  }
  if (type === BookingType.ACCOMMODATION) {
    const stay = await prisma.accommodation.findFirst({
      where: { id: resourceId, ...notDeleted },
      include: { vendor: true },
    });
    if (!stay) {
      throw new NotFoundError('Accommodation not found');
    }
    return {
      title: localizedTitle(stay.name, 'Stay'),
      imageUrl: mediaPublicUrl(stay.coverKey),
      city: stay.city ?? '',
      unitAmount: money(stay.nightlyRate) * spanDays(startAt, endAt),
      currency: currencyForCountry(stay.country ?? stay.vendor?.country, stay.currency),
    };
  }
  if (type === BookingType.HONEYMOON) {
    const pack = await prisma.honeymoonPackage.findFirst({
      where: { id: resourceId, ...notDeleted },
      include: { vendor: true },
    });
    if (!pack) {
      throw new NotFoundError('Honeymoon package not found');
    }
    return {
      title: localizedTitle(pack.name, 'Honeymoon'),
      imageUrl: mediaPublicUrl(pack.coverKey),
      city: asText(pack.destination),
      unitAmount: money(pack.priceAmount),
      currency: currencyForCountry(pack.vendor?.country, pack.currency),
    };
  }
  if (type === BookingType.HOTEL) {
    let hotel = await prisma.hotel.findFirst({
      where: { OR: [{ id: resourceId }, { providerRef: resourceId }], ...notDeleted },
    });
    if (!hotel) {
      const { hotelsProvider } = await import('../../integrations/index.js');
      const offer = await hotelsProvider.getHotel(resourceId);
      if (!offer) {
        throw new NotFoundError('Hotel not found');
      }
      hotel = await prisma.hotel.create({
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
    return {
      title: localizedTitle(hotel.name, 'Hotel'),
      imageUrl: mediaPublicUrl(hotel.coverKey),
      city: hotel.city ?? '',
      unitAmount: 0,
      currency: currencyForCountry(hotel.country),
    };
  }
  throw new AppError(422, 'CART_TYPE_UNSUPPORTED', 'This item cannot be added to the cart');
}

function bookingBody(item: { type: BookingType; resourceId: string; startAt: Date; endAt: Date | null; guestCount: number | null; notes: Prisma.JsonValue | null }, eventId?: string) {
  const notes = item.notes && typeof item.notes === 'object' ? (item.notes as { en?: string; ar?: string }) : undefined;
  return {
    type: item.type,
    eventId,
    startAt: item.startAt,
    endAt: item.endAt ?? undefined,
    guestCount: item.guestCount ?? undefined,
    notes: notes?.en && notes?.ar ? { en: notes.en, ar: notes.ar } : undefined,
    venueId: item.type === BookingType.VENUE ? item.resourceId : undefined,
    listingId: item.type === BookingType.LISTING ? item.resourceId : undefined,
    carId: item.type === BookingType.CAR ? item.resourceId : undefined,
    accommodationId: item.type === BookingType.ACCOMMODATION ? item.resourceId : undefined,
    honeymoonId: item.type === BookingType.HONEYMOON ? item.resourceId : undefined,
  };
}

function present(item: { snapshot: Prisma.JsonValue } & Record<string, unknown>) {
  const snapshot = (item.snapshot ?? {}) as Partial<Snapshot>;
  return {
    ...item,
    title: snapshot.title ?? null,
    imageUrl: snapshot.imageUrl ?? '',
    city: snapshot.city ?? '',
    unitAmount: snapshot.unitAmount ?? 0,
    currency: snapshot.currency ?? 'AED',
  };
}

export const cartService = {
  async list(userId: string) {
    const items = await cartRepository.list({ userId, ...notDeleted });
    const presented = items.map(present);
    const subtotal = presented.reduce((sum, item) => sum + Number(item.unitAmount ?? 0), 0);
    const currency = presented[0]?.currency ?? 'AED';
    return {
      items: presented,
      total: presented.length,
      subtotal: Math.round(subtotal * 100) / 100,
      depositTotal: Math.round(subtotal * 0.3 * 100) / 100,
      currency,
    };
  },

  async add(userId: string, input: z.infer<typeof cartAddSchema>) {
    if (input.type === BookingType.FLIGHT) {
      throw new AppError(422, 'CART_TYPE_UNSUPPORTED', 'Flights cannot be added to the cart');
    }
    const snapshot = await snapshotFor(input.type, input.resourceId, input.startAt, input.endAt, input.guestCount);
    const created = await cartRepository.create({
      user: { connect: { id: userId } },
      type: input.type,
      resourceId: input.resourceId,
      startAt: input.startAt,
      endAt: input.endAt,
      guestCount: input.guestCount,
      notes: input.notes as Prisma.InputJsonValue | undefined,
      snapshot: snapshot as Prisma.InputJsonValue,
    });
    return present(created);
  },

  async remove(userId: string, id: string) {
    const item = await cartRepository.findById(id);
    if (!item || item.deletedAt) {
      throw new NotFoundError('Cart item not found');
    }
    if (item.userId !== userId) {
      throw new ForbiddenError();
    }
    await cartRepository.softDelete(id);
    return { deleted: true };
  },

  async clear(userId: string) {
    const items = await cartRepository.list({ userId, ...notDeleted });
    if (items.length) {
      await cartRepository.softDeleteMany(items.map((item) => item.id));
    }
    return { deleted: true, count: items.length };
  },

  async checkout(userId: string, input: z.infer<typeof cartCheckoutSchema>) {
    const items = await cartRepository.list({ userId, ...notDeleted });
    if (!items.length) {
      throw new AppError(422, 'CART_EMPTY', 'Your cart is empty');
    }
    const bookings: unknown[] = [];
    const errors: { id: string; message: string }[] = [];
    for (const item of items) {
      try {
        if (item.type === BookingType.HOTEL) {
          const endAt = item.endAt ?? new Date(item.startAt.getTime() + 86_400_000);
          bookings.push(
            await hotelService.book(userId, item.resourceId, {
              eventId: input.eventId,
              checkIn: item.startAt,
              checkOut: endAt,
              rooms: 1,
              guests: item.guestCount ?? 2,
            }),
          );
        } else {
          bookings.push(await bookingService.create(userId, bookingBody(item, input.eventId)));
        }
        await cartRepository.softDelete(item.id);
      } catch (error) {
        errors.push({
          id: item.id,
          message: error instanceof Error ? error.message : 'Could not book this item',
        });
      }
    }
    if (!bookings.length) {
      throw new AppError(422, 'CART_CHECKOUT_FAILED', errors[0]?.message ?? 'Checkout failed', errors);
    }
    return { bookings, errors, remaining: errors.length };
  },
};
