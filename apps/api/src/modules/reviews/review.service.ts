import { BookingStatus, ReviewDirection, Role, type Prisma } from '@prisma/client';
import { AppError, ConflictError, ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { notDeleted } from '../../lib/common.js';
import { prisma } from '../../lib/prisma.js';
import { notificationService } from '../notifications/notification.service.js';
import { REVIEW_MAX, REVIEW_MIN, bookingAllowsReview, reviewDirectionForRole } from './review.rules.js';
import type { reviewBodySchema } from './review.schema.js';
import type { z } from 'zod';

const reviewAuthorSelect = {
  id: true,
  firstName: true,
  lastName: true,
  vendor: { select: { businessName: true } },
} satisfies Prisma.UserSelect;

type ReviewWithAuthor = Prisma.ReviewGetPayload<{ include: { author: { select: typeof reviewAuthorSelect } } }>;

function localizedName(value: unknown): string {
  if (value && typeof value === 'object') {
    const map = value as Record<string, unknown>;
    const en = map.en?.toString().trim() ?? '';
    const ar = map.ar?.toString().trim() ?? '';
    return en || ar;
  }
  return '';
}

export function presentReview(row: ReviewWithAuthor) {
  const fromVendor = row.direction === ReviewDirection.VENDOR_TO_CUSTOMER;
  const business = localizedName(row.author.vendor?.businessName);
  const person = [row.author.firstName, row.author.lastName].filter(Boolean).join(' ').trim();
  return {
    id: row.id,
    bookingId: row.bookingId,
    direction: row.direction,
    rating: row.rating,
    body: row.body,
    createdAt: row.createdAt,
    authorName: fromVendor ? business || person : person,
  };
}

function commentBody(comment: string | undefined) {
  const text = comment?.trim() ?? '';
  if (!text) {
    return undefined;
  }
  return { en: text, ar: text };
}

async function refreshAverage(
  table: 'vendor' | 'venue' | 'listing' | 'user',
  id: string,
  direction: ReviewDirection,
) {
  const where: Prisma.ReviewWhereInput = {
    ...notDeleted,
    direction,
    ...(table === 'vendor' ? { vendorId: id } : {}),
    ...(table === 'venue' ? { venueId: id } : {}),
    ...(table === 'listing' ? { listingId: id } : {}),
    ...(table === 'user' ? { targetUserId: id } : {}),
  };
  const agg = await prisma.review.aggregate({
    where,
    _avg: { rating: true },
    _count: { _all: true },
  });
  const ratingAvg = Number(agg._avg.rating ?? 0);
  const ratingCount = agg._count._all;
  if (table === 'vendor') {
    await prisma.vendor.update({ where: { id }, data: { ratingAvg, ratingCount } });
  } else if (table === 'venue') {
    await prisma.venue.update({ where: { id }, data: { ratingAvg, ratingCount } });
  } else if (table === 'listing') {
    await prisma.listing.update({ where: { id }, data: { ratingAvg, ratingCount } });
  } else {
    await prisma.user.update({ where: { id }, data: { ratingAvg, ratingCount } });
  }
}

export function reviewStateFor(role: Role, userId: string, booking: {
  status: BookingStatus;
  customerId: string;
  vendor?: { userId: string } | null;
  reviews?: ReviewWithAuthor[];
}) {
  const direction = reviewDirectionForRole(role);
  const reviews = booking.reviews ?? [];
  const mine = direction ? reviews.find((row) => row.direction === direction && row.authorId === userId) : undefined;
  const theirs = direction
    ? reviews.find((row) => row.direction !== direction)
    : undefined;
  const party = booking.customerId === userId || booking.vendor?.userId === userId;
  return {
    canWrite: Boolean(party && direction && bookingAllowsReview(booking.status) && !mine),
    mine: mine ? presentReview(mine) : null,
    theirs: theirs ? presentReview(theirs) : null,
  };
}

export const reviewService = {
  async publicFor(filter: { venueId?: string; listingId?: string; vendorId?: string }, take = 8) {
    const items = await prisma.review.findMany({
      where: {
        ...notDeleted,
        direction: ReviewDirection.CUSTOMER_TO_VENDOR,
        ...(filter.venueId ? { venueId: filter.venueId } : {}),
        ...(filter.listingId ? { listingId: filter.listingId } : {}),
        ...(filter.vendorId ? { vendorId: filter.vendorId } : {}),
      },
      include: { author: { select: reviewAuthorSelect } },
      orderBy: { createdAt: 'desc' },
      take,
    });
    return items.map(presentReview);
  },

  async forVendor(userId: string) {
    const vendor = await prisma.vendor.findFirst({
      where: { userId, ...notDeleted },
      select: { id: true, ratingAvg: true, ratingCount: true },
    });
    if (!vendor) {
      throw new NotFoundError('Vendor profile not found');
    }
    const items = await prisma.review.findMany({
      where: { vendorId: vendor.id, direction: ReviewDirection.CUSTOMER_TO_VENDOR, ...notDeleted },
      include: { author: { select: reviewAuthorSelect } },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
    return {
      ratingAvg: vendor.ratingAvg,
      ratingCount: vendor.ratingCount,
      items: items.map(presentReview),
    };
  },

  async create(userId: string, role: Role, bookingId: string, input: z.infer<typeof reviewBodySchema>) {
    const direction = reviewDirectionForRole(role);
    if (!direction) {
      throw new ForbiddenError('Only customers and vendors can leave a review');
    }
    if (input.rating < REVIEW_MIN || input.rating > REVIEW_MAX) {
      throw new AppError(422, 'VALIDATION_ERROR', 'Rating must be between 1 and 5');
    }
    const booking = await prisma.booking.findFirst({
      where: { id: bookingId, ...notDeleted },
      include: {
        vendor: { select: { id: true, userId: true } },
        reviews: { where: notDeleted, include: { author: { select: reviewAuthorSelect } } },
      },
    });
    if (!booking) {
      throw new NotFoundError('Booking not found');
    }
    const isCustomer = booking.customerId === userId;
    const isVendor = booking.vendor?.userId === userId;
    if ((direction === ReviewDirection.CUSTOMER_TO_VENDOR && !isCustomer) ||
        (direction === ReviewDirection.VENDOR_TO_CUSTOMER && !isVendor)) {
      throw new ForbiddenError();
    }
    if (!bookingAllowsReview(booking.status)) {
      throw new AppError(422, 'REVIEW_NOT_READY', 'Reviews open after the booking is completed');
    }
    if (booking.reviews.some((row) => row.direction === direction)) {
      throw new ConflictError('You already reviewed this booking');
    }
    const targetUserId = direction === ReviewDirection.CUSTOMER_TO_VENDOR
      ? booking.vendor?.userId
      : booking.customerId;
    if (!targetUserId) {
      throw new AppError(422, 'REVIEW_NOT_READY', 'This booking has no vendor to review');
    }
    const created = await prisma.review.create({
      data: {
        bookingId: booking.id,
        authorId: userId,
        targetUserId,
        vendorId: booking.vendorId,
        venueId: booking.venueId,
        listingId: booking.listingId,
        direction,
        rating: input.rating,
        body: commentBody(input.comment),
      },
      include: { author: { select: reviewAuthorSelect } },
    });
    if (direction === ReviewDirection.CUSTOMER_TO_VENDOR) {
      if (booking.vendorId) {
        await refreshAverage('vendor', booking.vendorId, direction);
      }
      if (booking.venueId) {
        await refreshAverage('venue', booking.venueId, direction);
      }
      if (booking.listingId) {
        await refreshAverage('listing', booking.listingId, direction);
      }
    } else {
      await refreshAverage('user', booking.customerId, direction);
    }
    const presented = presentReview(created);
    const copy = direction === ReviewDirection.CUSTOMER_TO_VENDOR
      ? {
          title: { en: 'New guest review', ar: 'تقييم جديد من الضيف' },
          body: {
            en: `${presented.authorName} rated you ${input.rating}/5.`,
            ar: `قيّمك ${presented.authorName} ${input.rating}/5.`,
          },
        }
      : {
          title: { en: 'Vendor review', ar: 'تقييم من المورد' },
          body: {
            en: `The vendor rated this booking ${input.rating}/5.`,
            ar: `قيّم المورد هذا الحجز ${input.rating}/5.`,
          },
        };
    await notificationService.notify({
      userId: targetUserId,
      title: copy.title,
      body: copy.body,
      data: { bookingId: booking.id, type: 'REVIEW' },
    });
    return presented;
  },
};
