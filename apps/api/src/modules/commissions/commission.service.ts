import { Prisma } from '@prisma/client';
import { notDeleted, paginated, skipTake } from '../../lib/common.js';
import { commissionRepository } from './commission.repository.js';
import type { z } from 'zod';
import type { commissionListQuery, commissionRateBody } from './commission.schema.js';

export const commissionService = {
  async ledger(query: z.infer<typeof commissionListQuery>) {
    const { skip, take } = skipTake(query);
    const [items, total] = await commissionRepository.listLedger(
      { ...notDeleted, ...(query.vendorId ? { vendorId: query.vendorId } : {}) },
      skip,
      take,
    );
    return paginated(items, total, query);
  },
  rates() {
    return commissionRepository.listRates();
  },
  createRate(input: z.infer<typeof commissionRateBody>) {
    return commissionRepository.createRate({
      name: input.name as Prisma.InputJsonValue,
      rate: input.rate,
      bookingType: input.bookingType,
      isDefault: input.isDefault,
      isActive: input.isActive,
    });
  },
  updateRate(id: string, input: Partial<z.infer<typeof commissionRateBody>>) {
    return commissionRepository.updateRate(id, {
      ...(input.name ? { name: input.name as Prisma.InputJsonValue } : {}),
      ...(input.rate !== undefined ? { rate: input.rate } : {}),
      ...(input.bookingType !== undefined ? { bookingType: input.bookingType } : {}),
      ...(input.isDefault !== undefined ? { isDefault: input.isDefault } : {}),
      ...(input.isActive !== undefined ? { isActive: input.isActive } : {}),
    });
  },
};
