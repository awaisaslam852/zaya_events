import { z } from 'zod';
import { paginationQuerySchema } from '../../lib/common.js';

export const flightListQuery = paginationQuerySchema.extend({
  origin: z.string().optional(),
  destination: z.string().optional(),
  date: z.string().optional(),
});

export const flightIdParam = z.object({
  id: z.string().min(1),
});

export const flightBookingParam = z.object({
  id: z.string().uuid(),
});

export const flightBookSchema = z.object({
  eventId: z.string().uuid().optional(),
  passengers: z.number().int().positive().default(1),
});

export const flightCancelSchema = z.object({
  reason: z.string().max(500).optional(),
});
