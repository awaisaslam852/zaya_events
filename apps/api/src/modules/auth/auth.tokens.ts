import { createHash, randomBytes } from 'node:crypto';
import jwt from 'jsonwebtoken';
import { env } from '../../config/env.js';
import { UnauthorizedError } from '../../lib/errors.js';
import type { Role } from '@prisma/client';

export type AccessPayload = {
  sub: string;
  role: Role;
  typ: 'access';
};

export type RefreshPayload = {
  sub: string;
  role: Role;
  typ: 'refresh';
  jti: string;
};

export function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

export function generateOpaqueToken(): string {
  return randomBytes(48).toString('base64url');
}

export function signAccessToken(userId: string, role: Role): string {
  const payload: AccessPayload = { sub: userId, role, typ: 'access' };
  return jwt.sign(payload, env.JWT_ACCESS_SECRET, {
    expiresIn: env.JWT_ACCESS_EXPIRES_IN as jwt.SignOptions['expiresIn'],
  });
}

export function signRefreshJwt(userId: string, role: Role, jti: string): string {
  const payload: RefreshPayload = { sub: userId, role, typ: 'refresh', jti };
  return jwt.sign(payload, env.JWT_REFRESH_SECRET, {
    expiresIn: env.JWT_REFRESH_EXPIRES_IN as jwt.SignOptions['expiresIn'],
  });
}

export function verifyAccessToken(token: string): AccessPayload {
  try {
    const decoded = jwt.verify(token, env.JWT_ACCESS_SECRET) as AccessPayload;
    if (decoded.typ !== 'access' || !decoded.sub) {
      throw new UnauthorizedError('Invalid access token');
    }
    return decoded;
  } catch {
    throw new UnauthorizedError('Invalid or expired access token');
  }
}

export function verifyRefreshJwt(token: string): RefreshPayload {
  try {
    const decoded = jwt.verify(token, env.JWT_REFRESH_SECRET) as RefreshPayload;
    if (decoded.typ !== 'refresh' || !decoded.sub || !decoded.jti) {
      throw new UnauthorizedError('Invalid refresh token');
    }
    return decoded;
  } catch {
    throw new UnauthorizedError('Invalid or expired refresh token');
  }
}

export function parseDurationToMs(input: string): number {
  const match = /^(\d+)([smhd])$/.exec(input);
  if (!match) {
    return 30 * 24 * 60 * 60 * 1000;
  }
  const value = Number(match[1]);
  const unit = match[2];
  switch (unit) {
    case 's':
      return value * 1000;
    case 'm':
      return value * 60 * 1000;
    case 'h':
      return value * 60 * 60 * 1000;
    case 'd':
      return value * 24 * 60 * 60 * 1000;
    default:
      return 30 * 24 * 60 * 60 * 1000;
  }
}
