import { PayoutStatus } from '@prisma/client';
import { writeAdminAudit } from '../../lib/admin-audit.js';
import { adminScope, assertCountryAllowed, viaVendorCountry } from '../../lib/admin-scope.js';
import { currencyForCountry } from '../../lib/countries.js';
import type { AuthUser } from '../../middleware/auth.js';
import { NotFoundError } from '../../lib/errors.js';
import { notDeleted, paginated, skipTake } from '../../lib/common.js';
import { prisma } from '../../lib/prisma.js';
import { notificationService } from '../notifications/notification.service.js';
import { payoutRepository } from './payout.repository.js';
import type { z } from 'zod';
import type { payoutCreateSchema, payoutListQuery } from './payout.schema.js';

export const payoutService = {
  async list(query: z.infer<typeof payoutListQuery>, actor?: AuthUser) {
    const { skip, take } = skipTake(query);
    const [items, total] = await payoutRepository.list(
      {
        ...notDeleted,
        ...viaVendorCountry(adminScope(actor)),
        ...(query.vendorId ? { vendorId: query.vendorId } : {}),
        ...(query.status ? { status: query.status } : {}),
      },
      skip,
      take,
    );
    return paginated(items, total, query);
  },
  async create(input: z.infer<typeof payoutCreateSchema>, actor?: AuthUser) {
    const vendor = await prisma.vendor.findFirst({ where: { id: input.vendorId, ...notDeleted } });
    if (!vendor) {
      throw new NotFoundError('Vendor not found');
    }
    assertCountryAllowed(adminScope(actor), vendor.country);
    return payoutRepository.create({
      vendor: { connect: { id: input.vendorId } },
      amount: input.amount,
      currency: currencyForCountry(vendor.country, input.currency),
      status: PayoutStatus.PENDING,
    });
  },
  async markPaid(id: string, actor?: AuthUser) {
    const row = await payoutRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Payout not found');
    }
    assertCountryAllowed(adminScope(actor), row.vendor.country);
    const updated = await payoutRepository.update(id, { status: PayoutStatus.PAID, processedAt: new Date() });
    await notificationService.notify({
      userId: row.vendor.userId,
      title: { en: 'Payout sent', ar: 'تم إرسال الدفعة' },
      body: { en: 'A payout has been marked as paid.', ar: 'تم تعليم دفعة كمُسددة.' },
      data: { type: 'payout_paid', payoutId: id },
    });
    if (actor) {
      await writeAdminAudit({
        actorId: actor.id,
        action: 'payout.paid',
        entityType: 'Payout',
        entityId: id,
        country: row.vendor.country,
        meta: { amount: String(row.amount), currency: row.currency },
      });
    }
    return updated;
  },
};
