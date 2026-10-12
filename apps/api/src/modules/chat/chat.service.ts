import { ConversationType, Role } from '@prisma/client';
import { ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { paginated, skipTake } from '../../lib/common.js';
import { emitToUser } from '../../lib/sockets.js';
import { chatRepository } from './chat.repository.js';
import { prisma } from '../../lib/prisma.js';
import type { z } from 'zod';
import type { conversationCreateSchema, conversationListQuery, messageCreateSchema, messageListQuery } from './chat.schema.js';

function other(userId: string, a: string, b: string): string {
  return a === userId ? b : a;
}

export const chatService = {
  async list(userId: string, query: z.infer<typeof conversationListQuery>) {
    const { skip, take } = skipTake(query);
    const [items, total] = await chatRepository.listConversations(userId, skip, take);
    return paginated(items, total, query);
  },
  async get(userId: string, id: string) {
    const row = await chatRepository.findConversation(id);
    if (!row) {
      throw new NotFoundError('Conversation not found');
    }
    if (row.participantAId !== userId && row.participantBId !== userId) {
      throw new ForbiddenError();
    }
    return row;
  },
  async start(userId: string, input: z.infer<typeof conversationCreateSchema>) {
    const peer = await prisma.user.findFirst({ where: { id: input.participantId, deletedAt: null } });
    if (!peer) {
      throw new NotFoundError('Participant not found');
    }
    const existing = await chatRepository.findPair(userId, input.participantId, input.bookingId);
    if (existing) {
      return existing;
    }
    return chatRepository.createConversation({
      type: input.type,
      participantA: { connect: { id: userId } },
      participantB: { connect: { id: input.participantId } },
      ...(input.bookingId ? { booking: { connect: { id: input.bookingId } } } : {}),
    });
  },
  async startSupport(userId: string) {
    const me = await prisma.user.findFirst({ where: { id: userId, deletedAt: null } });
    if (!me) {
      throw new ForbiddenError();
    }
    const admin = await prisma.user.findFirst({
      where: { role: Role.ADMIN, deletedAt: null },
      orderBy: { createdAt: 'asc' },
    });
    if (!admin) {
      throw new NotFoundError('Support is unavailable');
    }
    if (admin.id === userId) {
      throw new ForbiddenError();
    }
    const type = me.role === Role.VENDOR ? ConversationType.VENDOR_ADMIN : ConversationType.CUSTOMER_ADMIN;
    return this.start(userId, { participantId: admin.id, type });
  },
  async messages(userId: string, conversationId: string, query: z.infer<typeof messageListQuery>) {
    await this.get(userId, conversationId);
    const { skip, take } = skipTake(query);
    const [items, total] = await chatRepository.listMessages(conversationId, skip, take);
    return paginated(items, total, query);
  },
  async send(userId: string, conversationId: string, input: z.infer<typeof messageCreateSchema>) {
    const conversation = await this.get(userId, conversationId);
    const message = await chatRepository.createMessage({
      conversation: { connect: { id: conversationId } },
      sender: { connect: { id: userId } },
      type: input.type,
      body: input.body,
      attachments: input.attachments,
    });
    await prisma.conversation.update({
      where: { id: conversationId },
      data: { lastMessageAt: new Date() },
    });
    const peer = other(userId, conversation.participantAId, conversation.participantBId);
    emitToUser('/chat', peer, 'message:new', message);
    emitToUser('/chat', userId, 'message:new', message);
    emitToUser('/chat', peer, 'message', message);
    emitToUser('/chat', userId, 'message', message);
    return message;
  },
  async markRead(userId: string, conversationId: string) {
    const conversation = await this.get(userId, conversationId);
    const now = new Date();
    const data =
      conversation.participantAId === userId ? { aLastReadAt: now } : { bLastReadAt: now };
    await prisma.conversation.update({ where: { id: conversationId }, data });
    await prisma.message.updateMany({
      where: { conversationId, senderId: { not: userId }, readAt: null, deletedAt: null },
      data: { readAt: now },
    });
    const peer = other(userId, conversation.participantAId, conversation.participantBId);
    emitToUser('/chat', peer, 'message:read', { conversationId, userId, readAt: now.toISOString() });
    return { read: true };
  },
};
