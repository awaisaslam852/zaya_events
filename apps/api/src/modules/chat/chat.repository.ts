import { ConversationType, Role, type Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { adminScope, countryInFilter, type AdminActor } from '../../lib/admin-scope.js';
import { notDeleted } from '../../lib/common.js';

const supportTypes: ConversationType[] = [ConversationType.CUSTOMER_ADMIN, ConversationType.VENDOR_ADMIN];

const participantSelect = {
  id: true,
  firstName: true,
  lastName: true,
  displayName: true,
  avatarKey: true,
  role: true,
  country: true,
  vendor: { select: { logoKey: true, coverKey: true, businessName: true } },
} as const;

type ConversationMergeRow = {
  id: string;
  type: ConversationType;
  participantAId: string;
  participantBId: string;
  bookingId: string | null;
  lastMessageAt: Date | null;
  createdAt: Date;
};

export function pickCanonicalConversation<T extends { lastMessageAt: Date | null; createdAt: Date }>(
  rows: T[],
): T | null {
  if (rows.length === 0) {
    return null;
  }
  return [...rows].sort((left, right) => {
    if (left.lastMessageAt && !right.lastMessageAt) {
      return -1;
    }
    if (!left.lastMessageAt && right.lastMessageAt) {
      return 1;
    }
    if (left.lastMessageAt && right.lastMessageAt) {
      return right.lastMessageAt.getTime() - left.lastMessageAt.getTime();
    }
    return left.createdAt.getTime() - right.createdAt.getTime();
  })[0] ?? null;
}

function adminInboxWhere(userId: string, actor?: AdminActor | null): Prisma.ConversationWhereInput {
  const scope = adminScope(actor ?? null);
  const country = countryInFilter(scope);
  const supportOrOwn: Prisma.ConversationWhereInput = {
    OR: [{ participantAId: userId }, { participantBId: userId }, { type: { in: supportTypes } }],
  };
  if (!country) {
    return { ...notDeleted, ...supportOrOwn };
  }
  return {
    ...notDeleted,
    AND: [
      supportOrOwn,
      {
        OR: [
          { participantA: { role: { not: Role.ADMIN }, country } },
          { participantB: { role: { not: Role.ADMIN }, country } },
          { booking: { vendor: { country } } },
          { booking: { customer: { country } } },
        ],
      },
    ],
  };
}

export const chatRepository = {
  listConversations(userId: string, skip: number, take: number, actor?: AdminActor | null) {
    const where: Prisma.ConversationWhereInput =
      actor?.role === Role.ADMIN
        ? adminInboxWhere(userId, actor)
        : {
            ...notDeleted,
            OR: [{ participantAId: userId }, { participantBId: userId }],
          };
    return prisma.$transaction([
      prisma.conversation.findMany({
        where,
        include: {
          participantA: { select: participantSelect },
          participantB: { select: participantSelect },
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
        participantA: { select: participantSelect },
        participantB: { select: participantSelect },
        booking: { include: { vendor: { select: { country: true } }, customer: { select: { country: true } } } },
      },
    });
  },
  canAdminAccess(row: {
    type: ConversationType;
    participantA: { role: Role; country: string | null };
    participantB: { role: Role; country: string | null };
    booking?: { vendor?: { country: string | null } | null; customer?: { country: string | null } | null } | null;
  }, actor?: AdminActor | null): boolean {
    const scope = adminScope(actor ?? null);
    if (!scope) {
      return false;
    }
    const peerCountry =
      (row.participantA.role !== Role.ADMIN ? row.participantA.country : null) ??
      (row.participantB.role !== Role.ADMIN ? row.participantB.country : null) ??
      row.booking?.vendor?.country ??
      row.booking?.customer?.country ??
      null;
    if (scope.all) {
      return true;
    }
    return Boolean(peerCountry && scope.countries.includes(peerCountry));
  },
  pairWhere(a: string, b: string): Prisma.ConversationWhereInput {
    return {
      OR: [
        { participantAId: a, participantBId: b },
        { participantAId: b, participantBId: a },
      ],
    };
  },
  async findPair(a: string, b: string, type?: ConversationType) {
    const rows = await prisma.conversation.findMany({
      where: {
        ...notDeleted,
        ...(type ? { type } : {}),
        ...this.pairWhere(a, b),
      },
    });
    return pickCanonicalConversation(rows);
  },
  async collapseDuplicatesForUser(userId: string) {
    const rows = await prisma.conversation.findMany({
      where: {
        ...notDeleted,
        OR: [{ participantAId: userId }, { participantBId: userId }],
      },
    });
    const groups = new Map<string, typeof rows>();
    for (const row of rows) {
      const [left, right] = [row.participantAId, row.participantBId].sort();
      const key = `${row.type}:${left}:${right}`;
      const group = groups.get(key) ?? [];
      group.push(row);
      groups.set(key, group);
    }
    for (const group of groups.values()) {
      if (group.length > 1) {
        await this.mergeConversations(group);
      }
    }
  },
  async reusePair(input: { a: string; b: string; type: ConversationType; bookingId?: string }) {
    const rows = await prisma.conversation.findMany({
      where: { ...notDeleted, type: input.type, ...this.pairWhere(input.a, input.b) },
    });
    const keeper = await this.mergeConversations(rows);
    if (!keeper) {
      return null;
    }
    if (input.bookingId && !keeper.bookingId) {
      return prisma.conversation.update({
        where: { id: keeper.id },
        data: { bookingId: input.bookingId },
      });
    }
    return keeper;
  },
  async mergeConversations<T extends ConversationMergeRow>(rows: T[]): Promise<T | null> {
    if (rows.length === 0) {
      return null;
    }
    const keeper = pickCanonicalConversation(rows);
    if (!keeper) {
      return null;
    }
    const extras = rows.filter((row) => row.id !== keeper.id);
    if (extras.length === 0) {
      return keeper;
    }
    const latestMessageAt = rows.reduce<Date | null>((latest, row) => {
      if (!row.lastMessageAt) {
        return latest;
      }
      if (!latest || row.lastMessageAt > latest) {
        return row.lastMessageAt;
      }
      return latest;
    }, keeper.lastMessageAt);
    const bookingId = keeper.bookingId ?? extras.find((row) => row.bookingId)?.bookingId ?? null;
    await prisma.$transaction(async (tx) => {
      for (const extra of extras) {
        await tx.message.updateMany({
          where: { conversationId: extra.id, deletedAt: null },
          data: { conversationId: keeper.id },
        });
        await tx.conversation.update({
          where: { id: extra.id },
          data: { deletedAt: new Date() },
        });
      }
      await tx.conversation.update({
        where: { id: keeper.id },
        data: {
          ...(latestMessageAt && latestMessageAt.getTime() !== keeper.lastMessageAt?.getTime()
            ? { lastMessageAt: latestMessageAt }
            : {}),
          ...(bookingId && !keeper.bookingId ? { bookingId } : {}),
        },
      });
    });
    return { ...keeper, lastMessageAt: latestMessageAt ?? keeper.lastMessageAt, bookingId: bookingId ?? keeper.bookingId };
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
