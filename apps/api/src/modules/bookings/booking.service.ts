import {
  AvailabilityResourceType,
  BookingStatus,
  BookingType,
  CommissionStatus,
  Role,
  type Prisma,
} from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';
import { randomInt } from 'node:crypto';
import { writeAdminAudit } from '../../lib/admin-audit.js';
import { adminScope, assertCountryAllowed, viaVendorCountry } from '../../lib/admin-scope.js';
import { splitCommission } from '../../lib/commission-split.js';
import { currencyForCountry } from '../../lib/countries.js';
import type { AuthUser } from '../../middleware/auth.js';
import { AppError, ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { notDeleted, paginated, skipTake } from '../../lib/common.js';
import { prisma } from '../../lib/prisma.js';
import { commissionService } from '../commissions/commission.service.js';
import { availabilityService } from '../availability/availability.service.js';
import { notificationService } from '../notifications/notification.service.js';
import { quoteVenueAmount } from '../../lib/venue-pricing.js';
import { reviewStateFor } from '../reviews/review.service.js';
import { bookingRepository } from './booking.repository.js';
import {
  ALLOWED_TRANSITIONS,
  type bookingCreateSchema,
  type bookingListQuery,
  type bookingPatchSchema,
} from './booking.schema.js';
import type { z } from 'zod';

function bookingNumber(): string {
  return `ZY-${new Date().getFullYear()}-${randomInt(100000, 999999)}`;
}

async function resolveResource(input: z.infer<typeof bookingCreateSchema>) {
  if (input.type === BookingType.VENUE && input.venueId) {
    const venue = await prisma.venue.findFirst({
      where: { id: input.venueId, ...notDeleted },
      include: { packages: true },
    });
    if (!venue) {
      throw new NotFoundError('Venue not found');
    }
    const amount = quoteVenueAmount({
      startingPrice: venue.startingPrice,
      pricingModel: venue.pricingModel,
      capacityMin: venue.capacityMin,
      packages: venue.packages,
      packageId: input.venuePackageId,
      guestCount: input.guestCount,
    });
    return {
      vendorId: venue.vendorId,
      amount,
      resourceType: AvailabilityResourceType.VENUE,
      resourceId: venue.id,
    };
  }
  if (input.type === BookingType.LISTING && input.listingId) {
    const listing = await prisma.listing.findFirst({
      where: { id: input.listingId, ...notDeleted },
      include: { packages: true },
    });
    if (!listing) {
      throw new NotFoundError('Listing not found');
    }
    const pkg = input.listingPackageId
      ? listing.packages.find((item) => item.id === input.listingPackageId)
      : undefined;
    return {
      vendorId: listing.vendorId,
      amount: Number(pkg?.priceAmount ?? listing.startingPrice),
      resourceType: AvailabilityResourceType.LISTING,
      resourceId: listing.id,
    };
  }
  if (input.type === BookingType.CAR && input.carId) {
    const car = await prisma.car.findFirst({ where: { id: input.carId, ...notDeleted } });
    if (!car) {
      throw new NotFoundError('Car not found');
    }
    const days = Math.max(
      1,
      Math.ceil(((input.endAt ?? input.startAt).getTime() - input.startAt.getTime()) / 86400000),
    );
    return {
      vendorId: car.vendorId,
      amount: Number(car.dailyRate) * days,
      resourceType: AvailabilityResourceType.CAR,
      resourceId: car.id,
    };
  }
  if (input.type === BookingType.ACCOMMODATION && input.accommodationId) {
    const stay = await prisma.accommodation.findFirst({
      where: { id: input.accommodationId, ...notDeleted },
    });
    if (!stay) {
      throw new NotFoundError('Accommodation not found');
    }
    const nights = Math.max(
      1,
      Math.ceil(((input.endAt ?? input.startAt).getTime() - input.startAt.getTime()) / 86400000),
    );
    return {
      vendorId: stay.vendorId,
      amount: Number(stay.nightlyRate) * nights,
      resourceType: AvailabilityResourceType.ACCOMMODATION,
      resourceId: stay.id,
    };
  }
  if (input.type === BookingType.HONEYMOON && input.honeymoonId) {
    const pack = await prisma.honeymoonPackage.findFirst({
      where: { id: input.honeymoonId, ...notDeleted },
    });
    if (!pack) {
      throw new NotFoundError('Honeymoon package not found');
    }
    return {
      vendorId: pack.vendorId,
      amount: Number(pack.priceAmount),
      resourceType: AvailabilityResourceType.HONEYMOON,
      resourceId: pack.id,
    };
  }
  throw new AppError(422, 'INVALID_BOOKING', 'Booking type does not match resource ids');
}

function redactVendorFinance<T extends object>(row: T): T {
  const copy = { ...row } as T & { commissionAmount?: unknown; commissions?: unknown };
  delete copy.commissionAmount;
  delete copy.commissions;
  return copy;
}

function bookingStatusCopy(status: BookingStatus, bookingNumber: string) {
  switch (status) {
    case BookingStatus.CONFIRMED:
      return {
        title: { en: 'Booking accepted', ar: 'تم قبول الحجز' },
        body: {
          en: `Booking ${bookingNumber} was accepted.`,
          ar: `تم قبول الحجز ${bookingNumber}.`,
        },
      };
    case BookingStatus.REJECTED:
      return {
        title: { en: 'Booking declined', ar: 'تم رفض الحجز' },
        body: {
          en: `Booking ${bookingNumber} was declined.`,
          ar: `تم رفض الحجز ${bookingNumber}.`,
        },
      };
    case BookingStatus.CANCELLED:
      return {
        title: { en: 'Booking cancelled', ar: 'تم إلغاء الحجز' },
        body: {
          en: `Booking ${bookingNumber} was cancelled.`,
          ar: `تم إلغاء الحجز ${bookingNumber}.`,
        },
      };
    case BookingStatus.UNDER_REVIEW:
      return {
        title: { en: 'Booking under review', ar: 'الحجز قيد المراجعة' },
        body: {
          en: `Booking ${bookingNumber} is being reviewed.`,
          ar: `الحجز ${bookingNumber} قيد المراجعة.`,
        },
      };
    case BookingStatus.COMPLETED:
      return {
        title: { en: 'Booking completed', ar: 'اكتمل الحجز' },
        body: {
          en: `Booking ${bookingNumber} is completed.`,
          ar: `اكتمل الحجز ${bookingNumber}.`,
        },
      };
    case BookingStatus.PAID:
      return {
        title: { en: 'Booking paid', ar: 'تم دفع الحجز' },
        body: {
          en: `Payment was received for booking ${bookingNumber}.`,
          ar: `تم استلام الدفع للحجز ${bookingNumber}.`,
        },
      };
    default:
      return {
        title: { en: `Booking ${status.toLowerCase()}`, ar: `الحجز ${status}` },
        body: {
          en: `Booking ${bookingNumber} is now ${status.toLowerCase()}.`,
          ar: `أصبح الحجز ${bookingNumber} في حالة ${status}.`,
        },
      };
  }
}

function canView(
  role: Role,
  userId: string,
  booking: { customerId: string; vendor: { userId: string; country?: string | null } | null },
  actor?: AuthUser,
): boolean {
  if (role === Role.ADMIN) {
    try {
      assertCountryAllowed(adminScope(actor), booking.vendor?.country ?? null);
      return true;
    } catch {
      return false;
    }
  }
  if (booking.customerId === userId) {
    return true;
  }
  return booking.vendor?.userId === userId;
}

export const bookingService = {
  async list(userId: string, role: Role, query: z.infer<typeof bookingListQuery>, actor?: AuthUser) {
    const { skip, take } = skipTake(query);
    const where: Prisma.BookingWhereInput = {
      ...notDeleted,
      ...(query.status ? { status: query.status } : {}),
      ...(query.type ? { type: query.type } : {}),
      ...(query.eventId ? { eventId: query.eventId } : {}),
      ...(role === Role.ADMIN
        ? {
            ...viaVendorCountry(adminScope(actor)),
            ...(query.customerId ? { customerId: query.customerId } : {}),
            ...(query.vendorId ? { vendorId: query.vendorId } : {}),
            ...(query.q ? { bookingNumber: { contains: query.q, mode: 'insensitive' as const } } : {}),
          }
        : role === Role.VENDOR
          ? { vendor: { userId } }
          : { customerId: userId }),
    };
    const [items, total] = await bookingRepository.list(where, skip, take);
    return paginated(
      role === Role.ADMIN ? items : items.map((item) => redactVendorFinance(item)),
      total,
      query,
    );
  },

  async get(userId: string, role: Role, id: string, actor?: AuthUser) {
    const booking = await bookingRepository.findById(id);
    if (!booking) {
      throw new NotFoundError('Booking not found');
    }
    if (!canView(role, userId, booking, actor)) {
      throw new ForbiddenError();
    }
    const reviewState = reviewStateFor(role, userId, booking);
    const payload = { ...booking, reviewState };
    return role === Role.ADMIN ? payload : redactVendorFinance(payload);
  },

  async create(userId: string, input: z.infer<typeof bookingCreateSchema>, asInquiry = false) {
    const resolved = await resolveResource(input);
    const endAt = input.endAt ?? new Date(input.startAt.getTime() + 4 * 3600000);
    await availabilityService.assertNoOverlap({
      resourceType: resolved.resourceType,
      resourceId: resolved.resourceId,
      startAt: input.startAt,
      endAt,
    });
    const vendor = resolved.vendorId
      ? await prisma.vendor.findFirst({ where: { id: resolved.vendorId, ...notDeleted } })
      : null;
    const policy = await commissionService.resolvePolicy(vendor?.country);
    const subtotal = resolved.amount;
    const split = splitCommission({
      bookingAmount: subtotal,
      vendorRate: Number(vendor?.commissionRate ?? policy.defaultVendorRate),
      hqShareRate: policy.hqShareRate,
    });
    const deposit = Math.round(subtotal * 0.3 * 100) / 100;
    const status = asInquiry ? BookingStatus.INQUIRY : BookingStatus.PENDING;
    const booking = await prisma.$transaction(async (tx) => {
      const created = await tx.booking.create({
        data: {
          bookingNumber: bookingNumber(),
          type: input.type,
          status,
          customer: { connect: { id: userId } },
          ...(vendor ? { vendor: { connect: { id: vendor.id } } } : {}),
          ...(input.eventId ? { event: { connect: { id: input.eventId } } } : {}),
          ...(input.venueId ? { venue: { connect: { id: input.venueId } } } : {}),
          ...(input.venuePackageId ? { venuePackage: { connect: { id: input.venuePackageId } } } : {}),
          ...(input.listingId ? { listing: { connect: { id: input.listingId } } } : {}),
          ...(input.listingPackageId ? { listingPackage: { connect: { id: input.listingPackageId } } } : {}),
          ...(input.carId ? { car: { connect: { id: input.carId } } } : {}),
          ...(input.accommodationId ? { accommodation: { connect: { id: input.accommodationId } } } : {}),
          ...(input.honeymoonId ? { honeymoon: { connect: { id: input.honeymoonId } } } : {}),
          startAt: input.startAt,
          endAt,
          guestCount: input.guestCount,
          currency: currencyForCountry(vendor?.country),
          subtotalAmount: new Decimal(subtotal),
          commissionAmount: new Decimal(split.amount),
          depositAmount: new Decimal(deposit),
          balanceAmount: new Decimal(Math.round((subtotal - deposit) * 100) / 100),
          totalAmount: new Decimal(subtotal),
          notes: input.notes,
          statusHistory: {
            create: { toStatus: status, actorId: userId, reason: asInquiry ? 'inquiry' : 'created' },
          },
        },
      });
      await tx.availability.create({
        data: {
          resourceType: resolved.resourceType,
          resourceId: resolved.resourceId,
          startAt: input.startAt,
          endAt,
          status: 'RESERVED',
          isBlocked: true,
          source: 'internal',
          bookingId: created.id,
        },
      });
      return created;
    });
    if (vendor) {
      await notificationService.notify({
        userId: vendor.userId,
        title: asInquiry
          ? { en: 'New inquiry', ar: 'استفسار جديد' }
          : { en: 'New booking', ar: 'حجز جديد' },
        body: {
          en: asInquiry
            ? `Inquiry ${booking.bookingNumber} is waiting for your reply.`
            : `Booking ${booking.bookingNumber} is awaiting review.`,
          ar: asInquiry
            ? `الاستفسار ${booking.bookingNumber} بانتظار ردك.`
            : `الحجز ${booking.bookingNumber} بانتظار المراجعة.`,
        },
        data: { type: asInquiry ? 'booking_inquiry' : 'booking_created', bookingId: booking.id },
      });
    }
    return bookingRepository.findById(booking.id);
  },

  async transition(
    userId: string,
    role: Role,
    id: string,
    toStatus: BookingStatus,
    reason?: string,
    actor?: AuthUser,
  ) {
    const booking = await bookingRepository.findById(id);
    if (!booking) {
      throw new NotFoundError('Booking not found');
    }
    if (!canView(role, userId, booking, actor)) {
      throw new ForbiddenError();
    }
    const allowed = ALLOWED_TRANSITIONS[booking.status] ?? [];
    if (!allowed.includes(toStatus)) {
      throw new AppError(422, 'INVALID_TRANSITION', `Cannot move from ${booking.status} to ${toStatus}`);
    }
    if (role === Role.CUSTOMER && toStatus !== BookingStatus.CANCELLED) {
      throw new ForbiddenError();
    }
    const policy = await commissionService.resolvePolicy(booking.vendor?.country);
    const split = splitCommission({
      bookingAmount: Number(booking.subtotalAmount),
      vendorRate: Number(booking.vendor?.commissionRate ?? policy.defaultVendorRate),
      hqShareRate: policy.hqShareRate,
    });
    const updated = await prisma.$transaction(async (tx) => {
      const row = await tx.booking.update({
        where: { id },
        data: {
          status: toStatus,
          ...(toStatus === BookingStatus.CONFIRMED ? { commissionAmount: new Decimal(split.amount) } : {}),
        },
      });
      await tx.bookingStatusHistory.create({
        data: {
          bookingId: id,
          fromStatus: booking.status,
          toStatus,
          actorId: userId,
          reason,
        },
      });
      if (toStatus === BookingStatus.CONFIRMED && booking.vendorId) {
        const existing = await tx.commission.findFirst({ where: { bookingId: id, deletedAt: null } });
        if (!existing) {
          await tx.commission.create({
            data: {
              bookingId: id,
              vendorId: booking.vendorId,
              country: booking.vendor?.country ?? policy.country,
              rate: split.vendorRate,
              amount: split.amount,
              hqRate: split.hqShareRate,
              hqAmount: split.hqAmount,
              deskAmount: split.deskAmount,
              currency: booking.currency,
              status: CommissionStatus.ACCRUED,
            },
          });
        }
      }
      if (toStatus === BookingStatus.CANCELLED || toStatus === BookingStatus.REJECTED) {
        await tx.availability.updateMany({
          where: { bookingId: id, deletedAt: null },
          data: { deletedAt: new Date(), status: 'AVAILABLE', isBlocked: false },
        });
      }
      return row;
    });
    const copy = bookingStatusCopy(toStatus, booking.bookingNumber);
    const notifyIds = [booking.customerId, booking.vendor?.userId].filter(
      (value): value is string => Boolean(value) && value !== userId,
    );
    await Promise.all(
      notifyIds.map((target) =>
        notificationService.notify({
          userId: target,
          title: copy.title,
          body: copy.body,
          data: { type: 'booking_status', bookingId: id, status: toStatus },
        }),
      ),
    );
    if (actor?.role === Role.ADMIN) {
      await writeAdminAudit({
        actorId: actor.id,
        action: `booking.${toStatus.toLowerCase()}`,
        entityType: 'Booking',
        entityId: id,
        country: booking.vendor?.country ?? null,
        meta: { from: booking.status, to: toStatus, bookingNumber: booking.bookingNumber },
      });
    }
    return updated;
  },

  async modify(userId: string, role: Role, id: string, input: z.infer<typeof bookingPatchSchema>, actor?: AuthUser) {
    const booking = await bookingRepository.findById(id);
    if (!booking) {
      throw new NotFoundError('Booking not found');
    }
    if (!canView(role, userId, booking, actor)) {
      throw new ForbiddenError();
    }
    const editable: BookingStatus[] = [BookingStatus.INQUIRY, BookingStatus.PENDING, BookingStatus.UNDER_REVIEW];
    if (role === Role.CUSTOMER && !editable.includes(booking.status)) {
      throw new ForbiddenError();
    }
    const locked: BookingStatus[] = [
      BookingStatus.COMPLETED,
      BookingStatus.CANCELLED,
      BookingStatus.REJECTED,
      BookingStatus.REFUNDED,
    ];
    if (locked.includes(booking.status)) {
      throw new AppError(422, 'INVALID_TRANSITION', 'This booking can no longer be modified');
    }
    const startAt = input.startAt ?? booking.startAt;
    const endAt = input.endAt ?? booking.endAt ?? new Date(startAt.getTime() + 4 * 3600000);
    const resourceType =
      booking.type === BookingType.VENUE
        ? AvailabilityResourceType.VENUE
        : booking.type === BookingType.LISTING
          ? AvailabilityResourceType.LISTING
          : booking.type === BookingType.CAR
            ? AvailabilityResourceType.CAR
            : booking.type === BookingType.ACCOMMODATION
              ? AvailabilityResourceType.ACCOMMODATION
              : booking.type === BookingType.HONEYMOON
                ? AvailabilityResourceType.HONEYMOON
                : null;
    const resourceId = booking.venueId ?? booking.listingId ?? booking.carId ?? booking.accommodationId ?? booking.honeymoonId;
    if (resourceType && resourceId && (input.startAt || input.endAt)) {
      await prisma.availability.updateMany({
        where: { bookingId: id, deletedAt: null },
        data: { deletedAt: new Date(), isBlocked: false, status: 'AVAILABLE' },
      });
      await availabilityService.assertNoOverlap({ resourceType, resourceId, startAt, endAt });
      await prisma.availability.create({
        data: {
          resourceType,
          resourceId,
          startAt,
          endAt,
          status: 'RESERVED',
          isBlocked: true,
          source: 'internal',
          bookingId: id,
        },
      });
    }
    await prisma.booking.update({
      where: { id },
      data: {
        startAt,
        endAt,
        ...(input.guestCount !== undefined ? { guestCount: input.guestCount } : {}),
        ...(input.notes !== undefined ? { notes: input.notes } : {}),
        ...(input.eventId === null ? { event: { disconnect: true } } : input.eventId ? { event: { connect: { id: input.eventId } } } : {}),
      },
    });
    const otherId = userId === booking.customerId ? booking.vendor?.userId : booking.customerId;
    if (otherId) {
      await notificationService.notify({
        userId: otherId,
        title: { en: 'Booking updated', ar: 'تم تحديث الحجز' },
        body: {
          en: `Booking ${booking.bookingNumber} was updated.`,
          ar: `تم تحديث الحجز ${booking.bookingNumber}.`,
        },
        data: { type: 'booking_updated', bookingId: id },
      });
    }
    return this.get(userId, role, id, actor);
  },
};
