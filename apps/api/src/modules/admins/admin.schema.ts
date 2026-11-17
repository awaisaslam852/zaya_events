import { UserStatus } from '@prisma/client';
import { z } from 'zod';
import { COUNTRY_CODES } from '../../lib/countries.js';
import { paginationQuerySchema } from '../../lib/common.js';

export const adminListQuery = paginationQuerySchema.extend({
  q: z.string().optional(),
});

export const adminCreateSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(72).optional(),
  firstName: z.string().min(1).max(80),
  lastName: z.string().min(1).max(80),
  phone: z.string().max(32).optional(),
  allowedCountries: z.array(z.enum(COUNTRY_CODES)).min(1),
});

export const adminPatchSchema = z.object({
  firstName: z.string().min(1).max(80).optional(),
  lastName: z.string().min(1).max(80).optional(),
  phone: z.string().max(32).nullable().optional(),
  password: z.string().min(8).max(72).optional(),
  status: z.nativeEnum(UserStatus).optional(),
  allowedCountries: z.array(z.enum(COUNTRY_CODES)).min(1).optional(),
});
