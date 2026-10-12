import type { NextFunction, Request, Response } from 'express';
import { Role, type Vendor } from '@prisma/client';
import { z } from 'zod';
import { env } from '../config/env.js';
import { ForbiddenError, NotFoundError } from './errors.js';
import { prisma } from './prisma.js';

export const localizedString = z.object({
  en: z.string().min(1),
  ar: z.string().min(1),
});

export const idParamSchema = z.object({
  id: z.string().uuid(),
});

export const paginationQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(20),
});

export type PaginationQuery = z.infer<typeof paginationQuerySchema>;

export function skipTake(query: PaginationQuery): { skip: number; take: number } {
  return { skip: (query.page - 1) * query.pageSize, take: query.pageSize };
}

export function paginated<T>(items: T[], total: number, query: PaginationQuery) {
  return {
    items,
    total,
    page: query.page,
    pageSize: query.pageSize,
    pageCount: Math.ceil(total / query.pageSize),
  };
}

/** Turn a storage key (`banners/x.webp`) or path into a publicly fetchable URL. */
export function mediaPublicUrl(value: string | null | undefined): string {
  if (!value) {
    return '';
  }
  const trimmed = value.trim();
  if (!trimmed) {
    return '';
  }
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  const path = trimmed.startsWith('/') ? trimmed : `/uploads/${trimmed.replace(/^uploads\//, '')}`;
  return `${env.STORAGE_PUBLIC_URL.replace(/\/+$/, '')}${path}`;
}

/** Rewrite loopback file URLs so Android/emulators can load `/uploads` from the same host they used for the API. */
export function publicAssetUrl(req: Request, url: string): string {
  const host = req.get('host');
  const resolved = mediaPublicUrl(url);
  if (!host || !resolved) {
    return resolved || url;
  }
  try {
    const parsed = resolved.startsWith('http') ? new URL(resolved) : new URL(resolved, `${req.protocol}://${host}`);
    if (parsed.hostname === 'localhost' || parsed.hostname === '127.0.0.1') {
      parsed.protocol = `${req.protocol}:`;
      parsed.host = host;
      return parsed.toString();
    }
    return parsed.toString();
  } catch {
    return resolved;
  }
}

export function handle(
  fn: (req: Request, res: Response) => Promise<void>,
): (req: Request, res: Response, next: NextFunction) => void {
  return (req, res, next) => {
    void fn(req, res).catch(next);
  };
}

export function actor(req: Request): { id: string; role: Role; email: string } {
  if (!req.user) {
    throw new ForbiddenError();
  }
  return req.user;
}

export async function findVendorForUser(userId: string): Promise<Vendor> {
  const vendor = await prisma.vendor.findFirst({
    where: { userId, deletedAt: null },
  });
  if (!vendor) {
    throw new ForbiddenError('Vendor profile is required');
  }
  return vendor;
}

export async function assertOwnedVendor(userId: string, role: Role, vendorId: string): Promise<Vendor> {
  if (role === Role.ADMIN) {
    const vendor = await prisma.vendor.findFirst({ where: { id: vendorId, deletedAt: null } });
    if (!vendor) {
      throw new NotFoundError('Vendor not found');
    }
    return vendor;
  }
  const vendor = await findVendorForUser(userId);
  if (vendor.id !== vendorId) {
    throw new ForbiddenError();
  }
  return vendor;
}

export const notDeleted = { deletedAt: null };
