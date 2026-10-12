import { VenueVisitStatus } from '@prisma/client';
import { z } from 'zod';
import { localizedString, paginationQuerySchema } from '../../lib/common.js';

export const visitListQuery = paginationQuerySchema.extend({
  status: z.nativeEnum(VenueVisitStatus).optional(),
  venueId: z.string().uuid().optional(),
  q: z.string().optional(),
});

export const visitRequestSchema = z.object({
  venueId: z.string().uuid(),
  eventId: z.string().uuid().optional(),
  scheduledAt: z.coerce.date(),
  notes: localizedString.optional(),
});

export const visitRescheduleSchema = z.object({
  scheduledAt: z.coerce.date(),
  notes: localizedString.optional(),
});

export const visitAssignSchema = z.object({
  representativeId: z.string().uuid(),
});

export const visitNotesSchema = z.object({
  notes: localizedString,
});

export const visitDecisionSchema = z.object({
  accepted: z.boolean(),
  notes: localizedString.optional(),
});
