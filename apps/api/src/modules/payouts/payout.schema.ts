import { PayoutStatus } from '@prisma/client';
import { z } from 'zod';
import { paginationQuerySchema } from '../../lib/common.js';

export const payoutListQuery = paginationQuerySchema.extend({
  vendorId: z.string().uuid().optional(),
  status: z.nativeEnum(PayoutStatus).optional(),
});

export const payoutCreateSchema = z.object({
  vendorId: z.string().uuid(),
  amount: z.number().positive(),
  currency: z.string().length(3).default('AED'),
});
