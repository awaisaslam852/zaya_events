import { BookingType } from '@prisma/client';
import { z } from 'zod';
import { localizedString, paginationQuerySchema } from '../../lib/common.js';

export const commissionListQuery = paginationQuerySchema.extend({
  vendorId: z.string().uuid().optional(),
});

export const commissionRateBody = z.object({
  name: localizedString,
  rate: z.number().min(0).max(100),
  bookingType: z.nativeEnum(BookingType).optional(),
  isDefault: z.boolean().default(false),
  isActive: z.boolean().default(true),
});
