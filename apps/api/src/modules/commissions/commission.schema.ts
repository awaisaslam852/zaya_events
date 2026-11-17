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

export const countryCodeParam = z.object({
  country: z
    .string()
    .length(2)
    .transform((value) => value.toUpperCase()),
});

export const commissionPolicyPatch = z
  .object({
    hqShareRate: z.number().min(0).max(100).optional(),
    defaultVendorRate: z.number().min(0).max(100).optional(),
  })
  .refine((value) => value.hqShareRate !== undefined || value.defaultVendorRate !== undefined, {
    message: 'Provide hqShareRate or defaultVendorRate',
  });
