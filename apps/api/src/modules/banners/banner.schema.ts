import { BannerPlacement } from '@prisma/client';
import { z } from 'zod';
import { localizedString, paginationQuerySchema } from '../../lib/common.js';

export const bannerListQuery = paginationQuerySchema.extend({
  placement: z.nativeEnum(BannerPlacement).optional(),
});

export const bannerBody = z.object({
  title: localizedString,
  subtitle: localizedString.optional(),
  imageKey: z.string().min(1),
  linkUrl: z.string().url().optional(),
  placement: z.nativeEnum(BannerPlacement),
  sortOrder: z.number().int().default(0),
  isActive: z.boolean().default(true),
  startsAt: z.coerce.date().optional(),
  endsAt: z.coerce.date().optional(),
});

export const bannerPatch = bannerBody.partial();
