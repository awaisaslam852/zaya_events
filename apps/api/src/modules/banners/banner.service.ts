import { NotFoundError } from '../../lib/errors.js';
import { notDeleted, paginated, skipTake } from '../../lib/common.js';
import { bannerRepository } from './banner.repository.js';
import type { z } from 'zod';
import type { bannerBody, bannerListQuery, bannerPatch } from './banner.schema.js';

export const bannerService = {
  async list(query: z.infer<typeof bannerListQuery>, admin: boolean) {
    const { skip, take } = skipTake(query);
    const now = new Date();
    const [items, total] = await bannerRepository.list(
      {
        ...notDeleted,
        ...(query.placement ? { placement: query.placement } : {}),
        ...(admin
          ? {}
          : {
              isActive: true,
              AND: [
                { OR: [{ startsAt: null }, { startsAt: { lte: now } }] },
                { OR: [{ endsAt: null }, { endsAt: { gte: now } }] },
              ],
            }),
      },
      skip,
      take,
    );
    return paginated(items, total, query);
  },
  async create(input: z.infer<typeof bannerBody>) {
    return bannerRepository.create(input);
  },
  async update(id: string, input: z.infer<typeof bannerPatch>) {
    const row = await bannerRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Banner not found');
    }
    return bannerRepository.update(id, input);
  },
  async remove(id: string) {
    const row = await bannerRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Banner not found');
    }
    await bannerRepository.update(id, { deletedAt: new Date(), isActive: false });
    return { deleted: true };
  },
};
