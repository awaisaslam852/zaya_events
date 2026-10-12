import { z } from 'zod';
import { paginationQuerySchema } from '../../lib/common.js';

export const callInitiateSchema = z.object({
  calleeId: z.string().uuid(),
  bookingId: z.string().uuid().optional(),
});

export const callHistoryQuery = paginationQuerySchema.extend({
  q: z.string().optional(),
});
