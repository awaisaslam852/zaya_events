import { BookingType } from '@prisma/client';
import { z } from 'zod';
import { localizedString, paginationQuerySchema } from '../../lib/common.js';

export const cartListQuery = paginationQuerySchema;

export const cartAddSchema = z.object({
  type: z.nativeEnum(BookingType),
  resourceId: z.string().min(1),
  startAt: z.coerce.date(),
  endAt: z.coerce.date().optional(),
  guestCount: z.number().int().positive().optional(),
  notes: localizedString.optional(),
});

export const cartCheckoutSchema = z.object({
  eventId: z.string().uuid().optional(),
});
