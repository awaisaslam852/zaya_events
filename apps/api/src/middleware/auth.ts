import type { NextFunction, Request, Response } from 'express';
import type { Role } from '@prisma/client';
import { UnauthorizedError } from '../lib/errors.js';
import { verifyAccessToken } from '../modules/auth/auth.tokens.js';
import { authRepository } from '../modules/auth/auth.repository.js';
import { requireRole } from './rbac.js';

export { requireRole };

export type AuthUser = {
  id: string;
  email: string;
  role: Role;
};

declare global {
  namespace Express {
    interface Request {
      user?: AuthUser;
    }
  }
}

export async function optionalAuth(req: Request, _res: Response, next: NextFunction): Promise<void> {
  const header = req.header('authorization');
  if (!header?.startsWith('Bearer ')) {
    next();
    return;
  }
  try {
    const token = header.slice('Bearer '.length);
    const payload = verifyAccessToken(token);
    const user = await authRepository.findActiveById(payload.sub);
    if (user) {
      req.user = { id: user.id, email: user.email, role: user.role };
    }
  } catch {
    /* public list still works without a valid token */
  }
  next();
}

export async function requireAuth(req: Request, _res: Response, next: NextFunction): Promise<void> {
  try {
    const header = req.header('authorization');
    if (!header?.startsWith('Bearer ')) {
      throw new UnauthorizedError('Missing bearer token');
    }
    const token = header.slice('Bearer '.length);
    const payload = verifyAccessToken(token);
    const user = await authRepository.findActiveById(payload.sub);
    if (!user) {
      throw new UnauthorizedError('Account not found');
    }
    req.user = { id: user.id, email: user.email, role: user.role };
    next();
  } catch (error) {
    next(error);
  }
}
