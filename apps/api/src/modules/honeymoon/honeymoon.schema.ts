import { BookingType } from '@prisma/client';
import { z } from 'zod';
import { localizedString, paginationQuerySchema } from '../../lib/common.js';

export const honeymoonListQuery = paginationQuerySchema.extend({
  q: z.string().optional(),
});

export const honeymoonBody = z.object({
  name: localizedString,
  description: localizedString,
  destination: localizedString,
  nights: z.number().int().positive(),
  priceAmount: z.number().nonnegative(),
  currency: z.string().length(3).default('AED'),
  coverKey: z.string().optional(),
  galleryKeys: z.array(z.string()).default([]),
  inclusions: z.array(z.string()).default([]),
  isPublished: z.boolean().default(true),
});

export const honeymoonPatch = honeymoonBody.partial();
export const honeymoonInquirySchema = z.object({
  eventId: z.string().uuid().optional(),
  startAt: z.coerce.date(),
  endAt: z.coerce.date().optional(),
  notes: localizedString.optional(),
});
export { BookingType };
