import bcrypt from 'bcryptjs';
import { Role, UserStatus, type User, type Vendor } from '@prisma/client';
import { env } from '../../config/env.js';
import { ConflictError, UnauthorizedError, ValidationAppError } from '../../lib/errors.js';
import { sendMail } from '../../lib/mailer.js';
import { authRepository, type UserWithVendor } from './auth.repository.js';
import type {
  ForgotPasswordInput,
  LoginInput,
  RegisterInput,
  ProfilePatchInput,
  ResetPasswordInput,
} from './auth.schema.js';
import {
  generateOpaqueToken,
  hashToken,
  parseDurationToMs,
  signAccessToken,
  signRefreshJwt,
  verifyRefreshJwt,
} from './auth.tokens.js';

export type PublicUser = {
  id: string;
  email: string;
  phone: string | null;
  role: Role;
  status: UserStatus;
  firstName: string;
  lastName: string;
  displayName: string | null;
  avatarKey: string | null;
  locale: string;
  country: string | null;
  emailVerifiedAt: Date | null;
  vendor: Vendor | null;
};

export type AuthTokens = {
  accessToken: string;
  refreshToken: string;
  expiresIn: string;
};

function toPublicUser(user: UserWithVendor): PublicUser {
  return {
    id: user.id,
    email: user.email,
    phone: user.phone,
    role: user.role,
    status: user.status,
    firstName: user.firstName,
    lastName: user.lastName,
    displayName: user.displayName,
    avatarKey: user.avatarKey,
    locale: user.locale,
    country: user.country,
    emailVerifiedAt: user.emailVerifiedAt,
    vendor: user.vendor,
  };
}

async function issueTokens(
  user: Pick<User, 'id' | 'role'>,
  meta: { userAgent?: string; ipAddress?: string },
): Promise<AuthTokens> {
  const accessToken = signAccessToken(user.id, user.role);
  const jti = generateOpaqueToken();
  const refreshToken = signRefreshJwt(user.id, user.role, jti);
  const tokenHash = hashToken(refreshToken);
  await authRepository.createRefreshToken({
    userId: user.id,
    tokenHash,
    expiresAt: new Date(Date.now() + parseDurationToMs(env.JWT_REFRESH_EXPIRES_IN)),
    userAgent: meta.userAgent,
    ipAddress: meta.ipAddress,
  });
  return {
    accessToken,
    refreshToken,
    expiresIn: env.JWT_ACCESS_EXPIRES_IN,
  };
}

