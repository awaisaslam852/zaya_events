import { randomInt } from 'node:crypto';
import { CallStatus, Role } from '@prisma/client';
import { env } from '../../config/env.js';
import { adminScope, assertCountryAllowed, countryInFilter } from '../../lib/admin-scope.js';
import type { AuthUser } from '../../middleware/auth.js';
import { AppError, ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { paginated, skipTake } from '../../lib/common.js';
import { emitToUser } from '../../lib/sockets.js';
import { generateRtcToken } from '../agora/agora.service.js';
import { notificationService } from '../notifications/notification.service.js';
import { whatsappProvider } from '../../integrations/index.js';
import { callRepository } from './call.repository.js';
import { prisma } from '../../lib/prisma.js';
import type { z } from 'zod';
import type { callHistoryQuery, callInitiateSchema } from './call.schema.js';

const RING_TIMEOUT_MS = 60_000;
const pendingTimers = new Map<string, NodeJS.Timeout>();

function channelName(callerId: string, calleeId: string, bookingId?: string): string {
  if (bookingId) {
    return `booking_${bookingId}`;
  }
  const [a, b] = [callerId, calleeId].sort();
  return `call_${a}_${b}`;
}

function participant(userId: string, call: { callerId: string; calleeId: string }): boolean {
  return call.callerId === userId || call.calleeId === userId;
}

export const callService = {
  async initiate(userId: string, input: z.infer<typeof callInitiateSchema>, actor?: AuthUser) {
    if (input.calleeId === userId) {
      throw new AppError(422, 'INVALID_CALLEE', 'Cannot call yourself');
    }
    const callee = await prisma.user.findFirst({ where: { id: input.calleeId, deletedAt: null } });
    if (!callee) {
      throw new NotFoundError('Callee not found');
    }
    if (actor?.role === Role.ADMIN) {
      assertCountryAllowed(adminScope(actor), callee.country);
    }
    const callerUid = randomInt(1, 1_000_000_000);
    const calleeUid = randomInt(1, 1_000_000_000);
    const call = await callRepository.create({
      caller: { connect: { id: userId } },
      callee: { connect: { id: input.calleeId } },
      ...(input.bookingId ? { booking: { connect: { id: input.bookingId } } } : {}),
      channelName: channelName(userId, input.calleeId, input.bookingId),
      status: CallStatus.RINGING,
      callerUid,
      calleeUid,
    });
    const saved = await callRepository.findById(call.id);
    const callerName = [saved?.caller.firstName, saved?.caller.lastName].filter(Boolean).join(' ').trim();
    const calleeName = [saved?.callee.firstName, saved?.callee.lastName].filter(Boolean).join(' ').trim();
    const payload = {
      id: call.id,
      callId: call.id,
      channelName: call.channelName,
      callerId: userId,
      calleeId: input.calleeId,
      callerName,
      calleeName,
      status: CallStatus.RINGING,
    };
    emitToUser('/calls', input.calleeId, 'call:incoming', payload);
    emitToUser('/calls', input.calleeId, 'incoming_call', payload);
    await notificationService.notify({
      userId: input.calleeId,
      title: { en: 'Incoming call', ar: 'مكالمة واردة' },
      body: { en: 'You have an incoming call on Zaya Events.', ar: 'لديك مكالمة واردة علىزايا إيفنتس.' },
      data: { type: 'incoming_call', callId: call.id, channelName: call.channelName, callerName },
    });
    if (env.CALLS_WHATSAPP_ENABLED && callee.phone) {
      await whatsappProvider.sendTemplate({
        to: callee.phone,
        templateName: 'incoming_call',
        bodyParams: [call.channelName],
      });
    }
    const timer = setTimeout(() => {
      void this.missIfRinging(call.id);
    }, RING_TIMEOUT_MS);
    pendingTimers.set(call.id, timer);
    return saved;
  },

  async missIfRinging(id: string): Promise<void> {
    pendingTimers.delete(id);
    const call = await callRepository.findById(id);
    if (!call || call.status !== CallStatus.RINGING) {
      return;
    }
    await callRepository.update(id, { status: CallStatus.MISSED, missedAt: new Date() });
    emitToUser('/calls', call.callerId, 'call:missed', { callId: id });
    emitToUser('/calls', call.calleeId, 'call:missed', { callId: id });
    await notificationService.notify({
      userId: call.callerId,
      title: { en: 'Call missed', ar: 'مكالمة فائتة' },
      body: { en: 'The call was not answered.', ar: 'لم يتم الرد على المكالمة.' },
      data: { type: 'call_missed', callId: id },
    });
  },

  async accept(userId: string, id: string) {
    const call = await callRepository.findById(id);
    if (!call) {
      throw new NotFoundError('Call not found');
    }
    if (call.calleeId !== userId) {
      throw new ForbiddenError();
    }
    if (call.status !== CallStatus.RINGING) {
      throw new AppError(422, 'INVALID_CALL_STATE', 'Call is not ringing');
    }
    const timer = pendingTimers.get(id);
    if (timer) {
      clearTimeout(timer);
      pendingTimers.delete(id);
    }
    const updated = await callRepository.update(id, { status: CallStatus.ACCEPTED, startedAt: new Date() });
    emitToUser('/calls', call.callerId, 'call:accepted', { callId: id });
    emitToUser('/calls', call.calleeId, 'call:accepted', { callId: id });
    return updated;
  },

  async reject(userId: string, id: string) {
    const call = await callRepository.findById(id);
    if (!call) {
      throw new NotFoundError('Call not found');
    }
    if (call.calleeId !== userId) {
      throw new ForbiddenError();
    }
    if (call.status !== CallStatus.RINGING) {
      throw new AppError(422, 'INVALID_CALL_STATE', 'Call is not ringing');
    }
    const timer = pendingTimers.get(id);
    if (timer) {
      clearTimeout(timer);
      pendingTimers.delete(id);
    }
    const updated = await callRepository.update(id, { status: CallStatus.REJECTED, endedAt: new Date() });
    emitToUser('/calls', call.callerId, 'call:rejected', { callId: id });
    emitToUser('/calls', call.calleeId, 'call:rejected', { callId: id });
    return updated;
  },

  async end(userId: string, id: string) {
    const call = await callRepository.findById(id);
    if (!call) {
      throw new NotFoundError('Call not found');
    }
    if (!participant(userId, call)) {
      throw new ForbiddenError();
    }
    const timer = pendingTimers.get(id);
    if (timer) {
      clearTimeout(timer);
      pendingTimers.delete(id);
    }
    const updated = await callRepository.update(id, { status: CallStatus.ENDED, endedAt: new Date() });
    emitToUser('/calls', call.callerId, 'call:ended', { callId: id });
    emitToUser('/calls', call.calleeId, 'call:ended', { callId: id });
    return updated;
  },

  async token(user: AuthUser, id: string) {
    const call = await callRepository.findById(id);
    if (!call) {
      throw new NotFoundError('Call not found');
    }
    if (user.role === Role.ADMIN && !participant(user.id, call)) {
      assertCountryAllowed(adminScope(user), call.caller.country ?? call.callee.country);
      return generateRtcToken(call.channelName, randomInt(1, 1_000_000_000), 'SUBSCRIBER');
    }
    if (!participant(user.id, call)) {
      throw new ForbiddenError();
    }
    const uid = call.callerId === user.id ? call.callerUid : call.calleeUid;
    return generateRtcToken(call.channelName, uid, 'PUBLISHER');
  },

  async history(user: AuthUser, query: z.infer<typeof callHistoryQuery>) {
    const { skip, take } = skipTake(query);
    const country = user.role === Role.ADMIN ? countryInFilter(adminScope(user)) : undefined;
    const [items, total] = await callRepository.list(
      user.role === Role.ADMIN ? null : user.id,
      skip,
      take,
      query.q,
      country,
    );
    return paginated(items, total, query);
  },
};
