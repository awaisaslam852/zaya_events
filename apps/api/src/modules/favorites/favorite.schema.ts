import { FavoriteResourceType } from '@prisma/client';
import { z } from 'zod';
import { paginationQuerySchema } from '../../lib/common.js';

export const favoriteListQuery = paginationQuerySchema.extend({
  resourceType: z.nativeEnum(FavoriteResourceType).optional(),
});

export const favoriteBody = z.object({
  resourceType: z.nativeEnum(FavoriteResourceType),
  resourceId: z.string().min(1),
});
