import { Prisma } from '@prisma/client';
import { crmRepository } from './crm.repository.js';
import type { z } from 'zod';
import type { crmFollowUpBody, crmFollowUpPatch, crmInteractionBody, crmNoteBody, crmSubjectQuery } from './crm.schema.js';

export const crmService = {
  async timeline(query: z.infer<typeof crmSubjectQuery>) {
    const [notes, interactions, followUps] = await Promise.all([
      crmRepository.notes(query.subjectType, query.subjectId),
      crmRepository.interactions(query.subjectType, query.subjectId),
      crmRepository.followUps(query.subjectType, query.subjectId),
    ]);
    const activity = [
      ...notes.map((item) => ({ kind: 'note' as const, at: item.createdAt, item })),
      ...interactions.map((item) => ({ kind: 'interaction' as const, at: item.createdAt, item })),
      ...followUps.map((item) => ({ kind: 'follow_up' as const, at: item.createdAt, item })),
    ].sort((a, b) => b.at.getTime() - a.at.getTime());
    return { notes, interactions, followUps, activity };
  },
  addNote(userId: string, input: z.infer<typeof crmNoteBody>) {
    return crmRepository.createNote({
      author: { connect: { id: userId } },
      subjectType: input.subjectType,
      subjectId: input.subjectId,
      body: input.body,
    });
  },
  addInteraction(userId: string, input: z.infer<typeof crmInteractionBody>) {
    return crmRepository.createInteraction({
      actor: { connect: { id: userId } },
      subjectType: input.subjectType,
      subjectId: input.subjectId,
      type: input.type,
      summary: input.summary,
      metadata: (input.metadata ?? undefined) as Prisma.InputJsonValue | undefined,
    });
  },
  addFollowUp(userId: string, input: z.infer<typeof crmFollowUpBody>) {
    return crmRepository.createFollowUp({
      owner: { connect: { id: userId } },
      subjectType: input.subjectType,
      subjectId: input.subjectId,
      dueAt: input.dueAt,
      summary: input.summary,
    });
  },
  updateFollowUp(id: string, input: z.infer<typeof crmFollowUpPatch>) {
    return crmRepository.updateFollowUp(id, input);
  },
};
