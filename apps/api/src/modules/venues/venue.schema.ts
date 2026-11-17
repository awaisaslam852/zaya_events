import { z } from 'zod';
import { localizedString, paginationQuerySchema } from '../../lib/common.js';

export const venueListQuery = paginationQuerySchema.extend({
  city: z.string().optional(),
  country: z.string().length(2).optional(),
  minCapacity: z.coerce.number().int().optional(),
  maxCapacity: z.coerce.number().int().optional(),
  vendorId: z.string().uuid().optional(),
});

export const venuePricingModel = z.enum(['HIRE', 'PER_GUEST', 'HYBRID']);
export const venuePackageUnit = z.enum(['EVENT', 'GUEST']);

export const venueBody = z.object({
  name: localizedString,
  description: localizedString,
  address: localizedString,
  city: z.string(),
  country: z.string().optional(),
  latitude: z.number(),
  longitude: z.number(),
  capacityMin: z.number().int().positive(),
  capacityMax: z.number().int().positive(),
  startingPrice: z.coerce.number().nonnegative().optional(),
  currency: z.string().length(3).optional(),
  pricingModel: venuePricingModel.optional(),
  amenities: z.array(z.string()).default([]),
  coverKey: z.string().nullish(),
  galleryKeys: z.array(z.string()).default([]),
  isPublished: z.boolean().default(true),
});

export const venuePatch = venueBody.partial();

export const venueInquirySchema = z.object({
  eventId: z.string().uuid().optional(),
  venuePackageId: z.string().uuid().optional(),
  startAt: z.coerce.date(),
  endAt: z.coerce.date().optional(),
  guestCount: z.number().int().positive().optional(),
  notes: localizedString.optional(),
});

export const venuePackageBody = z.object({
  name: localizedString,
  description: localizedString,
  priceAmount: z.coerce.number().nonnegative(),
  currency: z.string().length(3).optional(),
  guestCountMin: z.coerce.number().int().positive().optional().default(1),
  guestCountMax: z.coerce.number().int().positive().optional().default(500),
  durationHours: z.coerce.number().int().positive().optional().default(4),
  pricingUnit: venuePackageUnit.optional().default('EVENT'),
  isActive: z.boolean().optional().default(true),
});

export const venuePackagePatch = venuePackageBody.partial();

export const venuePackageParams = z.object({
  id: z.string().uuid(),
  packageId: z.string().uuid(),
});
