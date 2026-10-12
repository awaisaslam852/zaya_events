import { randomUUID } from 'node:crypto';
import { Role, type Prisma } from '@prisma/client';
import { ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { notDeleted, paginated, skipTake } from '../../lib/common.js';
import { eventCategoryRepository } from '../event-categories/event-category.repository.js';
import { eventRepository } from './event.repository.js';
import type { z } from 'zod';
import type { eventBody, eventListQuery, eventPatch } from './event.schema.js';

function defaultChecklist() {
  const items = [
    { en: 'Confirm venue', ar: 'تأكيد القاعة' },
    { en: 'Book vendors and services', ar: 'حجز الموردين والخدمات' },
    { en: 'Arrange venue visit', ar: 'ترتيب زيارة القاعة' },
    { en: 'Book event car', ar: 'حجز سيارة المناسبة' },
    { en: 'Book stay or honeymoon', ar: 'حجز الإقامة أو شهر العسل' },
    { en: 'Review budget', ar: 'مراجعة الميزانية' },
  ];
  return items.map((title) => ({ id: randomUUID(), title, done: false }));
}

function hub(event: Awaited<ReturnType<typeof eventRepository.findById>>) {
  if (!event) {
    return event;
  }
  const bookings = event.bookings ?? [];
  const paid = bookings.reduce((sum, booking) => {
    const captured = (booking.payments ?? []).filter((p) =>
      ['SUCCEEDED', 'PAID', 'CAPTURED'].includes(p.status),
    );
    return sum + captured.reduce((s, p) => s + Number(p.amount), 0);
  }, 0);
  const total = bookings.reduce((sum, booking) => sum + Number(booking.totalAmount ?? 0), 0);
  return {
    ...event,
    cost: {
      currency: event.currency,
      bookingsTotal: total,
      paid,
      remaining: Math.max(0, total - paid),
      budgetMin: event.budgetMin,
      budgetMax: event.budgetMax,
    },
  };
}

function scope(userId: string, role: Role): Prisma.EventWhereInput {
  if (role === Role.ADMIN) {
    return notDeleted;
  }
  return { customerId: userId, ...notDeleted };
}

export const eventService = {
  async list(userId: string, role: Role, query: z.infer<typeof eventListQuery>) {
    const { skip, take } = skipTake(query);
    const where: Prisma.EventWhereInput = {
      ...scope(userId, role),
      ...(query.status ? { status: query.status } : {}),
      ...(query.categoryId ? { categoryId: query.categoryId } : {}),
      ...(query.customerId && role === Role.ADMIN ? { customerId: query.customerId } : {}),
    };
    const [items, total] = await eventRepository.list(where, skip, take);
    return paginated(items, total, query);
  },
  async get(userId: string, role: Role, id: string) {
    const row = await eventRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Event not found');
    }
    if (role !== Role.ADMIN && row.customerId !== userId) {
      throw new ForbiddenError();
    }
    return hub(row);
  },
  async create(userId: string, input: z.infer<typeof eventBody>) {
    const category = await eventCategoryRepository.findById(input.categoryId);
    if (!category || !category.isActive) {
      throw new NotFoundError('Event category not found');
    }
    return eventRepository.create({
      customer: { connect: { id: userId } },
      category: { connect: { id: input.categoryId } },
      title: input.title,
      description: input.description,
      notes: input.notes,
      preferredVenueType: input.preferredVenueType,
      eventDate: input.eventDate,
      endDate: input.endDate,
      guestCount: input.guestCount,
      city: input.city,
      country: input.country,
      budgetMin: input.budgetMin,
      budgetMax: input.budgetMax,
      currency: input.currency,
      status: input.status,
      checklist: input.checklist ?? defaultChecklist(),
    });
  },
  async update(userId: string, role: Role, id: string, input: z.infer<typeof eventPatch>) {
    await this.get(userId, role, id);
    const { categoryId, ...rest } = input;
    await eventRepository.update(id, {
      ...rest,
      ...(categoryId ? { category: { connect: { id: categoryId } } } : {}),
    });
    return this.get(userId, role, id);
  },
  async remove(userId: string, role: Role, id: string) {
    await this.get(userId, role, id);
    await eventRepository.update(id, { deletedAt: new Date() });
    return { deleted: true };
  },
};
