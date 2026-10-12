import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const chatRepository = {
  listConversations(userId: string, skip: number, take: number) {
    const where: Prisma.ConversationWhereInput = {
      ...notDeleted,
      OR: [{ participantAId: userId }, { participantBId: userId }],
    };
    return prisma.$transaction([
      prisma.conversation.findMany({
        where,
        include: {
          participantA: { select: { id: true, firstName: true, lastName: true, avatarKey: true, role: true } },
          participantB: { select: { id: true, firstName: true, lastName: true, avatarKey: true, role: true } },
          messages: { orderBy: { createdAt: 'desc' }, take: 1 },
        },
        orderBy: { lastMessageAt: 'desc' },
        skip,
        take,
      }),
      prisma.conversation.count({ where }),
    ]);
  },
  findConversation(id: string) {
    return prisma.conversation.findFirst({
      where: { id, ...notDeleted },
      include: {
        participantA: { select: { id: true, firstName: true, lastName: true, role: true } },
        participantB: { select: { id: true, firstName: true, lastName: true, role: true } },
      },
    });
  },
  findPair(a: string, b: string, bookingId?: string) {
    return prisma.conversation.findFirst({
      where: {
        ...notDeleted,
        bookingId: bookingId ?? null,
        OR: [
          { participantAId: a, participantBId: b },
          { participantAId: b, participantBId: a },
        ],
      },
    });
  },
  createConversation(data: Prisma.ConversationCreateInput) {
    return prisma.conversation.create({ data });
  },
  listMessages(conversationId: string, skip: number, take: number) {
    const where = { conversationId, ...notDeleted };
    return prisma.$transaction([
      prisma.message.findMany({ where, orderBy: { createdAt: 'desc' }, skip, take }),
      prisma.message.count({ where }),
    ]);
  },
  createMessage(data: Prisma.MessageCreateInput) {
    return prisma.message.create({ data });
  },
};
