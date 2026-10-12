import { z } from 'zod';
import { localizedString, paginationQuerySchema } from '../../lib/common.js';

export const eventListQuery = paginationQuerySchema.extend({
  status: z.string().optional(),
  categoryId: z.string().uuid().optional(),
  customerId: z.string().uuid().optional(),
});

const checklistItem = z.object({
  id: z.string().min(1),
  title: z.union([z.string().min(1), localizedString]),
  done: z.boolean().default(false),
});

export const eventBody = z.object({
  categoryId: z.string().uuid(),
  title: localizedString,
  description: localizedString.optional(),
  notes: localizedString.optional(),
  preferredVenueType: z.string().max(80).optional(),
  eventDate: z.coerce.date(),
  endDate: z.coerce.date().optional(),
  guestCount: z.number().int().positive().optional(),
  city: z.string().optional(),
  country: z.string().optional(),
  budgetMin: z.number().nonnegative().optional(),
  budgetMax: z.number().nonnegative().optional(),
  currency: z.string().length(3).default('AED'),
  status: z.string().default('planning'),
  checklist: z.array(checklistItem).optional(),
});

export const eventPatch = eventBody.partial();
