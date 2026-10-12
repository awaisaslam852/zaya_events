import { Role, UserStatus } from '@prisma/client';
import { z } from 'zod';
import { paginationQuerySchema } from '../../lib/common.js';
import { COUNTRY_CODES } from '../../lib/countries.js';

export const customerListQuery = paginationQuerySchema.extend({
  q: z.string().optional(),
  status: z.nativeEnum(UserStatus).optional(),
});

export const customerPatchSchema = z.object({
  firstName: z.string().min(1).max(80).optional(),
  lastName: z.string().min(1).max(80).optional(),
  phone: z
    .string()
    .max(20)
    .nullable()
    .optional()
    .transform((value) => {
      if (value === undefined) {
        return undefined;
      }
      const trimmed = value?.trim();
      return trimmed ? trimmed : null;
    }),
  country: z.enum(COUNTRY_CODES).nullable().optional(),
  locale: z.enum(['en', 'ar']).optional(),
  avatarKey: z.string().min(1).optional(),
  status: z.nativeEnum(UserStatus).optional(),
  password: z.string().min(8).max(72).optional(),
});

export const customerCreateSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(72),
  firstName: z.string().min(1).max(80),
  lastName: z.string().min(1).max(80),
  phone: z
    .string()
    .max(20)
    .optional()
    .transform((value) => {
      const trimmed = value?.trim();
      return trimmed ? trimmed : undefined;
    }),
  country: z.enum(COUNTRY_CODES).default('AE'),
  locale: z.enum(['en', 'ar']).default('en'),
});

export { Role };
