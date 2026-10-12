import { NotificationChannel, NotificationStatus, Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const notificationRepository = {
  create(data: Prisma.NotificationCreateInput) {
    return prisma.notification.create({ data });
  },
  list(userId: string, skip: number, take: number, unreadOnly: boolean) {
    const where = {
      userId,
      ...notDeleted,
      ...(unreadOnly ? { readAt: null } : {}),
    };
    return prisma.$transaction([
      prisma.notification.findMany({ where, orderBy: { createdAt: 'desc' }, skip, take }),
      prisma.notification.count({ where }),
    ]);
  },
  markRead(userId: string, id: string) {
    return prisma.notification.updateMany({
      where: { id, userId, deletedAt: null },
      data: { readAt: new Date(), status: NotificationStatus.READ },
    });
  },
  markAllRead(userId: string) {
    return prisma.notification.updateMany({
      where: { userId, deletedAt: null, readAt: null },
      data: { readAt: new Date(), status: NotificationStatus.READ },
    });
  },
  tokens(userId: string) {
    return prisma.deviceToken.findMany({ where: { userId, ...notDeleted } });
  },
  upsertDevice(userId: string, token: string, platform: string) {
    return prisma.deviceToken.upsert({
      where: { userId_token: { userId, token } },
      update: { platform, deletedAt: null },
      create: { userId, token, platform },
    });
  },
  createChannel(data: Prisma.NotificationUncheckedCreateInput) {
    return prisma.notification.create({ data });
  },
  adminList(skip: number, take: number) {
    const where = { ...notDeleted };
    return prisma.$transaction([
      prisma.notification.findMany({
        where,
        include: { user: { select: { id: true, email: true, role: true } } },
        orderBy: { createdAt: 'desc' },
        skip,
        take,
      }),
      prisma.notification.count({ where }),
    ]);
  },
  usersByRole(role: 'CUSTOMER' | 'VENDOR') {
    return prisma.user.findMany({
      where: { role, deletedAt: null, status: 'ACTIVE' },
      select: { id: true },
    });
  },
};

export { NotificationChannel, NotificationStatus };
