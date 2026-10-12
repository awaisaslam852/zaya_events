import { z } from 'zod';
import { localizedString, paginationQuerySchema } from '../../lib/common.js';

export const venueListQuery = paginationQuerySchema.extend({
  city: z.string().optional(),
  minCapacity: z.coerce.number().int().optional(),
  maxCapacity: z.coerce.number().int().optional(),
  vendorId: z.string().uuid().optional(),
});

export const venueBody = z.object({
  name: localizedString,
  description: localizedString,
  address: localizedString,
  city: z.string(),
  country: z.string(),
  latitude: z.number(),
  longitude: z.number(),
  capacityMin: z.number().int().positive(),
  capacityMax: z.number().int().positive(),
  amenities: z.array(z.string()).default([]),
  coverKey: z.string().optional(),
  galleryKeys: z.array(z.string()).default([]),
  isPublished: z.boolean().default(true),
});

export const venuePatch = venueBody.partial();

export const venueInquirySchema = z.object({
  eventId: z.string().uuid().optional(),
  venuePackageId: z.string().uuid().optional(),
  startAt: z.coerce.date(),
  endAt: z.coerce.date().optional(),
  guestCount: z.number().int().positive().optional(),
  notes: localizedString.optional(),
});

export const venuePackageBody = z.object({
  name: localizedString,
  description: localizedString,
  priceAmount: z.number().nonnegative(),
  currency: z.string().length(3).default('AED'),
  guestCountMin: z.number().int().positive(),
  guestCountMax: z.number().int().positive(),
  durationHours: z.number().int().positive(),
});
