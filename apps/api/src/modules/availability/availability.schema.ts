import { AvailabilityResourceType, AvailabilitySlotStatus } from '@prisma/client';
import { z } from 'zod';
import { paginationQuerySchema } from '../../lib/common.js';

export const resourceTypeSchema = z.nativeEnum(AvailabilityResourceType);

export const availabilityListQuery = paginationQuerySchema.extend({
  resourceType: resourceTypeSchema,
  resourceId: z.string().uuid(),
  from: z.coerce.date().optional(),
  to: z.coerce.date().optional(),
});

export const availabilityUpsertSchema = z.object({
  resourceType: resourceTypeSchema,
  resourceId: z.string().uuid(),
  startAt: z.coerce.date(),
  endAt: z.coerce.date(),
  status: z.nativeEnum(AvailabilitySlotStatus).default(AvailabilitySlotStatus.UNAVAILABLE),
  isBlocked: z.boolean().default(false),
  source: z.enum(['internal', 'external']).default('internal'),
  notes: z.string().max(500).optional(),
  priceOverride: z.number().nonnegative().optional(),
});
