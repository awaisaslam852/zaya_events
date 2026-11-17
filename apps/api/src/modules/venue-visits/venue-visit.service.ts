import { Role, VenueVisitStatus, type Prisma } from '@prisma/client';
import { adminScope, assertCountryAllowed, recordCountry, viaVenueCountry } from '../../lib/admin-scope.js';
import type { AuthUser } from '../../middleware/auth.js';
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

async function notifyVisitCustomer(
  customerId: string,
  visitId: string,
  title: { en: string; ar: string },
  body: { en: string; ar: string },
) {
  await notificationService.notify({
    userId: customerId,
    title,
    body,
    data: { type: 'venue_visit', visitId },
  });
}

async function vendorUserIdForVenue(venueId: string): Promise<string | null> {
  const venue = await prisma.venue.findFirst({
    where: { id: venueId, ...notDeleted },
    include: { vendor: { select: { userId: true } } },
  });
  return venue?.vendor?.userId ?? null;
}

export const venueVisitService = {
  async list(userId: string, role: Role, query: z.infer<typeof visitListQuery>, actor?: AuthUser) {
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
        ? viaVenueCountry(adminScope(actor))
        : role === Role.VENDOR
          ? { venue: { vendor: { userId } } }
          : { customerId: userId }),
    };
    const [items, total] = await venueVisitRepository.list(where, skip, take);
    return paginated(items, total, query);
  },
  async get(userId: string, role: Role, id: string, actor?: AuthUser) {
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
    if (role === Role.ADMIN) {
      assertCountryAllowed(adminScope(actor), recordCountry(row.venue));
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
  async approve(userId: string, role: Role, id: string, actor?: AuthUser) {
    const visit = await this.get(userId, role, id, actor);
    const updated = await venueVisitRepository.update(id, { status: VenueVisitStatus.APPROVED });
    if (visit.customerId !== userId) {
      await notifyVisitCustomer(
        visit.customerId,
        id,
        { en: 'Venue visit approved', ar: 'تمت الموافقة على زيارة القاعة' },
        { en: 'Your venue visit was approved.', ar: 'تمت الموافقة على زيارة القاعة.' },
      );
    }
    return updated;
  },
  async reschedule(userId: string, role: Role, id: string, input: z.infer<typeof visitRescheduleSchema>, actor?: AuthUser) {
    const visit = await this.get(userId, role, id, actor);
    const updated = await venueVisitRepository.update(id, {
      status: VenueVisitStatus.RESCHEDULED,
      scheduledAt: input.scheduledAt,
      notes: input.notes,
    });
    const otherId =
      visit.customerId === userId ? await vendorUserIdForVenue(visit.venueId) : visit.customerId;
    if (otherId && otherId !== userId) {
      await notificationService.notify({
        userId: otherId,
        title: { en: 'Venue visit rescheduled', ar: 'تم إعادة جدولة زيارة القاعة' },
        body: { en: 'A venue visit was rescheduled.', ar: 'تم إعادة جدولة زيارة القاعة.' },
        data: { type: 'venue_visit', visitId: id },
      });
    }
    return updated;
  },
  async assign(userId: string, role: Role, id: string, input: z.infer<typeof visitAssignSchema>, actor?: AuthUser) {
    await this.get(userId, role, id, actor);
    const representative = await prisma.representative.findFirst({
      where: { id: input.representativeId, ...notDeleted },
    });
    if (!representative) {
      throw new NotFoundError('Representative not found');
    }
    const updated = await venueVisitRepository.update(id, {
      representative: { connect: { id: representative.id } },
      status: VenueVisitStatus.CONFIRMED,
    });
    const visit = await this.get(userId, role, id, actor);
    if (visit.customerId !== userId) {
      await notifyVisitCustomer(
        visit.customerId,
        id,
        { en: 'Venue visit confirmed', ar: 'تم تأكيد زيارة القاعة' },
        { en: 'Your venue visit is confirmed.', ar: 'تم تأكيد زيارة القاعة.' },
      );
    }
    return updated;
  },
  async notes(userId: string, role: Role, id: string, input: z.infer<typeof visitNotesSchema>, actor?: AuthUser) {
    await this.get(userId, role, id, actor);
    return venueVisitRepository.update(id, { notes: input.notes });
  },
  async decide(userId: string, role: Role, id: string, input: z.infer<typeof visitDecisionSchema>, actor?: AuthUser) {
    const visit = await this.get(userId, role, id, actor);
    if (role === Role.CUSTOMER && visit.customerId !== userId) {
      throw new ForbiddenError();
    }
    const updated = await venueVisitRepository.update(id, {
      status: VenueVisitStatus.DECIDED,
      decision: { accepted: input.accepted, notes: input.notes },
      decisionAt: new Date(),
    });
    const vendorUserId = await vendorUserIdForVenue(visit.venueId);
    if (vendorUserId && vendorUserId !== userId) {
      await notificationService.notify({
        userId: vendorUserId,
        title: {
          en: input.accepted ? 'Venue visit accepted' : 'Venue visit declined',
          ar: input.accepted ? 'تمت الموافقة على زيارة القاعة' : 'تم رفض زيارة القاعة',
        },
        body: {
          en: input.accepted ? 'The customer accepted the venue after the visit.' : 'The customer declined the venue after the visit.',
          ar: input.accepted ? 'قبل العميل القاعة بعد الزيارة.' : 'رفض العميل القاعة بعد الزيارة.',
        },
        data: { type: 'venue_visit', visitId: id },
      });
    }
    return updated;
  },
  async complete(userId: string, role: Role, id: string, actor?: AuthUser) {
    await this.get(userId, role, id, actor);
    return venueVisitRepository.update(id, { status: VenueVisitStatus.COMPLETED });
  },
  async cancel(userId: string, role: Role, id: string, actor?: AuthUser) {
    const visit = await this.get(userId, role, id, actor);
    const updated = await venueVisitRepository.update(id, { status: VenueVisitStatus.CANCELLED });
    const otherId =
      visit.customerId === userId ? await vendorUserIdForVenue(visit.venueId) : visit.customerId;
    if (otherId && otherId !== userId) {
      await notificationService.notify({
        userId: otherId,
        title: { en: 'Venue visit cancelled', ar: 'تم إلغاء زيارة القاعة' },
        body: { en: 'A venue visit was cancelled.', ar: 'تم إلغاء زيارة القاعة.' },
        data: { type: 'venue_visit', visitId: id },
      });
    }
    return updated;
  },
};
