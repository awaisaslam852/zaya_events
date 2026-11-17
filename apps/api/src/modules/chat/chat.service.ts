import { ConversationType, Role, UserStatus } from '@prisma/client';
import { ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { parseCountryList } from '../../lib/admin-scope.js';
import type { AuthUser } from '../../middleware/auth.js';
import { paginated, skipTake } from '../../lib/common.js';
import { emitToUser } from '../../lib/sockets.js';
import { notificationService } from '../notifications/notification.service.js';
import { chatRepository } from './chat.repository.js';
import { prisma } from '../../lib/prisma.js';
import type { z } from 'zod';
import type { conversationCreateSchema, conversationListQuery, messageCreateSchema, messageListQuery } from './chat.schema.js';

function other(userId: string, a: string, b: string): string {
  return a === userId ? b : a;
}

function isParticipant(userId: string, a: string, b: string): boolean {
  return a === userId || b === userId;
}

async function supportAdminForCountry(country: string | null) {
  const admins = await prisma.user.findMany({
    where: { role: Role.ADMIN, deletedAt: null, status: UserStatus.ACTIVE },
    orderBy: [{ isSuperAdmin: 'asc' }, { createdAt: 'asc' }],
    select: { id: true, isSuperAdmin: true, allowedCountries: true },
  });
  if (country) {
    const countryAdmin = admins.find(
      (row) => !row.isSuperAdmin && parseCountryList(row.allowedCountries).includes(country),
    );
    if (countryAdmin) {
      return countryAdmin;
    }
  }
  return admins.find((row) => row.isSuperAdmin) ?? admins[0] ?? null;
}

export const chatService = {
  async list(user: AuthUser, query: z.infer<typeof conversationListQuery>) {
    const { skip, take } = skipTake(query);
    await chatRepository.collapseDuplicatesForUser(user.id);
    const [items, total] = await chatRepository.listConversations(user.id, skip, take, user);
    return paginated(items, total, query);
  },
  async get(user: AuthUser, id: string) {
    const row = await chatRepository.findConversation(id);
    if (!row) {
      throw new NotFoundError('Conversation not found');
    }
    if (isParticipant(user.id, row.participantAId, row.participantBId)) {
      return row;
    }
    if (user.role === Role.ADMIN && chatRepository.canAdminAccess(row, user)) {
      return row;
    }
    throw new ForbiddenError();
  },
  async start(userId: string, input: z.infer<typeof conversationCreateSchema>) {
    const peer = await prisma.user.findFirst({ where: { id: input.participantId, deletedAt: null } });
    if (!peer) {
      throw new NotFoundError('Participant not found');
    }
    const existing = await chatRepository.reusePair({
      a: userId,
      b: input.participantId,
      type: input.type,
      bookingId: input.bookingId,
    });
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
    const admin = await supportAdminForCountry(me.country);
    if (!admin) {
      throw new NotFoundError('Support is unavailable');
    }
    if (admin.id === userId) {
      throw new ForbiddenError();
    }
    const type = me.role === Role.VENDOR ? ConversationType.VENDOR_ADMIN : ConversationType.CUSTOMER_ADMIN;
    return this.start(userId, { participantId: admin.id, type });
  },
  async messages(user: AuthUser, conversationId: string, query: z.infer<typeof messageListQuery>) {
    await this.get(user, conversationId);
    const { skip, take } = skipTake(query);
    const [items, total] = await chatRepository.listMessages(conversationId, skip, take);
    return paginated(items, total, query);
  },
  async send(user: AuthUser, conversationId: string, input: z.infer<typeof messageCreateSchema>) {
    const conversation = await this.get(user, conversationId);
    const message = await chatRepository.createMessage({
      conversation: { connect: { id: conversationId } },
      sender: { connect: { id: user.id } },
      type: input.type,
      body: input.body,
      attachments: input.attachments,
    });
    await prisma.conversation.update({
      where: { id: conversationId },
      data: { lastMessageAt: new Date() },
    });
    const peer = other(user.id, conversation.participantAId, conversation.participantBId);
    emitToUser('/chat', peer, 'message:new', message);
    emitToUser('/chat', user.id, 'message:new', message);
    emitToUser('/chat', peer, 'message', message);
    emitToUser('/chat', user.id, 'message', message);
    const preview = input.body.trim().slice(0, 140);
    await notificationService.notify({
      userId: peer,
      title: { en: 'New message', ar: 'رسالة جديدة' },
      body: { en: preview, ar: preview },
      data: {
        type: 'chat_message',
        conversationId,
        ...(conversation.bookingId ? { bookingId: conversation.bookingId } : {}),
      },
    });
    return message;
  },
  async markRead(user: AuthUser, conversationId: string) {
    const conversation = await this.get(user, conversationId);
    const now = new Date();
    const data =
      conversation.participantAId === user.id
        ? { aLastReadAt: now }
        : conversation.participantBId === user.id
          ? { bLastReadAt: now }
          : {};
    if (Object.keys(data).length > 0) {
      await prisma.conversation.update({ where: { id: conversationId }, data });
    }
    await prisma.message.updateMany({
      where: { conversationId, senderId: { not: user.id }, readAt: null, deletedAt: null },
      data: { readAt: now },
    });
    const peer = other(user.id, conversation.participantAId, conversation.participantBId);
    emitToUser('/chat', peer, 'message:read', { conversationId, userId: user.id, readAt: now.toISOString() });
    return { read: true };
  },
};
