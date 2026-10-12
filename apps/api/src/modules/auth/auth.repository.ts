import { Role, UserStatus, VendorStatus, type Prisma, type User, type Vendor } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';

const notDeleted = { deletedAt: null };

export type UserWithVendor = User & { vendor: Vendor | null };

export const authRepository = {
  async findActiveByEmail(email: string): Promise<UserWithVendor | null> {
    return prisma.user.findFirst({
      where: { email: email.toLowerCase(), ...notDeleted },
      include: { vendor: true },
    });
  },

  async findActiveById(id: string): Promise<UserWithVendor | null> {
    return prisma.user.findFirst({
      where: { id, ...notDeleted },
      include: { vendor: true },
    });
  },

  async createCustomer(data: {
    email: string;
    passwordHash: string;
    firstName: string;
    lastName: string;
    phone?: string;
    locale: string;
    country?: string;
  }): Promise<UserWithVendor> {
    return prisma.user.create({
      data: {
        email: data.email.toLowerCase(),
        passwordHash: data.passwordHash,
        role: Role.CUSTOMER,
        status: UserStatus.ACTIVE,
        firstName: data.firstName,
        lastName: data.lastName,
        displayName: `${data.firstName} ${data.lastName}`,
        phone: data.phone,
        locale: data.locale,
        country: data.country,
        emailVerifiedAt: new Date(),
      },
      include: { vendor: true },
    });
  },

  async createVendor(data: {
    email: string;
    passwordHash: string;
    firstName: string;
    lastName: string;
    phone?: string;
    locale: string;
    businessName: Prisma.InputJsonValue;
    description: Prisma.InputJsonValue;
    country?: string;
    city?: string;
    legalName?: string;
    taxId?: string;
    website?: string;
    approved?: boolean;
  }): Promise<UserWithVendor> {
    return prisma.user.create({
      data: {
        email: data.email.toLowerCase(),
        passwordHash: data.passwordHash,
        role: Role.VENDOR,
        status: UserStatus.ACTIVE,
        firstName: data.firstName,
        lastName: data.lastName,
        displayName: `${data.firstName} ${data.lastName}`,
        phone: data.phone,
        locale: data.locale,
        country: data.country,
        emailVerifiedAt: new Date(),
        vendor: {
          create: {
            businessName: data.businessName,
            description: data.description,
            phone: data.phone,
            country: data.country,
            city: data.city,
            legalName: data.legalName,
            taxId: data.taxId,
            website: data.website,
            status: data.approved ? VendorStatus.APPROVED : VendorStatus.PENDING,
          },
        },
      },
      include: { vendor: true },
    });
  },

  async touchLastLogin(id: string): Promise<void> {
    await prisma.user.update({
      where: { id },
      data: { lastLoginAt: new Date() },
    });
  },

  async createRefreshToken(data: {
    userId: string;
    tokenHash: string;
    expiresAt: Date;
    userAgent?: string;
    ipAddress?: string;
  }): Promise<{ id: string }> {
    return prisma.refreshToken.create({
      data: { ...data },
      select: { id: true },
    });
  },

  async findRefreshToken(tokenHash: string) {
    return prisma.refreshToken.findFirst({
      where: { tokenHash, deletedAt: null },
    });
  },

  async revokeRefreshToken(id: string): Promise<void> {
    await prisma.refreshToken.update({
      where: { id },
      data: { revokedAt: new Date() },
    });
  },

  async revokeAllRefreshTokens(userId: string): Promise<void> {
    await prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null, deletedAt: null },
      data: { revokedAt: new Date() },
    });
  },

  async createPasswordReset(data: { userId: string; tokenHash: string; expiresAt: Date }): Promise<void> {
    await prisma.passwordResetToken.updateMany({
      where: { userId: data.userId, usedAt: null, deletedAt: null },
      data: { usedAt: new Date() },
    });
    await prisma.passwordResetToken.create({ data });
  },

  async findPasswordReset(tokenHash: string) {
    return prisma.passwordResetToken.findFirst({
      where: { tokenHash, deletedAt: null },
    });
  },

  async markPasswordResetUsed(id: string): Promise<void> {
    await prisma.passwordResetToken.update({
      where: { id },
      data: { usedAt: new Date() },
    });
  },

  async updatePassword(userId: string, passwordHash: string): Promise<void> {
    await prisma.user.update({
      where: { id: userId },
      data: { passwordHash },
    });
  },

  async updateProfile(
    userId: string,
    data: Prisma.UserUpdateInput,
  ): Promise<UserWithVendor> {
    return prisma.user.update({
      where: { id: userId },
      data,
      include: { vendor: true },
    });
  },
};
