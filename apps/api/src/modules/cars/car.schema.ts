import { BookingType, CarTransmission } from '@prisma/client';
import { z } from 'zod';
import { localizedString, paginationQuerySchema } from '../../lib/common.js';

export const carListQuery = paginationQuerySchema.extend({
  city: z.string().optional(),
  seats: z.coerce.number().int().optional(),
  q: z.string().optional(),
  vendorId: z.string().uuid().optional(),
});

export const carBody = z.object({
  name: localizedString,
  description: localizedString,
  make: z.string(),
  model: z.string(),
  year: z.coerce.number().int(),
  seats: z.coerce.number().int().positive(),
  transmission: z.nativeEnum(CarTransmission),
  color: z.string().optional(),
  plateNumber: z.string().optional(),
  dailyRate: z.coerce.number().nonnegative(),
  currency: z.string().length(3).default('AED'),
  coverKey: z.string().optional(),
  galleryKeys: z.array(z.string()).optional().default([]),
  isPublished: z.boolean().default(true),
});

export const carPatch = carBody.partial();
export const carBookSchema = z.object({
  eventId: z.string().uuid().optional(),
  startAt: z.coerce.date(),
  endAt: z.coerce.date(),
  notes: localizedString.optional(),
});
export { BookingType };
