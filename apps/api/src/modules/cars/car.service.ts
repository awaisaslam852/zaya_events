import { AvailabilityResourceType, BookingType, Role, type Prisma } from '@prisma/client';
import { adminScope, assertCountryAllowed, publicVendorCountry, recordCountry, viaVendorCountry } from '../../lib/admin-scope.js';
import { currencyForCountry } from '../../lib/countries.js';
import { ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { findVendorForUser, notDeleted, paginated, skipTake } from '../../lib/common.js';
import { availabilityRepository } from '../availability/availability.repository.js';
import { bookingService } from '../bookings/booking.service.js';
import { carRepository } from './car.repository.js';
import type { z } from 'zod';
import type { carBody, carBookSchema, carListQuery, carPatch } from './car.schema.js';

export const carService = {
  async list(query: z.infer<typeof carListQuery>, user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] }) {
    const { skip, take } = skipTake(query);
    let vendorId = query.vendorId;
    if (user?.role === Role.VENDOR) {
      const vendor = await findVendorForUser(user.id);
      vendorId = vendor.id;
    }
    const where: Prisma.CarWhereInput = {
      ...notDeleted,
      ...(user?.role === Role.ADMIN ? viaVendorCountry(adminScope(user)) : {}),
      ...(user?.role !== Role.ADMIN && user?.role !== Role.VENDOR ? publicVendorCountry(query.country) : {}),
      ...(vendorId ? { vendorId } : {}),
      ...(user?.role === Role.ADMIN || user?.role === Role.VENDOR ? {} : { isPublished: true }),
      ...(query.seats ? { seats: { gte: query.seats } } : {}),
      ...(query.q
        ? {
            OR: [
              { make: { contains: query.q, mode: 'insensitive' } },
              { model: { contains: query.q, mode: 'insensitive' } },
              { plateNumber: { contains: query.q, mode: 'insensitive' } },
            ],
          }
        : {}),
    };
    const [items, total] = await carRepository.list(where, skip, take);
    return paginated(items, total, query);
  },
  async get(id: string, user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] }) {
    const row = await carRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Car not found');
    }
    if (user?.role === Role.ADMIN) {
      assertCountryAllowed(adminScope(user), recordCountry(row));
    }
    return row;
  },
  async calendar(id: string, from?: Date, to?: Date) {
    await this.get(id);
    const [items] = await availabilityRepository.list({
      resourceType: AvailabilityResourceType.CAR,
      resourceId: id,
      from,
      to,
      skip: 0,
      take: 500,
    });
    return { items };
  },
  async create(userId: string, input: z.infer<typeof carBody>) {
    const vendor = await findVendorForUser(userId);
    return carRepository.create({
      vendor: { connect: { id: vendor.id } },
      ...input,
      currency: currencyForCountry(vendor.country, input.currency),
    });
  },
  async update(
    userId: string,
    role: Role,
    id: string,
    input: z.infer<typeof carPatch>,
    user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] },
  ) {
    const car = await this.get(id, user ?? { id: userId, role });
    if (role !== Role.ADMIN) {
      const vendor = await findVendorForUser(userId);
      if (car.vendorId !== vendor.id) {
        throw new ForbiddenError();
      }
    }
    return carRepository.update(id, input);
  },
  async remove(
    userId: string,
    role: Role,
    id: string,
    user?: { id: string; role: Role; isSuperAdmin?: boolean; allowedCountries?: string[] },
  ) {
    const car = await this.get(id, user ?? { id: userId, role });
    if (role !== Role.ADMIN) {
      const vendor = await findVendorForUser(userId);
      if (car.vendorId !== vendor.id) {
        throw new ForbiddenError();
      }
    }
    await carRepository.update(id, { deletedAt: new Date(), isPublished: false });
    return { deleted: true };
  },
  async book(userId: string, carId: string, input: z.infer<typeof carBookSchema>) {
    await this.get(carId);
    return bookingService.create(userId, {
      type: BookingType.CAR,
      carId,
      eventId: input.eventId,
      startAt: input.startAt,
      endAt: input.endAt,
      notes: input.notes,
    });
  },
};
