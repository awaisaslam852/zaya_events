import { Prisma } from '@prisma/client';
import { ConflictError, NotFoundError } from '../../lib/errors.js';
import { paginated, skipTake } from '../../lib/common.js';
import { serviceCategoryRepository } from './service-category.repository.js';
import type { z } from 'zod';
import type { serviceCategoryBody, serviceCategoryListQuery, serviceCategoryPatch } from './service-category.schema.js';

export const serviceCategoryService = {
  async list(query: z.infer<typeof serviceCategoryListQuery>) {
    const { skip, take } = skipTake(query);
    const [items, total] = await serviceCategoryRepository.list(
      query.includeInactive === 'true',
      skip,
      take,
      query.q,
    );
    return paginated(items, total, query);
  },
  async get(id: string) {
    const row = await serviceCategoryRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Service category not found');
    }
    return row;
  },
  async create(input: z.infer<typeof serviceCategoryBody>) {
    if (await serviceCategoryRepository.findBySlug(input.slug)) {
      throw new ConflictError('Slug already exists');
    }
    return serviceCategoryRepository.create({
      ...input,
      customFields: input.customFields as Prisma.InputJsonValue,
    });
  },
  async update(id: string, input: z.infer<typeof serviceCategoryPatch>) {
    await this.get(id);
    if (input.slug) {
      const existing = await serviceCategoryRepository.findBySlug(input.slug);
      if (existing && existing.id !== id) {
        throw new ConflictError('Slug already exists');
      }
    }
    return serviceCategoryRepository.update(id, {
      ...input,
      ...(input.customFields ? { customFields: input.customFields as Prisma.InputJsonValue } : {}),
    });
  },
  async setActive(id: string, isActive: boolean) {
    await this.get(id);
    return serviceCategoryRepository.update(id, { isActive });
  },
  async remove(id: string) {
    await this.get(id);
    await serviceCategoryRepository.update(id, { deletedAt: new Date(), isActive: false });
    return { deleted: true };
  },
};
