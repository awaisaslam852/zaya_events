import { BookingStatus, BookingType } from '@prisma/client';
import { z } from 'zod';
import { localizedString, paginationQuerySchema } from '../../lib/common.js';

export const bookingListQuery = paginationQuerySchema.extend({
  status: z.nativeEnum(BookingStatus).optional(),
  type: z.nativeEnum(BookingType).optional(),
  customerId: z.string().uuid().optional(),
  vendorId: z.string().uuid().optional(),
  eventId: z.string().uuid().optional(),
  q: z.string().optional(),
});

export const bookingCreateSchema = z.object({
  type: z.nativeEnum(BookingType),
  eventId: z.string().uuid().optional(),
  venueId: z.string().uuid().optional(),
  venuePackageId: z.string().uuid().optional(),
  listingId: z.string().uuid().optional(),
  listingPackageId: z.string().uuid().optional(),
  carId: z.string().uuid().optional(),
  accommodationId: z.string().uuid().optional(),
  honeymoonId: z.string().uuid().optional(),
  startAt: z.coerce.date(),
  endAt: z.coerce.date().optional(),
  guestCount: z.number().int().positive().optional(),
  notes: localizedString.optional(),
});

export const bookingPatchSchema = z.object({
  startAt: z.coerce.date().optional(),
  endAt: z.coerce.date().optional(),
  guestCount: z.number().int().positive().optional(),
  notes: localizedString.optional(),
  eventId: z.string().uuid().nullable().optional(),
});

export const bookingTransitionSchema = z.preprocess(
  (value) => (value == null || value === '' ? {} : value),
  z.object({
    reason: z.string().max(500).optional(),
  }),
);

export const ALLOWED_TRANSITIONS: Record<BookingStatus, BookingStatus[]> = {
  DRAFT: [BookingStatus.PENDING, BookingStatus.INQUIRY, BookingStatus.CANCELLED],
  INQUIRY: [
    BookingStatus.PENDING,
    BookingStatus.UNDER_REVIEW,
    BookingStatus.CONFIRMED,
    BookingStatus.CANCELLED,
    BookingStatus.REJECTED,
  ],
  PENDING: [BookingStatus.UNDER_REVIEW, BookingStatus.CONFIRMED, BookingStatus.CANCELLED, BookingStatus.REJECTED],
  UNDER_REVIEW: [BookingStatus.CONFIRMED, BookingStatus.CANCELLED, BookingStatus.REJECTED],
  CONFIRMED: [BookingStatus.PAID, BookingStatus.COMPLETED, BookingStatus.CANCELLED],
  PAID: [BookingStatus.IN_PROGRESS, BookingStatus.COMPLETED, BookingStatus.CANCELLED],
  IN_PROGRESS: [BookingStatus.COMPLETED, BookingStatus.CANCELLED],
  COMPLETED: [],
  CANCELLED: [],
  REJECTED: [],
  REFUNDED: [],
};
