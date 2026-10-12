import { Role } from '@prisma/client';
import type { NextFunction, Request, Response } from 'express';
import { ForbiddenError, UnauthorizedError } from '../lib/errors.js';

export type RoleName = 'admin' | 'vendor' | 'customer';

const ROLE_MAP: Record<RoleName, Role> = {
  admin: Role.ADMIN,
  vendor: Role.VENDOR,
  customer: Role.CUSTOMER,
};

function toPrismaRole(role: RoleName | Role): Role {
  if (role === Role.ADMIN || role === Role.VENDOR || role === Role.CUSTOMER) {
    return role;
  }
  return ROLE_MAP[role];
}

export function requireRole(...roles: Array<RoleName | Role>) {
  const allowed = roles.map(toPrismaRole);
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user) {
      next(new UnauthorizedError());
      return;
    }
    if (!allowed.includes(req.user.role)) {
      next(new ForbiddenError());
      return;
    }
    next();
  };
}
