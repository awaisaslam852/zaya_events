import bcrypt from 'bcryptjs';
import { Role, UserStatus, VendorStatus, type Prisma } from '@prisma/client';
import { env } from '../../config/env.js';
import { writeAdminAudit } from '../../lib/admin-audit.js';
import { adminScope, assignableCountry, assertCountryAllowed, countryWhere } from '../../lib/admin-scope.js';
import type { AuthUser } from '../../middleware/auth.js';
import { ConflictError, ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { notDeleted, paginated, skipTake } from '../../lib/common.js';
import { prisma } from '../../lib/prisma.js';
import { reviewService } from '../reviews/review.service.js';
import { authRepository } from '../auth/auth.repository.js';
import { notificationService } from '../notifications/notification.service.js';
import { vendorRepository } from './vendor.repository.js';
import type { z } from 'zod';
import type { vendorAdminCreateSchema, vendorApplySchema, vendorListQuery, vendorProfilePatch } from './vendor.schema.js';

export const vendorService = {
  async list(role: Role, query: z.infer<typeof vendorListQuery>, actor?: AuthUser) {
    const { skip, take } = skipTake(query);
    const where: Prisma.VendorWhereInput = {
      ...notDeleted,
      ...countryWhere(adminScope(actor)),
      ...(query.status ? { status: query.status } : role === Role.ADMIN ? {} : { status: VendorStatus.APPROVED }),
      ...(role !== Role.ADMIN && query.country ? { country: query.country } : {}),
      ...(query.city ? { city: query.city } : {}),
      ...(query.q
        ? {
            OR: [
              { city: { contains: query.q, mode: 'insensitive' } },
              { phone: { contains: query.q, mode: 'insensitive' } },
              { user: { email: { contains: query.q, mode: 'insensitive' } } },
              { user: { firstName: { contains: query.q, mode: 'insensitive' } } },
              { user: { lastName: { contains: query.q, mode: 'insensitive' } } },
            ],
          }
        : {}),
    };
    const [items, total] = await vendorRepository.list(where, skip, take);
    return paginated(items, total, query);
  },
  async get(id: string, actor?: AuthUser) {
    const row = await vendorRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Vendor not found');
    }
    if (actor?.role === Role.ADMIN) {
      assertCountryAllowed(adminScope(actor), row.country);
    }
    return row;
  },
  async me(userId: string, role: Role) {
    const row = await vendorRepository.findByUserId(userId);
    if (!row) {
      throw new NotFoundError('Vendor profile not found');
    }
    const full = await this.get(row.id);
    if (role === Role.ADMIN) {
      return full;
    }
    const entries = Object.entries(full).filter(([key]) => key !== 'commissionRate');
    const safe = Object.fromEntries(entries) as Omit<typeof full, 'commissionRate'>;
    return {
      ...safe,
      payouts: (full.payouts ?? []).map((p) => ({
        id: p.id,
        amount: p.amount,
        currency: p.currency,
        status: p.status,
        createdAt: p.createdAt,
        processedAt: p.processedAt,
      })),
    };
  },
  async earnings(userId: string) {
    const vendor = await vendorRepository.findByUserId(userId);
    if (!vendor) {
      throw new NotFoundError('Vendor profile not found');
    }
    const [bookings, payouts] = await Promise.all([
      prisma.booking.findMany({
        where: { vendorId: vendor.id, deletedAt: null },
        select: {
          id: true,
          bookingNumber: true,
          status: true,
          totalAmount: true,
          depositAmount: true,
          balanceAmount: true,
          currency: true,
          createdAt: true,
        },
        orderBy: { createdAt: 'desc' },
        take: 50,
      }),
      prisma.payout.findMany({
        where: { vendorId: vendor.id, deletedAt: null },
        select: { id: true, amount: true, currency: true, status: true, createdAt: true, processedAt: true },
        orderBy: { createdAt: 'desc' },
        take: 50,
      }),
    ]);
    const totals = bookings.reduce(
      (acc, row) => ({
        total: acc.total + Number(row.totalAmount),
        deposits: acc.deposits + Number(row.depositAmount),
        balances: acc.balances + Number(row.balanceAmount),
      }),
      { total: 0, deposits: 0, balances: 0 },
    );
    return { totals, bookings, payouts };
  },
  async reviews(userId: string) {
    const vendor = await vendorRepository.findByUserId(userId);
    if (!vendor) {
      throw new NotFoundError('Vendor profile not found');
    }
    const listings = await prisma.listing.findMany({
      where: { vendorId: vendor.id, deletedAt: null },
      select: { id: true, title: true, ratingAvg: true, ratingCount: true, isPublished: true },
      orderBy: { ratingCount: 'desc' },
    });
    const venues = await prisma.venue.findMany({
      where: { vendorId: vendor.id, deletedAt: null },
      select: { id: true, name: true, ratingAvg: true, ratingCount: true },
      orderBy: { ratingCount: 'desc' },
    });
    const incoming = await reviewService.forVendor(userId);
    return {
      ratingAvg: incoming.ratingAvg,
      ratingCount: incoming.ratingCount,
      listings,
      venues,
      items: incoming.items,
    };
  },
  async apply(userId: string, input: z.infer<typeof vendorApplySchema>) {
    const existing = await vendorRepository.findByUserId(userId);
    if (existing) {
      throw new ConflictError('Vendor profile already exists');
    }
    await prisma.user.update({ where: { id: userId }, data: { role: 'VENDOR' } });
    return vendorRepository.create({
      user: { connect: { id: userId } },
      businessName: input.businessName,
      description: input.description,
      legalName: input.legalName,
      taxId: input.taxId,
      city: input.city,
      country: input.country,
      phone: input.phone,
      website: input.website,
      status: VendorStatus.PENDING,
    });
  },
  async updateProfile(
    userId: string,
    role: Role,
    vendorId: string | undefined,
    input: z.infer<typeof vendorProfilePatch>,
    actor?: AuthUser,
  ) {
    const vendor =
      role === Role.ADMIN && vendorId
        ? await vendorRepository.findById(vendorId)
        : await vendorRepository.findByUserId(userId);
    if (!vendor) {
      throw new NotFoundError('Vendor profile not found');
    }
    if (role === Role.ADMIN) {
      assertCountryAllowed(adminScope(actor), vendor.country);
      if (input.country) {
        assignableCountry(adminScope(actor), input.country);
      }
    }
    if (role !== Role.ADMIN && (input.commissionRate !== undefined || input.status !== undefined)) {
      throw new ForbiddenError('Commission rate can only be changed by admin');
    }
    const { commissionRate, galleryKeys, serviceAreas, notificationPrefs, firstName, lastName, ...rest } = input;
    if (role === Role.ADMIN && (firstName || lastName || rest.phone)) {
      const account = await prisma.user.findUnique({ where: { id: vendor.userId } });
      await prisma.user.update({
        where: { id: vendor.userId },
        data: {
          ...(firstName ? { firstName } : {}),
          ...(lastName ? { lastName } : {}),
          ...(rest.phone ? { phone: rest.phone } : {}),
          displayName: `${firstName ?? account?.firstName ?? ''} ${lastName ?? account?.lastName ?? ''}`.trim() || undefined,
        },
      });
    }
    return vendorRepository.update(vendor.id, {
      ...rest,
      ...(role === Role.ADMIN && commissionRate !== undefined ? { commissionRate } : {}),
      ...(galleryKeys ? { galleryKeys: galleryKeys as Prisma.InputJsonValue } : {}),
      ...(serviceAreas ? { serviceAreas: serviceAreas as Prisma.InputJsonValue } : {}),
      ...(notificationPrefs ? { notificationPrefs: notificationPrefs as Prisma.InputJsonValue } : {}),
    });
  },
  async approve(id: string, actor?: AuthUser) {
    const vendor = await this.get(id, actor);
    const updated = await vendorRepository.update(id, { status: VendorStatus.APPROVED });
    await notificationService.notify({
      userId: vendor.userId,
      title: { en: 'Vendor approved', ar: 'تمت الموافقة على حساب المورد' },
      body: { en: 'Your vendor account is approved.', ar: 'تمت الموافقة على حساب المورد الخاص بك.' },
      data: { type: 'vendor_approved', vendorId: id },
    });
    if (actor) {
      await writeAdminAudit({
        actorId: actor.id,
        action: 'vendor.approve',
        entityType: 'Vendor',
        entityId: id,
        country: vendor.country,
      });
    }
    return updated;
  },
  async createByAdmin(input: z.infer<typeof vendorAdminCreateSchema>, actor?: AuthUser) {
    const existing = await authRepository.findActiveByEmail(input.email);
    if (existing) {
      throw new ConflictError('An account with this email already exists');
    }
    const passwordHash = await bcrypt.hash(input.password, env.BCRYPT_ROUNDS);
    const businessName = input.businessName;
    const country = assignableCountry(adminScope(actor), input.country) ?? input.country;
    const user = await authRepository.createVendor({
      email: input.email,
      passwordHash,
      firstName: input.firstName,
      lastName: input.lastName,
      phone: input.phone,
      locale: input.locale,
      country,
      city: input.city,
      legalName: input.legalName?.trim() || businessName.en,
      website: input.website,
      businessName,
      description: input.description ?? { en: '', ar: '' },
      approved: true,
    });
    if (!user.vendor) {
      throw new NotFoundError('Vendor profile not found');
    }
    return this.get(user.vendor.id, actor);
  },
  async remove(id: string, actor?: AuthUser) {
    const vendor = await this.get(id, actor);
    await vendorRepository.update(id, { deletedAt: new Date(), status: VendorStatus.SUSPENDED });
    await prisma.user.update({
      where: { id: vendor.userId },
      data: { deletedAt: new Date(), status: UserStatus.INACTIVE },
    });
    await authRepository.revokeAllRefreshTokens(vendor.userId);
    return { deleted: true };
  },
  async reject(id: string, reason?: string, actor?: AuthUser) {
    const vendor = await this.get(id, actor);
    const updated = await vendorRepository.update(id, { status: VendorStatus.REJECTED });
    await notificationService.notify({
      userId: vendor.userId,
      title: { en: 'Vendor application rejected', ar: 'رُفض طلب المورد' },
      body: {
        en: reason ?? 'Your vendor application was rejected.',
        ar: reason ?? 'تم رفض طلب حساب المورد.',
      },
      data: { type: 'vendor_rejected', vendorId: id },
    });
    return updated;
  },
};
