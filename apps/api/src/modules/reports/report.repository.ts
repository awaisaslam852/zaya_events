import { BookingStatus, CommissionStatus, PaymentStatus, PayoutStatus } from '@prisma/client';
import { adminScope, countryWhere, viaBookingVendorCountry, viaEventCountry, viaVendorCountry } from '../../lib/admin-scope.js';
import { currencyForCountry } from '../../lib/countries.js';
import type { AuthUser } from '../../middleware/auth.js';
import { prisma } from '../../lib/prisma.js';

const REVENUE_STATUSES: BookingStatus[] = [
  BookingStatus.CONFIRMED,
  BookingStatus.PAID,
  BookingStatus.IN_PROGRESS,
  BookingStatus.COMPLETED,
];

type MoneyBucket = {
  country: string;
  currency: string;
  gmv: number;
  collected: number;
  platformCommission: number;
  hqEarnings: number;
  deskEarnings: number;
  pendingVendorPayouts: number;
};

function emptyBucket(country: string, currency: string): MoneyBucket {
  return {
    country,
    currency,
    gmv: 0,
    collected: 0,
    platformCommission: 0,
    hqEarnings: 0,
    deskEarnings: 0,
    pendingVendorPayouts: 0,
  };
}

function moneyKey(country: string, currency: string): string {
  return `${country}:${currency}`;
}

function num(value: unknown): number {
  return Number(value ?? 0);
}

function rollup(buckets: MoneyBucket[]) {
  const byCountryMap = new Map<string, MoneyBucket>();
  const byCurrencyMap = new Map<string, Omit<MoneyBucket, 'country'>>();
  for (const row of buckets) {
    const country = byCountryMap.get(row.country) ?? emptyBucket(row.country, row.currency);
    country.gmv += row.gmv;
    country.collected += row.collected;
    country.platformCommission += row.platformCommission;
    country.hqEarnings += row.hqEarnings;
    country.deskEarnings += row.deskEarnings;
    country.pendingVendorPayouts += row.pendingVendorPayouts;
    byCountryMap.set(row.country, country);

    const currency = byCurrencyMap.get(row.currency) ?? {
      currency: row.currency,
      gmv: 0,
      collected: 0,
      platformCommission: 0,
      hqEarnings: 0,
      deskEarnings: 0,
      pendingVendorPayouts: 0,
    };
    currency.gmv += row.gmv;
    currency.collected += row.collected;
    currency.platformCommission += row.platformCommission;
    currency.hqEarnings += row.hqEarnings;
    currency.deskEarnings += row.deskEarnings;
    currency.pendingVendorPayouts += row.pendingVendorPayouts;
    byCurrencyMap.set(row.currency, currency);
  }
  const byCountry = [...byCountryMap.values()].sort((a, b) => a.country.localeCompare(b.country));
  const byCurrency = [...byCurrencyMap.values()].sort((a, b) => a.currency.localeCompare(b.currency));
  const mixed = byCurrency.length !== 1;
  return {
    mixedCurrencies: mixed,
    totals: mixed ? null : (byCurrency[0] ?? null),
    byCountry,
    byCurrency,
  };
}

export const reportRepository = {
  async aggregates(from?: Date, to?: Date, actor?: AuthUser) {
    const createdAt = {
      ...(from || to ? { createdAt: { gte: from, lte: to } } : {}),
    };
    const scope = adminScope(actor);
    const byCountry = countryWhere(scope);
    const byVendor = viaVendorCountry(scope);
    const byBookingVendor = viaBookingVendorCountry(scope);
    const byEvent = viaEventCountry(scope);
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
      bookingRows,
      paymentRows,
      commissionRows,
      payoutRows,
    ] = await Promise.all([
      prisma.user.count({ where: { role: 'CUSTOMER', deletedAt: null, ...createdAt, ...byCountry } }),
      prisma.vendor.count({ where: { deletedAt: null, ...createdAt, ...byCountry } }),
      prisma.booking.groupBy({
        by: ['status'],
        where: { deletedAt: null, ...createdAt, ...byVendor },
        _count: true,
        _sum: { totalAmount: true },
      }),
      prisma.event.count({ where: { deletedAt: null, ...createdAt, ...byEvent } }),
      prisma.venue.count({ where: { deletedAt: null, ...createdAt, ...byCountry } }),
      prisma.accommodation.count({ where: { deletedAt: null, ...createdAt, ...byCountry } }),
      prisma.flight.count({ where: { deletedAt: null, ...createdAt } }),
      prisma.hotel.count({ where: { deletedAt: null, ...createdAt, ...byCountry } }),
      prisma.payment.aggregate({
        where: { deletedAt: null, status: PaymentStatus.SUCCEEDED, ...createdAt, ...byBookingVendor },
        _sum: { amount: true },
        _count: true,
      }),
      prisma.commission.aggregate({
        where: { deletedAt: null, status: { not: CommissionStatus.VOID }, ...createdAt, ...byVendor },
        _sum: { amount: true, hqAmount: true, deskAmount: true },
        _count: true,
      }),
      prisma.crmInteraction.count({ where: { deletedAt: null, ...createdAt } }),
      prisma.booking.findMany({
        where: { deletedAt: null, status: { in: REVENUE_STATUSES }, ...createdAt, ...byVendor },
        select: { totalAmount: true, currency: true, vendor: { select: { country: true } } },
      }),
      prisma.payment.findMany({
        where: { deletedAt: null, status: PaymentStatus.SUCCEEDED, ...createdAt, ...byBookingVendor },
        select: { amount: true, currency: true, booking: { select: { vendor: { select: { country: true } } } } },
      }),
      prisma.commission.findMany({
        where: { deletedAt: null, status: { not: CommissionStatus.VOID }, ...createdAt, ...byVendor },
        select: { amount: true, hqAmount: true, deskAmount: true, currency: true, country: true, vendor: { select: { country: true } } },
      }),
      prisma.payout.findMany({
        where: { deletedAt: null, status: PayoutStatus.PENDING, ...createdAt, ...byVendor },
        select: { amount: true, currency: true, vendor: { select: { country: true } } },
      }),
    ]);

    const buckets = new Map<string, MoneyBucket>();
    function bucket(country: string | null | undefined, currency: string | null | undefined): MoneyBucket {
      const code = country || 'UN';
      const curr = currency || currencyForCountry(code);
      const key = moneyKey(code, curr);
      const current = buckets.get(key) ?? emptyBucket(code, curr);
      buckets.set(key, current);
      return current;
    }
    for (const row of bookingRows) {
      bucket(row.vendor?.country, row.currency).gmv += num(row.totalAmount);
    }
    for (const row of paymentRows) {
      bucket(row.booking.vendor?.country, row.currency).collected += num(row.amount);
    }
    for (const row of commissionRows) {
      const item = bucket(row.country ?? row.vendor?.country, row.currency);
      item.platformCommission += num(row.amount);
      item.hqEarnings += num(row.hqAmount);
      item.deskEarnings += num(row.deskAmount);
    }
    for (const row of payoutRows) {
      bucket(row.vendor?.country, row.currency).pendingVendorPayouts += num(row.amount);
    }

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
      finance: rollup([...buckets.values()]),
    };
  },
};
