import { AccommodationType, BookingType } from '@prisma/client';
import { z } from 'zod';
import { localizedString, paginationQuerySchema } from '../../lib/common.js';

export const accommodationListQuery = paginationQuerySchema.extend({
  city: z.string().optional(),
  type: z.nativeEnum(AccommodationType).optional(),
  minGuests: z.coerce.number().int().optional(),
  vendorId: z.string().uuid().optional(),
});

export const accommodationBody = z.object({
  name: localizedString,
  description: localizedString,
  type: z.nativeEnum(AccommodationType),
  address: localizedString,
  city: z.string(),
  country: z.string(),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
  maxGuests: z.number().int().positive(),
  bedrooms: z.number().int().nonnegative(),
  bathrooms: z.number().int().nonnegative(),
  nightlyRate: z.number().nonnegative(),
  currency: z.string().length(3).default('AED'),
  amenities: z.array(z.string()).default([]),
  coverKey: z.string().optional(),
  galleryKeys: z.array(z.string()).default([]),
  isPublished: z.boolean().default(true),
});

export const accommodationPatch = accommodationBody.partial();
export const accommodationBookSchema = z.object({
  eventId: z.string().uuid().optional(),
  startAt: z.coerce.date(),
  endAt: z.coerce.date(),
  guestCount: z.number().int().positive().optional(),
  notes: localizedString.optional(),
});
export { BookingType };
