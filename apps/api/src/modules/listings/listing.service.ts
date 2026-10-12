import { Prisma, Role } from '@prisma/client';
import { ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { findVendorForUser, notDeleted, paginated, skipTake } from '../../lib/common.js';
import { listingRepository } from './listing.repository.js';
import { serviceCategoryRepository } from '../service-categories/service-category.repository.js';
import { prisma } from '../../lib/prisma.js';
import type { z } from 'zod';
import type { listingBody, listingListQuery, listingPackageBody, listingPatch } from './listing.schema.js';

export const listingService = {
  async list(query: z.infer<typeof listingListQuery>, user?: { id: string; role: Role }) {
    const { skip, take } = skipTake(query);
    let vendorScope: string | undefined = query.vendorId;
    if (user?.role === Role.VENDOR) {
      const vendor = await findVendorForUser(user.id);
      vendorScope = vendor.id;
    }
    const where: Prisma.ListingWhereInput = {
      ...notDeleted,
      ...(query.categoryId ? { categoryId: query.categoryId } : {}),
      ...(vendorScope ? { vendorId: vendorScope } : {}),
      ...(query.city ? { city: query.city } : {}),
      ...(user?.role === Role.ADMIN || user?.role === Role.VENDOR
        ? query.published === 'true'
          ? { isPublished: true }
          : query.published === 'false'
            ? { isPublished: false }
            : {}
        : { isPublished: true }),
    };
    const [items, total] = await listingRepository.list(where, skip, take);
    return paginated(items, total, query);
  },
  async get(id: string) {
    const row = await listingRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Listing not found');
    }
    return row;
  },
  async create(userId: string, role: Role, input: z.infer<typeof listingBody>) {
    const vendor = await findVendorForUser(userId);
    if (role !== Role.ADMIN && vendor.userId !== userId) {
      throw new ForbiddenError();
    }
    const category = await serviceCategoryRepository.findById(input.categoryId);
    if (!category?.isActive) {
      throw new NotFoundError('Service category not found');
    }
    return listingRepository.create({
      vendor: { connect: { id: vendor.id } },
      category: { connect: { id: input.categoryId } },
      title: input.title,
      description: input.description,
      city: input.city,
      country: input.country,
      coverKey: input.coverKey,
      galleryKeys: (input.galleryKeys ?? []) as Prisma.InputJsonValue,
      startingPrice: input.startingPrice,
      currency: input.currency,
      isPublished: input.isPublished,
      customFieldValues: input.customFieldValues as Prisma.InputJsonValue,
      packages: {
        create: (input.packages ?? []).map((pkg) => ({
          name: pkg.name,
          description: pkg.description,
          priceAmount: pkg.priceAmount,
          currency: pkg.currency,
          durationHours: pkg.durationHours,
          isActive: pkg.isActive,
        })),
      },
    });
  },
  async update(userId: string, role: Role, id: string, input: z.infer<typeof listingPatch>) {
    const row = await this.assertOwner(userId, role, id);
    return listingRepository.update(row.id, {
      title: input.title,
      description: input.description,
      city: input.city,
      country: input.country,
      coverKey: input.coverKey,
      galleryKeys: input.galleryKeys as Prisma.InputJsonValue | undefined,
      startingPrice: input.startingPrice,
      currency: input.currency,
      isPublished: input.isPublished,
      customFieldValues: input.customFieldValues as Prisma.InputJsonValue,
      ...(input.categoryId ? { category: { connect: { id: input.categoryId } } } : {}),
    });
  },
  async remove(userId: string, role: Role, id: string) {
    const row = await this.assertOwner(userId, role, id);
    await listingRepository.update(row.id, { deletedAt: new Date() });
    return { deleted: true };
  },
  async addPackage(userId: string, role: Role, listingId: string, input: z.infer<typeof listingPackageBody>) {
    await this.assertOwner(userId, role, listingId);
    return prisma.listingPackage.create({
      data: {
        listing: { connect: { id: listingId } },
        name: input.name as Prisma.InputJsonValue,
        description: input.description as Prisma.InputJsonValue,
        priceAmount: input.priceAmount,
        currency: input.currency,
        durationHours: input.durationHours,
        isActive: input.isActive,
      },
    });
  },
  async updatePackage(
    userId: string,
    role: Role,
    listingId: string,
    packageId: string,
    input: Partial<z.infer<typeof listingPackageBody>>,
  ) {
    await this.assertOwner(userId, role, listingId);
    const pkg = await prisma.listingPackage.findFirst({ where: { id: packageId, listingId, deletedAt: null } });
    if (!pkg) {
      throw new NotFoundError('Package not found');
    }
    return prisma.listingPackage.update({
      where: { id: packageId },
      data: {
        ...(input.name ? { name: input.name as Prisma.InputJsonValue } : {}),
        ...(input.description ? { description: input.description as Prisma.InputJsonValue } : {}),
        ...(input.priceAmount !== undefined ? { priceAmount: input.priceAmount } : {}),
        ...(input.currency ? { currency: input.currency } : {}),
        ...(input.durationHours !== undefined ? { durationHours: input.durationHours } : {}),
        ...(input.isActive !== undefined ? { isActive: input.isActive } : {}),
      },
    });
  },
  async assertOwner(userId: string, role: Role, id: string) {
    const row = await this.get(id);
    if (role !== Role.ADMIN) {
      const vendor = await findVendorForUser(userId);
      if (row.vendorId !== vendor.id) {
        throw new ForbiddenError();
      }
    }
    return row;
  },
};
