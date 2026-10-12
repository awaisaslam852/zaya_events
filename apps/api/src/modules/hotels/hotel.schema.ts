import { z } from 'zod';
import { paginationQuerySchema } from '../../lib/common.js';

export const hotelListQuery = paginationQuerySchema.extend({
  city: z.string().optional(),
  country: z.string().optional(),
  q: z.string().optional(),
  checkIn: z.string().optional(),
  checkOut: z.string().optional(),
});

export const hotelIdParam = z.object({
  id: z.string().min(1),
});

export const hotelBookingParam = z.object({
  id: z.string().uuid(),
});

export const hotelBookSchema = z.object({
  eventId: z.string().uuid().optional(),
  checkIn: z.coerce.date(),
  checkOut: z.coerce.date(),
  rooms: z.number().int().positive().default(1),
  guests: z.number().int().positive().default(2),
  roomId: z.string().optional(),
});

export const hotelCancelSchema = z.object({
  reason: z.string().max(500).optional(),
});
