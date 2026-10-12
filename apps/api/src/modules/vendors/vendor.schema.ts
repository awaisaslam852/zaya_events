import { VendorStatus } from '@prisma/client';
import { z } from 'zod';
import { localizedString, paginationQuerySchema } from '../../lib/common.js';
import { COUNTRY_CODES } from '../../lib/countries.js';

export const vendorListQuery = paginationQuerySchema.extend({
  status: z.nativeEnum(VendorStatus).optional(),
  city: z.string().optional(),
  q: z.string().optional(),
});

export const vendorApplySchema = z.object({
  businessName: localizedString,
  description: localizedString,
  legalName: z.string().optional(),
  taxId: z.string().optional(),
  city: z.string().optional(),
  country: z.string().optional(),
  phone: z.string().optional(),
  website: z.string().url().optional(),
});

export const vendorProfilePatch = vendorApplySchema.partial().extend({
  firstName: z.string().min(1).max(80).optional(),
  lastName: z.string().min(1).max(80).optional(),
  coverKey: z.string().optional(),
  logoKey: z.string().optional(),
  galleryKeys: z.array(z.string()).optional(),
  serviceAreas: z.array(z.string()).optional(),
  notificationPrefs: z
    .object({
      email: z.boolean(),
      push: z.boolean(),
      whatsapp: z.boolean(),
    })
    .optional(),
  commissionRate: z.number().min(0).max(100).optional(),
  status: z.nativeEnum(VendorStatus).optional(),
});

export const vendorDecisionSchema = z.object({
  reason: z.string().max(500).optional(),
});

export const vendorAdminCreateSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(72),
  firstName: z.string().min(1).max(80),
  lastName: z.string().min(1).max(80),
  phone: z.string().min(8).max(20),
  country: z.enum(COUNTRY_CODES).default('AE'),
  locale: z.enum(['en', 'ar']).default('en'),
  city: z.string().min(1).max(80),
  legalName: z.string().min(1).max(160),
  taxId: z.string().max(80).optional(),
  website: z.string().url().optional().or(z.literal('')),
  businessName: localizedString,
  description: localizedString.optional(),
});
