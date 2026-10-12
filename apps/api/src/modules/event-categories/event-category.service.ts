import { Prisma } from '@prisma/client';
import { ConflictError, NotFoundError } from '../../lib/errors.js';
import { paginated, skipTake } from '../../lib/common.js';
import { eventCategoryRepository } from './event-category.repository.js';
import type { z } from 'zod';
import type { eventCategoryBody, eventCategoryListQuery, eventCategoryPatch } from './event-category.schema.js';

export const eventCategoryService = {
  async list(query: z.infer<typeof eventCategoryListQuery>) {
    const { skip, take } = skipTake(query);
    const [items, total] = await eventCategoryRepository.list(
      query.includeInactive === 'true',
      skip,
      take,
      query.q,
    );
    return paginated(items, total, query);
  },
  async get(id: string) {
    const row = await eventCategoryRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Event category not found');
    }
    return row;
  },
  async create(input: z.infer<typeof eventCategoryBody>) {
    const existing = await eventCategoryRepository.findBySlug(input.slug);
    if (existing) {
      throw new ConflictError('Slug already exists');
    }
    return eventCategoryRepository.create({
      ...input,
      customFields: input.customFields as Prisma.InputJsonValue,
    });
  },
  async update(id: string, input: z.infer<typeof eventCategoryPatch>) {
    await this.get(id);
    if (input.slug) {
      const existing = await eventCategoryRepository.findBySlug(input.slug);
      if (existing && existing.id !== id) {
        throw new ConflictError('Slug already exists');
      }
    }
    return eventCategoryRepository.update(id, {
      ...input,
      ...(input.customFields ? { customFields: input.customFields as Prisma.InputJsonValue } : {}),
    });
  },
  async setActive(id: string, isActive: boolean) {
    await this.get(id);
    return eventCategoryRepository.update(id, { isActive });
  },
  async remove(id: string) {
    await this.get(id);
    await eventCategoryRepository.update(id, { deletedAt: new Date(), isActive: false });
    return { deleted: true };
  },
};
