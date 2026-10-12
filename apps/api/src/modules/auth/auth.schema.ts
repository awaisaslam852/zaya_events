import { z } from 'zod';
import { COUNTRY_CODES } from '../../lib/countries.js';

const localized = z.object({
  en: z.string().min(1),
  ar: z.string().min(1),
});

export const registerSchema = z
  .object({
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
    role: z.enum(['customer', 'vendor']),
    businessName: localized.optional(),
    description: localized.optional(),
    city: z.string().min(1).max(80).optional(),
    legalName: z.string().min(1).max(160).optional(),
    taxId: z.string().min(1).max(80).optional(),
    website: z
      .string()
      .optional()
      .transform((value) => {
        const trimmed = value?.trim();
        return trimmed ? trimmed : undefined;
      })
      .pipe(z.string().url().optional()),
  })
  .superRefine((value, ctx) => {
    if (value.role !== 'vendor') {
      return;
    }
    if (!value.businessName) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['businessName'],
        message: 'Vendor registration requires businessName.en and businessName.ar',
      });
    }
    if (!value.city) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ['city'], message: 'Vendor registration requires city' });
    }
    if (!value.legalName) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ['legalName'], message: 'Vendor registration requires legalName' });
    }
    if (!value.phone || value.phone.length < 8) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ['phone'], message: 'Vendor registration requires phone' });
    }
  });

export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(10),
});

export const logoutSchema = z
  .object({
    refreshToken: z.string().min(10).optional(),
  })
  .default({});

export const forgotPasswordSchema = z.object({
  email: z.string().email(),
});

export const resetPasswordSchema = z.object({
  token: z.string().min(10),
  password: z.string().min(8).max(72),
});

export const profilePatchSchema = z.object({
  firstName: z.string().min(1).max(80).optional(),
  lastName: z.string().min(1).max(80).optional(),
  phone: z.string().min(8).max(20).nullable().optional(),
  locale: z.enum(['en', 'ar']).optional(),
  country: z.enum(COUNTRY_CODES).nullable().optional(),
  avatarKey: z.string().min(1).optional(),
  displayName: z.string().min(1).max(120).optional(),
});

export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type RefreshInput = z.infer<typeof refreshSchema>;
export type LogoutInput = z.infer<typeof logoutSchema>;
export type ForgotPasswordInput = z.infer<typeof forgotPasswordSchema>;
export type ResetPasswordInput = z.infer<typeof resetPasswordSchema>;
export type ProfilePatchInput = z.infer<typeof profilePatchSchema>;
