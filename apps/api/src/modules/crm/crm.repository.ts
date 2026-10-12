import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const crmRepository = {
  notes(subjectType: Prisma.CrmNoteWhereInput['subjectType'], subjectId: string) {
    return prisma.crmNote.findMany({
      where: { subjectType, subjectId, ...notDeleted },
      orderBy: { createdAt: 'desc' },
    });
  },
  interactions(subjectType: Prisma.CrmInteractionWhereInput['subjectType'], subjectId: string) {
    return prisma.crmInteraction.findMany({
      where: { subjectType, subjectId, ...notDeleted },
      orderBy: { createdAt: 'desc' },
    });
  },
  followUps(subjectType: Prisma.CrmFollowUpWhereInput['subjectType'], subjectId: string) {
    return prisma.crmFollowUp.findMany({
      where: { subjectType, subjectId, ...notDeleted },
      orderBy: { dueAt: 'asc' },
    });
  },
  createNote(data: Prisma.CrmNoteCreateInput) {
    return prisma.crmNote.create({ data });
  },
  createInteraction(data: Prisma.CrmInteractionCreateInput) {
    return prisma.crmInteraction.create({ data });
  },
  createFollowUp(data: Prisma.CrmFollowUpCreateInput) {
    return prisma.crmFollowUp.create({ data });
  },
  updateFollowUp(id: string, data: Prisma.CrmFollowUpUpdateInput) {
    return prisma.crmFollowUp.update({ where: { id }, data });
  },
};
