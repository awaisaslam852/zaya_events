import { CrmSubjectType, Prisma } from '@prisma/client';
import { adminScope, assertCountryAllowed } from '../../lib/admin-scope.js';
import type { AuthUser } from '../../middleware/auth.js';
import { prisma } from '../../lib/prisma.js';
import { crmRepository } from './crm.repository.js';
import type { z } from 'zod';
import type { crmFollowUpBody, crmFollowUpPatch, crmInteractionBody, crmNoteBody, crmSubjectQuery } from './crm.schema.js';

async function subjectCountry(subjectType: CrmSubjectType, subjectId: string): Promise<string | null> {
  if (subjectType === CrmSubjectType.USER) {
    const row = await prisma.user.findFirst({ where: { id: subjectId, deletedAt: null }, select: { country: true } });
    return row?.country ?? null;
  }
  if (subjectType === CrmSubjectType.VENDOR) {
    const row = await prisma.vendor.findFirst({ where: { id: subjectId, deletedAt: null }, select: { country: true } });
    return row?.country ?? null;
  }
  if (subjectType === CrmSubjectType.BOOKING) {
    const row = await prisma.booking.findFirst({
      where: { id: subjectId, deletedAt: null },
      select: { vendor: { select: { country: true } }, customer: { select: { country: true } } },
    });
    return row?.vendor?.country ?? row?.customer?.country ?? null;
  }
  if (subjectType === CrmSubjectType.EVENT) {
    const row = await prisma.event.findFirst({
      where: { id: subjectId, deletedAt: null },
      select: { country: true, customer: { select: { country: true } } },
    });
    return row?.country ?? row?.customer?.country ?? null;
  }
  const row = await prisma.venue.findFirst({
    where: { id: subjectId, deletedAt: null },
    select: { country: true, vendor: { select: { country: true } } },
  });
  return row?.country ?? row?.vendor?.country ?? null;
}

async function assertSubjectAllowed(actor: AuthUser, subjectType: CrmSubjectType, subjectId: string): Promise<void> {
  const country = await subjectCountry(subjectType, subjectId);
  assertCountryAllowed(adminScope(actor), country);
}

export const crmService = {
  async timeline(query: z.infer<typeof crmSubjectQuery>, actor: AuthUser) {
    await assertSubjectAllowed(actor, query.subjectType, query.subjectId);
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
  async addNote(user: AuthUser, input: z.infer<typeof crmNoteBody>) {
    await assertSubjectAllowed(user, input.subjectType, input.subjectId);
    return crmRepository.createNote({
      author: { connect: { id: user.id } },
      subjectType: input.subjectType,
      subjectId: input.subjectId,
      body: input.body,
    });
  },
  async addInteraction(user: AuthUser, input: z.infer<typeof crmInteractionBody>) {
    await assertSubjectAllowed(user, input.subjectType, input.subjectId);
    return crmRepository.createInteraction({
      actor: { connect: { id: user.id } },
      subjectType: input.subjectType,
      subjectId: input.subjectId,
      type: input.type,
      summary: input.summary,
      metadata: (input.metadata ?? undefined) as Prisma.InputJsonValue | undefined,
    });
  },
  async addFollowUp(user: AuthUser, input: z.infer<typeof crmFollowUpBody>) {
    await assertSubjectAllowed(user, input.subjectType, input.subjectId);
    return crmRepository.createFollowUp({
      owner: { connect: { id: user.id } },
      subjectType: input.subjectType,
      subjectId: input.subjectId,
      dueAt: input.dueAt,
      summary: input.summary,
    });
  },
  async updateFollowUp(id: string, input: z.infer<typeof crmFollowUpPatch>, actor: AuthUser) {
    const row = await prisma.crmFollowUp.findFirst({ where: { id, deletedAt: null } });
    if (row) {
      await assertSubjectAllowed(actor, row.subjectType, row.subjectId);
    }
    return crmRepository.updateFollowUp(id, input);
  },
};
