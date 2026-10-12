import { CrmFollowUpStatus, CrmInteractionType, CrmSubjectType } from '@prisma/client';
import { z } from 'zod';
import { paginationQuerySchema } from '../../lib/common.js';

export const crmSubjectQuery = paginationQuerySchema.extend({
  subjectType: z.nativeEnum(CrmSubjectType),
  subjectId: z.string().uuid(),
});

export const crmNoteBody = z.object({
  subjectType: z.nativeEnum(CrmSubjectType),
  subjectId: z.string().uuid(),
  body: z.string().min(1).max(5000),
});

export const crmInteractionBody = z.object({
  subjectType: z.nativeEnum(CrmSubjectType),
  subjectId: z.string().uuid(),
  type: z.nativeEnum(CrmInteractionType),
  summary: z.string().min(1).max(500),
  metadata: z.record(z.unknown()).optional(),
});

export const crmFollowUpBody = z.object({
  subjectType: z.nativeEnum(CrmSubjectType),
  subjectId: z.string().uuid(),
  dueAt: z.coerce.date(),
  summary: z.string().min(1).max(500),
});

export const crmFollowUpPatch = z.object({
  status: z.nativeEnum(CrmFollowUpStatus),
});
