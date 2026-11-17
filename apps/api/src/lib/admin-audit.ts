import type { Prisma } from '@prisma/client';
import { prisma } from './prisma.js';

export async function writeAdminAudit(input: {
  actorId: string;
  action: string;
  entityType: string;
  entityId?: string | null;
  country?: string | null;
  meta?: Prisma.InputJsonValue;
}): Promise<void> {
  await prisma.adminAuditLog.create({
    data: {
      actorId: input.actorId,
      action: input.action,
      entityType: input.entityType,
      entityId: input.entityId ?? undefined,
      country: input.country ?? undefined,
      meta: input.meta,
    },
  });
}

export function listAdminAudit(actorId: string, take = 50) {
  return prisma.adminAuditLog.findMany({
    where: { actorId },
    orderBy: { createdAt: 'desc' },
    take,
  });
}
