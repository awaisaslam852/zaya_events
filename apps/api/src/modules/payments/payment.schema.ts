import { PaymentKind } from '@prisma/client';
import { z } from 'zod';
import { paginationQuerySchema } from '../../lib/common.js';

export const paymentListQuery = paginationQuerySchema.extend({
  bookingId: z.string().uuid().optional(),
  q: z.string().optional(),
});

export const paymentCreateSchema = z.object({
  bookingId: z.string().uuid(),
  kind: z.nativeEnum(PaymentKind),
});

export const refundSchema = z.object({
  amount: z.number().positive().optional(),
});
