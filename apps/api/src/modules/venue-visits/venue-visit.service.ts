import { Role, VenueVisitStatus, type Prisma } from '@prisma/client';
import { ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { findVendorForUser, notDeleted, paginated, skipTake } from '../../lib/common.js';
import { notificationService } from '../notifications/notification.service.js';
import { venueVisitRepository } from './venue-visit.repository.js';
import { prisma } from '../../lib/prisma.js';
import type { z } from 'zod';
import type {
  visitAssignSchema,
  visitDecisionSchema,
  visitListQuery,
  visitNotesSchema,
  visitRequestSchema,
  visitRescheduleSchema,
} from './venue-visit.schema.js';

export const venueVisitService = {
  async list(userId: string, role: Role, query: z.infer<typeof visitListQuery>) {
    const { skip, take } = skipTake(query);
    const where: Prisma.VenueVisitWhereInput = {
      ...notDeleted,
      ...(query.status ? { status: query.status } : {}),
      ...(query.venueId ? { venueId: query.venueId } : {}),
      ...(query.q
        ? {
            OR: [
              { customer: { email: { contains: query.q, mode: 'insensitive' } } },
              { venue: { city: { contains: query.q, mode: 'insensitive' } } },
            ],
          }
        : {}),
      ...(role === Role.ADMIN
        ? {}
        : role === Role.VENDOR
          ? { venue: { vendor: { userId } } }
          : { customerId: userId }),
    };
    const [items, total] = await venueVisitRepository.list(where, skip, take);
    return paginated(items, total, query);
  },
  async get(userId: string, role: Role, id: string) {
    const row = await venueVisitRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Visit not found');
    }
    if (role === Role.CUSTOMER && row.customerId !== userId) {
      throw new ForbiddenError();
    }
    if (role === Role.VENDOR) {
      const vendor = await findVendorForUser(userId);
      if (row.venue.vendorId !== vendor.id) {
        throw new ForbiddenError();
      }
    }
    return row;
  },
  async request(userId: string, input: z.infer<typeof visitRequestSchema>) {
    const venue = await prisma.venue.findFirst({ where: { id: input.venueId, ...notDeleted } });
    if (!venue) {
      throw new NotFoundError('Venue not found');
    }
    const visit = await venueVisitRepository.create({
      customer: { connect: { id: userId } },
      venue: { connect: { id: input.venueId } },
      ...(input.eventId ? { event: { connect: { id: input.eventId } } } : {}),
      scheduledAt: input.scheduledAt,
      notes: input.notes,
      status: VenueVisitStatus.REQUESTED,
    });
    if (venue.vendorId) {
      const vendor = await prisma.vendor.findFirst({ where: { id: venue.vendorId } });
      if (vendor) {
        await notificationService.notify({
          userId: vendor.userId,
          title: { en: 'Venue visit requested', ar: 'طلب زيارة قاعة' },
          body: { en: 'A customer requested a venue visit.', ar: 'طلب عميل زيارة القاعة.' },
          data: { type: 'venue_visit', visitId: visit.id },
        });
      }
    }
    return visit;
  },
  async approve(userId: string, role: Role, id: string) {
    await this.get(userId, role, id);
    return venueVisitRepository.update(id, { status: VenueVisitStatus.APPROVED });
  },
  async reschedule(userId: string, role: Role, id: string, input: z.infer<typeof visitRescheduleSchema>) {
    await this.get(userId, role, id);
    return venueVisitRepository.update(id, {
      status: VenueVisitStatus.RESCHEDULED,
      scheduledAt: input.scheduledAt,
      notes: input.notes,
    });
  },
  async assign(userId: string, role: Role, id: string, input: z.infer<typeof visitAssignSchema>) {
    await this.get(userId, role, id);
    const representative = await prisma.representative.findFirst({
      where: { id: input.representativeId, ...notDeleted },
    });
    if (!representative) {
      throw new NotFoundError('Representative not found');
    }
    return venueVisitRepository.update(id, {
      representative: { connect: { id: representative.id } },
      status: VenueVisitStatus.CONFIRMED,
    });
  },
  async notes(userId: string, role: Role, id: string, input: z.infer<typeof visitNotesSchema>) {
    await this.get(userId, role, id);
    return venueVisitRepository.update(id, { notes: input.notes });
  },
  async decide(userId: string, role: Role, id: string, input: z.infer<typeof visitDecisionSchema>) {
    const visit = await this.get(userId, role, id);
    if (role === Role.CUSTOMER && visit.customerId !== userId) {
      throw new ForbiddenError();
    }
    return venueVisitRepository.update(id, {
      status: VenueVisitStatus.DECIDED,
      decision: { accepted: input.accepted, notes: input.notes },
      decisionAt: new Date(),
    });
  },
  async complete(userId: string, role: Role, id: string) {
    await this.get(userId, role, id);
    return venueVisitRepository.update(id, { status: VenueVisitStatus.COMPLETED });
  },
  async cancel(userId: string, role: Role, id: string) {
    await this.get(userId, role, id);
    return venueVisitRepository.update(id, { status: VenueVisitStatus.CANCELLED });
  },
};
