import { NotificationChannel, NotificationStatus } from '@prisma/client';
import { env } from '../../config/env.js';
import { sendFcm } from '../../integrations/fcm.js';
import { whatsappProvider } from '../../integrations/index.js';
import { logger } from '../../lib/logger.js';
import { paginated, skipTake, type PaginationQuery } from '../../lib/common.js';
import { NotFoundError } from '../../lib/errors.js';
import { prisma } from '../../lib/prisma.js';
import { notificationRepository } from './notification.repository.js';

export type NotifyInput = {
  userId: string;
  title: { en: string; ar: string };
  body: { en: string; ar: string };
  data?: Record<string, string>;
};

export const notificationService = {
  async notify(input: NotifyInput): Promise<void> {
    const row = await notificationRepository.create({
      user: { connect: { id: input.userId } },
      title: input.title,
      body: input.body,
      channel: NotificationChannel.IN_APP,
      status: NotificationStatus.SENT,
      data: input.data ?? {},
      sentAt: new Date(),
    });
    const devices = await notificationRepository.tokens(input.userId);
    await sendFcm({
      tokens: devices.map((d) => d.token),
      title: input.title.en,
      body: input.body.en,
      data: { notificationId: row.id, ...(input.data ?? {}) },
    });
    if (env.WHATSAPP_NOTIFY_ENABLED) {
      const user = await prisma.user.findFirst({ where: { id: input.userId, deletedAt: null } });
      if (user?.phone) {
        try {
          await whatsappProvider.sendTemplate({
            to: user.phone,
            templateName: 'zaya_notification',
            language: user.locale === 'ar' ? 'ar' : 'en',
            bodyParams: [input.title.en, input.body.en],
          });
          await notificationRepository.create({
            user: { connect: { id: input.userId } },
            title: input.title,
            body: input.body,
            channel: NotificationChannel.WHATSAPP,
            status: NotificationStatus.SENT,
            data: input.data ?? {},
            sentAt: new Date(),
          });
        } catch (error) {
          logger.warn({ err: error, userId: input.userId }, 'WhatsApp notification skipped');
        }
      }
    }
  },

  async list(userId: string, query: PaginationQuery & { unreadOnly?: boolean }) {
    const { skip, take } = skipTake(query);
    const [items, total] = await notificationRepository.list(userId, skip, take, query.unreadOnly === true);
    return paginated(items, total, query);
  },

  async markRead(userId: string, id: string) {
    const result = await notificationRepository.markRead(userId, id);
    if (result.count === 0) {
      throw new NotFoundError('Notification not found');
    }
    return { read: true };
  },

  async markAllRead(userId: string) {
    await notificationRepository.markAllRead(userId);
    return { read: true };
  },

  async registerDevice(userId: string, token: string, platform: string) {
    const device = await notificationRepository.upsertDevice(userId, token, platform);
    return { id: device.id };
  },

  async adminHistory(query: PaginationQuery) {
    const { skip, take } = skipTake(query);
    const [items, total] = await notificationRepository.adminList(skip, take);
    return paginated(items, total, query);
  },

  async broadcast(input: {
    title: { en: string; ar: string };
    body: { en: string; ar: string };
    role?: 'CUSTOMER' | 'VENDOR';
  }) {
    const users = input.role
      ? await notificationRepository.usersByRole(input.role)
      : [
          ...(await notificationRepository.usersByRole('CUSTOMER')),
          ...(await notificationRepository.usersByRole('VENDOR')),
        ];
    await Promise.all(
      users.map((user) =>
        this.notify({
          userId: user.id,
          title: input.title,
          body: input.body,
          data: { type: 'broadcast' },
        }),
      ),
    );
    return { sent: users.length };
  },
};