export const authService = {
  async register(
    input: RegisterInput,
    meta: { userAgent?: string; ipAddress?: string },
  ): Promise<{ user: PublicUser; tokens: AuthTokens }> {
    const existing = await authRepository.findActiveByEmail(input.email);
    if (existing) {
      throw new ConflictError('An account with this email already exists');
    }
    const passwordHash = await bcrypt.hash(input.password, env.BCRYPT_ROUNDS);
    const user =
      input.role === 'vendor'
        ? await authRepository.createVendor({
            email: input.email,
            passwordHash,
            firstName: input.firstName,
            lastName: input.lastName,
            phone: input.phone,
            locale: input.locale,
            country: input.country,
            city: input.city,
            legalName: input.legalName,
            taxId: input.taxId,
            website: input.website || undefined,
            businessName: input.businessName ?? { en: `${input.firstName} ${input.lastName}`, ar: `${input.firstName} ${input.lastName}` },
            description: input.description ?? { en: '', ar: '' },
          })
        : await authRepository.createCustomer({
            email: input.email,
            passwordHash,
            firstName: input.firstName,
            lastName: input.lastName,
            phone: input.phone,
            locale: input.locale,
            country: input.country,
          });
    const tokens = await issueTokens(user, meta);
    return { user: toPublicUser(user), tokens };
  },

  async login(
    input: LoginInput,
    meta: { userAgent?: string; ipAddress?: string },
  ): Promise<{ user: PublicUser; tokens: AuthTokens }> {
    const user = await authRepository.findActiveByEmail(input.email);
    if (!user) {
      throw new UnauthorizedError('Invalid credentials');
    }
    if (user.status === UserStatus.SUSPENDED || user.status === UserStatus.INACTIVE) {
      throw new UnauthorizedError('Account is not allowed to sign in');
    }
    const matches = await bcrypt.compare(input.password, user.passwordHash);
    if (!matches) {
      throw new UnauthorizedError('Invalid credentials');
    }
    await authRepository.touchLastLogin(user.id);
    const tokens = await issueTokens(user, meta);
    return { user: toPublicUser(user), tokens };
  },

  async refresh(
    refreshToken: string,
    meta: { userAgent?: string; ipAddress?: string },
  ): Promise<{ user: PublicUser; tokens: AuthTokens }> {
    const payload = verifyRefreshJwt(refreshToken);
    const tokenHash = hashToken(refreshToken);
    const stored = await authRepository.findRefreshToken(tokenHash);
    if (!stored || stored.revokedAt || stored.expiresAt.getTime() < Date.now()) {
      throw new UnauthorizedError('Refresh token is not valid');
    }
    if (stored.userId !== payload.sub) {
      throw new UnauthorizedError('Refresh token is not valid');
    }
    const user = await authRepository.findActiveById(payload.sub);
    if (!user) {
      throw new UnauthorizedError('Account not found');
    }
    await authRepository.revokeRefreshToken(stored.id);
    const tokens = await issueTokens(user, meta);
    return { user: toPublicUser(user), tokens };
  },

  async logout(userId: string, refreshToken?: string): Promise<void> {
    if (refreshToken) {
      const stored = await authRepository.findRefreshToken(hashToken(refreshToken));
      if (stored && stored.userId === userId && !stored.revokedAt) {
        await authRepository.revokeRefreshToken(stored.id);
        return;
      }
    }
    await authRepository.revokeAllRefreshTokens(userId);
  },

  async forgotPassword(input: ForgotPasswordInput): Promise<void> {
    const user = await authRepository.findActiveByEmail(input.email);
    if (!user) {
      return;
    }
    const token = generateOpaqueToken();
    await authRepository.createPasswordReset({
      userId: user.id,
      tokenHash: hashToken(token),
      expiresAt: new Date(Date.now() + 60 * 60 * 1000),
    });
    const resetUrl = `${env.ADMIN_WEB_URL}/reset-password?token=${encodeURIComponent(token)}`;
    const appLink = `${env.CUSTOMER_APP_DEEP_LINK}?token=${encodeURIComponent(token)}`;
    await sendMail({
      to: user.email,
      subject: 'Reset your Zaya Events password',
      text: `Reset your password: ${resetUrl}\nMobile: ${appLink}\nThis link expires in 1 hour.`,
      html: `<p>Reset your password (expires in 1 hour):</p><p><a href="${resetUrl}">${resetUrl}</a></p><p>Mobile: ${appLink}</p>`,
    });
  },

  async resetPassword(input: ResetPasswordInput): Promise<void> {
    const stored = await authRepository.findPasswordReset(hashToken(input.token));
    if (!stored || stored.usedAt || stored.expiresAt.getTime() < Date.now()) {
      throw new ValidationAppError('Reset token is invalid or expired');
    }
    const passwordHash = await bcrypt.hash(input.password, env.BCRYPT_ROUNDS);
    await authRepository.updatePassword(stored.userId, passwordHash);
    await authRepository.markPasswordResetUsed(stored.id);
    await authRepository.revokeAllRefreshTokens(stored.userId);
  },

  async me(userId: string): Promise<PublicUser> {
    const user = await authRepository.findActiveById(userId);
    if (!user) {
      throw new UnauthorizedError('Account not found');
    }
    return toPublicUser(user);
  },

  async updateProfile(userId: string, input: ProfilePatchInput): Promise<PublicUser> {
    const user = await authRepository.findActiveById(userId);
    if (!user) {
      throw new UnauthorizedError('Account not found');
    }
    const firstName = input.firstName ?? user.firstName;
    const lastName = input.lastName ?? user.lastName;
    const updated = await authRepository.updateProfile(userId, {
      firstName: input.firstName,
      lastName: input.lastName,
      phone: input.phone === undefined ? undefined : input.phone,
      locale: input.locale,
      country: input.country === undefined ? undefined : input.country,
      avatarKey: input.avatarKey,
      displayName: input.displayName ?? `${firstName} ${lastName}`,
    });
    return toPublicUser(updated);
  },
};
