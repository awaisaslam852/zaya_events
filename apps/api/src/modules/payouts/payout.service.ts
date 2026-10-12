import { PayoutStatus } from '@prisma/client';
import { NotFoundError } from '../../lib/errors.js';
import { notDeleted, paginated, skipTake } from '../../lib/common.js';
import { notificationService } from '../notifications/notification.service.js';
import { payoutRepository } from './payout.repository.js';
import type { z } from 'zod';
import type { payoutCreateSchema, payoutListQuery } from './payout.schema.js';

export const payoutService = {
  async list(query: z.infer<typeof payoutListQuery>) {
    const { skip, take } = skipTake(query);
    const [items, total] = await payoutRepository.list(
      {
        ...notDeleted,
        ...(query.vendorId ? { vendorId: query.vendorId } : {}),
        ...(query.status ? { status: query.status } : {}),
      },
      skip,
      take,
    );
    return paginated(items, total, query);
  },
  async create(input: z.infer<typeof payoutCreateSchema>) {
    return payoutRepository.create({
      vendor: { connect: { id: input.vendorId } },
      amount: input.amount,
      currency: input.currency,
      status: PayoutStatus.PENDING,
    });
  },
  async markPaid(id: string) {
    const row = await payoutRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Payout not found');
    }
    const updated = await payoutRepository.update(id, { status: PayoutStatus.PAID, processedAt: new Date() });
    await notificationService.notify({
      userId: row.vendor.userId,
      title: { en: 'Payout sent', ar: 'تم إرسال الدفعة' },
      body: { en: 'A payout has been marked as paid.', ar: 'تم تعليم دفعة كمُسددة.' },
      data: { type: 'payout_paid', payoutId: id },
    });
    return updated;
  },
};
