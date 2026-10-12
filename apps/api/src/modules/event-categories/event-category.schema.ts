import { z } from 'zod';
import { localizedString, paginationQuerySchema } from '../../lib/common.js';

const customField = z.object({
  key: z.string().min(1).max(60),
  label: localizedString,
  type: z.enum(['text', 'number', 'select', 'boolean']),
  required: z.boolean().default(false),
  options: z.array(localizedString).optional(),
});

export const eventCategoryListQuery = paginationQuerySchema.extend({
  includeInactive: z.enum(['true', 'false']).optional(),
  q: z.string().optional(),
});

export const eventCategoryBody = z.object({
  slug: z.string().min(2).max(80).regex(/^[a-z0-9-]+$/),
  name: localizedString,
  description: localizedString,
  icon: z.string().max(40).optional(),
  sortOrder: z.number().int().default(0),
  isActive: z.boolean().default(true),
  customFields: z.array(customField).default([]),
});

export const eventCategoryPatch = eventCategoryBody.partial();
