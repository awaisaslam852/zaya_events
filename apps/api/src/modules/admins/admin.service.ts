import { randomBytes } from 'node:crypto';
import bcrypt from 'bcryptjs';
import { Role, UserStatus, type Prisma } from '@prisma/client';
import { env } from '../../config/env.js';
import { listAdminAudit, writeAdminAudit } from '../../lib/admin-audit.js';
import { parseCountryList } from '../../lib/admin-scope.js';
import { ConflictError, ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { sendMail } from '../../lib/mailer.js';
import { notDeleted, paginated, skipTake } from '../../lib/common.js';
import { prisma } from '../../lib/prisma.js';
import { authRepository } from '../auth/auth.repository.js';
import type { z } from 'zod';
import type { adminCreateSchema, adminListQuery, adminPatchSchema } from './admin.schema.js';

function toStaff(user: {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  phone: string | null;
  status: UserStatus;
  isSuperAdmin: boolean;
  allowedCountries: Prisma.JsonValue;
  lastLoginAt: Date | null;
  createdAt: Date;
}) {
  return {
    id: user.id,
    email: user.email,
    firstName: user.firstName,
    lastName: user.lastName,
    phone: user.phone,
    status: user.status,
    isSuperAdmin: user.isSuperAdmin,
    allowedCountries: parseCountryList(user.allowedCountries),
    lastLoginAt: user.lastLoginAt,
    createdAt: user.createdAt,
  };
}

const staffSelect = {
  id: true,
  email: true,
  firstName: true,
  lastName: true,
  phone: true,
  status: true,
  isSuperAdmin: true,
  allowedCountries: true,
  lastLoginAt: true,
  createdAt: true,
} as const;

function generateTempPassword(): string {
  return `${randomBytes(9).toString('base64url').replace(/[^a-zA-Z0-9]/g, 'A').slice(0, 10)}1a`;
}

async function inviteStaff(email: string, password: string): Promise<boolean> {
  try {
    await sendMail({
      to: email,
      subject: 'Your Zaya Events admin access',
      text: `You have been added as a country administrator.\n\nLogin: ${env.ADMIN_WEB_URL}/login\nEmail: ${email}\nTemporary password: ${password}\n\nChange this password after you sign in.`,
      html: `<p>You have been added as a country administrator.</p><p>Login: <a href="${env.ADMIN_WEB_URL}/login">${env.ADMIN_WEB_URL}/login</a></p><p>Email: ${email}</p><p>Temporary password: <strong>${password}</strong></p><p>Change this password after you sign in.</p>`,
    });
    return true;
  } catch {
    return false;
  }
}

export const adminService = {
  async list(query: z.infer<typeof adminListQuery>) {
    const { skip, take } = skipTake(query);
    const where: Prisma.UserWhereInput = {
      role: Role.ADMIN,
      ...notDeleted,
      ...(query.q
        ? {
            OR: [
              { email: { contains: query.q, mode: 'insensitive' } },
              { firstName: { contains: query.q, mode: 'insensitive' } },
              { lastName: { contains: query.q, mode: 'insensitive' } },
            ],
          }
        : {}),
    };
    const [items, total] = await prisma.$transaction([
      prisma.user.findMany({
        where,
        orderBy: [{ isSuperAdmin: 'desc' }, { createdAt: 'asc' }],
        skip,
        take,
        select: staffSelect,
      }),
      prisma.user.count({ where }),
    ]);
    return paginated(items.map(toStaff), total, query);
  },

  async get(id: string) {
    const current = await prisma.user.findFirst({
      where: { id, role: Role.ADMIN, ...notDeleted },
      select: staffSelect,
    });
    if (!current) {
      throw new NotFoundError('Staff account not found');
    }
    const [audit, bookingActions] = await Promise.all([
      listAdminAudit(id, 40),
      prisma.bookingStatusHistory.findMany({
        where: { actorId: id, deletedAt: null },
        orderBy: { createdAt: 'desc' },
        take: 20,
        include: { booking: { select: { id: true, bookingNumber: true, status: true } } },
      }),
    ]);
    const activity = [
      ...audit.map((row) => ({
        kind: 'audit' as const,
        at: row.createdAt,
        action: row.action,
        entityType: row.entityType,
        entityId: row.entityId,
        country: row.country,
        meta: row.meta,
      })),
      ...bookingActions.map((row) => ({
        kind: 'booking' as const,
        at: row.createdAt,
        action: `booking.${String(row.toStatus).toLowerCase()}`,
        entityType: 'Booking',
        entityId: row.bookingId,
        country: null,
        meta: { fromStatus: row.fromStatus, toStatus: row.toStatus, bookingNumber: row.booking.bookingNumber },
      })),
    ].sort((a, b) => b.at.getTime() - a.at.getTime());
    return { ...toStaff(current), activity: activity.slice(0, 50) };
  },

  async create(input: z.infer<typeof adminCreateSchema>, actorId: string) {
    const existing = await authRepository.findActiveByEmail(input.email);
    if (existing) {
      throw new ConflictError('An account with this email already exists');
    }
    const temporaryPassword = input.password ?? generateTempPassword();
    const passwordHash = await bcrypt.hash(temporaryPassword, env.BCRYPT_ROUNDS);
    const user = await prisma.user.create({
      data: {
        email: input.email.toLowerCase(),
        passwordHash,
        role: Role.ADMIN,
        status: UserStatus.ACTIVE,
        isSuperAdmin: false,
        allowedCountries: input.allowedCountries,
        firstName: input.firstName,
        lastName: input.lastName,
        displayName: `${input.firstName} ${input.lastName}`,
        phone: input.phone,
        locale: 'en',
        emailVerifiedAt: new Date(),
      },
    });
    const emailSent = await inviteStaff(user.email, temporaryPassword);
    await writeAdminAudit({
      actorId,
      action: 'staff.create',
      entityType: 'User',
      entityId: user.id,
      country: input.allowedCountries[0],
      meta: { allowedCountries: input.allowedCountries, emailSent },
    });
    return {
      ...toStaff(user),
      emailSent,
      temporaryPassword: emailSent ? undefined : temporaryPassword,
    };
  },

  async update(id: string, actorId: string, input: z.infer<typeof adminPatchSchema>) {
    const current = await prisma.user.findFirst({ where: { id, role: Role.ADMIN, ...notDeleted } });
    if (!current) {
      throw new NotFoundError('Staff account not found');
    }
    if (current.isSuperAdmin) {
      throw new ForbiddenError('The main administrator account cannot be edited here');
    }
    if (input.password) {
      await authRepository.updatePassword(id, await bcrypt.hash(input.password, env.BCRYPT_ROUNDS));
    }
    const firstName = input.firstName ?? current.firstName;
    const lastName = input.lastName ?? current.lastName;
    const updated = await prisma.user.update({
      where: { id },
      data: {
        firstName: input.firstName,
        lastName: input.lastName,
        displayName: `${firstName} ${lastName}`,
        phone: input.phone === undefined ? undefined : input.phone,
        status: input.status,
        allowedCountries: input.allowedCountries,
      },
    });
    if (input.status === UserStatus.INACTIVE || input.status === UserStatus.SUSPENDED) {
      await authRepository.revokeAllRefreshTokens(id);
    }
    if (input.status && input.status !== current.status) {
      await writeAdminAudit({
        actorId,
        action: `staff.${input.status.toLowerCase()}`,
        entityType: 'User',
        entityId: id,
        country: parseCountryList(updated.allowedCountries)[0],
        meta: { from: current.status, to: input.status },
      });
    }
    return toStaff(updated);
  },

  async remove(id: string, actorId: string) {
    const current = await prisma.user.findFirst({ where: { id, role: Role.ADMIN, ...notDeleted } });
    if (!current) {
      throw new NotFoundError('Staff account not found');
    }
    if (current.isSuperAdmin) {
      throw new ForbiddenError('The main administrator account cannot be deleted');
    }
    if (current.id === actorId) {
      throw new ForbiddenError('You cannot delete your own account');
    }
    await prisma.user.update({
      where: { id },
      data: { deletedAt: new Date(), status: UserStatus.INACTIVE },
    });
    await authRepository.revokeAllRefreshTokens(id);
    await writeAdminAudit({
      actorId,
      action: 'staff.delete',
      entityType: 'User',
      entityId: id,
      country: parseCountryList(current.allowedCountries)[0],
    });
    return { deleted: true };
  },
};
