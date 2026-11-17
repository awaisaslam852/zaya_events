import bcrypt from 'bcryptjs';
import request from 'supertest';
import { ConversationType, Role, UserStatus } from '@prisma/client';
import { createApp } from '../src/app.js';
import { env } from '../src/config/env.js';
import { prisma } from '../src/lib/prisma.js';
import { pickCanonicalConversation } from '../src/modules/chat/chat.repository.js';
import { accessToken, uniqueEmail } from './helpers.js';

const app = createApp();

describe('one conversation per person', () => {
  it('prefers the thread that already has a message', () => {
    const empty = { lastMessageAt: null, createdAt: new Date('2026-11-15T09:00:00Z') };
    const dated = { lastMessageAt: new Date('2026-11-15T10:00:00Z'), createdAt: new Date('2026-11-15T11:00:00Z') };
    expect(pickCanonicalConversation([empty, dated])).toBe(dated);
  });

  it('reuses the same thread if Chat is opened again from a booking', async () => {
    const password = 'TestPass!234';
    const customerEmail = uniqueEmail('chat-customer');
    const customerRes = await request(app).post('/api/v1/auth/register').send({
      email: customerEmail,
      password,
      firstName: 'Insha',
      lastName: 'Awais',
      role: 'customer',
    });
    expect(customerRes.status).toBe(201);
    const customerToken = accessToken(customerRes);
    const customerId = customerRes.body.data.user.id as string;

    const vendor = await prisma.user.create({
      data: {
        email: uniqueEmail('chat-vendor'),
        passwordHash: await bcrypt.hash(password, env.BCRYPT_ROUNDS),
        role: Role.VENDOR,
        status: UserStatus.ACTIVE,
        firstName: 'Vendor',
        lastName: 'Peer',
      },
    });

    const first = await request(app)
      .post('/api/v1/chat/conversations')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ participantId: vendor.id });
    expect(first.status).toBe(201);
    const conversationId = first.body.data.id as string;

    const second = await request(app)
      .post('/api/v1/chat/conversations')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ participantId: vendor.id });
    expect(second.status).toBe(201);
    expect(second.body.data.id).toBe(conversationId);

    await prisma.conversation.create({
      data: {
        type: ConversationType.CUSTOMER_VENDOR,
        participantAId: customerId,
        participantBId: vendor.id,
      },
    });

    const inbox = await request(app)
      .get('/api/v1/chat/conversations')
      .set('Authorization', `Bearer ${customerToken}`);
    expect(inbox.status).toBe(200);
    const samePeer = (inbox.body.data.items as Array<{ participantAId: string; participantBId: string }>).filter(
      (row) =>
        (row.participantAId === customerId && row.participantBId === vendor.id) ||
        (row.participantAId === vendor.id && row.participantBId === customerId),
    );
    expect(samePeer).toHaveLength(1);
    expect(samePeer[0]).toMatchObject({ id: conversationId });
  });
});
