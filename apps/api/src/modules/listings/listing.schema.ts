import { z } from 'zod';
import { localizedString, paginationQuerySchema } from '../../lib/common.js';

export const listingListQuery = paginationQuerySchema.extend({
  categoryId: z.string().uuid().optional(),
  vendorId: z.string().uuid().optional(),
  city: z.string().optional(),
  published: z.enum(['true', 'false']).optional(),
});

export const listingPackageBody = z.object({
  name: localizedString,
  description: localizedString,
  priceAmount: z.coerce.number().nonnegative(),
  currency: z.string().length(3).default('AED'),
  durationHours: z.coerce.number().int().positive().optional(),
  isActive: z.boolean().default(true),
});

export const listingBody = z.object({
  categoryId: z.string().uuid(),
  title: localizedString,
  description: localizedString,
  city: z.string().optional(),
  country: z.string().optional(),
  coverKey: z.string().optional(),
  galleryKeys: z.array(z.string()).optional().default([]),
  startingPrice: z.coerce.number().nonnegative(),
  currency: z.string().length(3).default('AED'),
  isPublished: z.boolean().default(true),
  customFieldValues: z.record(z.unknown()).optional().default({}),
  packages: z.array(listingPackageBody).optional().default([]),
});

export const listingPatch = listingBody.partial().omit({ packages: true });

export const listingPackageParams = z.object({
  id: z.string().uuid(),
  packageId: z.string().uuid(),
});
