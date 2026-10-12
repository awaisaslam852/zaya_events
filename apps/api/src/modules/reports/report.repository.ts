import { prisma } from '../../lib/prisma.js';

export const reportRepository = {
  async aggregates(from?: Date, to?: Date) {
    const createdAt = {
      ...(from || to ? { createdAt: { gte: from, lte: to } } : {}),
    };
    const [
      customers,
      vendors,
      bookings,
      events,
      venues,
      accommodations,
      flights,
      hotels,
      payments,
      commissions,
      activity,
    ] = await Promise.all([
      prisma.user.count({ where: { role: 'CUSTOMER', deletedAt: null, ...createdAt } }),
      prisma.vendor.count({ where: { deletedAt: null, ...createdAt } }),
      prisma.booking.groupBy({ by: ['status'], where: { deletedAt: null, ...createdAt }, _count: true, _sum: { totalAmount: true } }),
      prisma.event.count({ where: { deletedAt: null, ...createdAt } }),
      prisma.venue.count({ where: { deletedAt: null, ...createdAt } }),
      prisma.accommodation.count({ where: { deletedAt: null, ...createdAt } }),
      prisma.flight.count({ where: { deletedAt: null, ...createdAt } }),
      prisma.hotel.count({ where: { deletedAt: null, ...createdAt } }),
      prisma.payment.aggregate({
        where: { deletedAt: null, status: 'SUCCEEDED', ...createdAt },
        _sum: { amount: true },
        _count: true,
      }),
      prisma.commission.aggregate({
        where: { deletedAt: null, ...createdAt },
        _sum: { amount: true },
        _count: true,
      }),
      prisma.crmInteraction.count({ where: { deletedAt: null, ...createdAt } }),
    ]);
    return {
      customers,
      vendors,
      bookings,
      events,
      venues,
      accommodations,
      flights,
      hotels,
      payments,
      commissions,
      activity,
    };
  },
};
