import { Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { api, unwrap, type Paginated } from '@/lib/api';
import { getDeskCountry, isSuperAdmin } from '@/lib/auth';
import { countryName } from '@/lib/countries';
import { loc, money } from '@/lib/utils';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { StatusBadge } from '@/components/StatusBadge';
import { StatTile } from '@/components/AdminChrome';

type FinanceRow = {
  country?: string;
  currency: string;
  gmv: number;
  collected: number;
  platformCommission: number;
  hqEarnings: number;
  deskEarnings: number;
  pendingVendorPayouts: number;
};

type Overview = {
  customers: number;
  vendors: number;
  events: number;
  payments: { _sum: { amount: unknown }; _count: number };
  bookings: Array<{ status: string; _count: number; _sum: { totalAmount: unknown } }>;
  finance?: {
    mixedCurrencies: boolean;
    totals: FinanceRow | null;
    byCountry: FinanceRow[];
    byCurrency: FinanceRow[];
  };
};

type Booking = {
  id: string;
  bookingNumber: string;
  status: string;
  totalAmount: string;
  currency?: string;
  type: string;
  customer?: { firstName: string; lastName: string };
};
type Vendor = { id: string; status: string; businessName: unknown; city: string | null };

export function DashboardPage() {
  const { t, i18n } = useTranslation();
  const superAdmin = isSuperAdmin();
  const overview = useQuery({
    queryKey: ['reports-overview', getDeskCountry()],
    queryFn: () => unwrap<Overview>(api.get('/api/v1/reports/overview')),
  });
  const visits = useQuery({
    queryKey: ['pending-visits'],
    queryFn: () => unwrap<Paginated<unknown>>(api.get('/api/v1/venue-visits', { params: { status: 'REQUESTED', pageSize: 5 } })),
  });
  const events = useQuery({
    queryKey: ['upcoming-events'],
    queryFn: () => unwrap<Paginated<unknown>>(api.get('/api/v1/events', { params: { pageSize: 5 } })),
  });
  const recentBookings = useQuery({
    queryKey: ['dash-bookings'],
    queryFn: () => unwrap<Paginated<Booking>>(api.get('/api/v1/bookings', { params: { pageSize: 6 } })),
  });
  const pendingVendors = useQuery({
    queryKey: ['dash-vendors'],
    queryFn: () => unwrap<Paginated<Vendor>>(api.get('/api/v1/vendors', { params: { status: 'PENDING', pageSize: 6 } })),
  });

  const data = overview.data;
  const finance = data?.finance;
  const totals = finance?.totals;
  const chart = (data?.bookings ?? []).map((row) => ({
    status: row.status,
    count: row._count,
    revenue: Number(row._sum.totalAmount ?? 0),
  }));

  return (
    <div className="space-y-6">
      <div className="overflow-hidden rounded-2xl brand-hero p-4 text-white sm:rounded-3xl sm:p-6">
        <p className="text-xs font-semibold uppercase tracking-[0.25em] text-[#FEBB02]">
          {superAdmin ? t('layout.headquarters') : t('layout.countryDesk')}
        </p>
        <h1 className="mt-1 text-2xl font-extrabold tracking-tight sm:text-3xl">{t('finance.today')}</h1>
        <p className="mt-1 max-w-2xl text-sm text-white/80">
          {superAdmin ? t('finance.superHero') : t('finance.countryHero')}
        </p>
        <div className="mt-4 flex flex-wrap gap-2 text-sm">
          <Link className="rounded-full bg-white/15 px-3 py-1 hover:bg-white/25" to="/commissions">{t('nav.commissions')}</Link>
          <Link className="rounded-full bg-white/15 px-3 py-1 hover:bg-white/25" to="/reports">{t('nav.reports')}</Link>
          <Link className="rounded-full bg-white/15 px-3 py-1 hover:bg-white/25" to="/bookings">{t('nav.bookings')}</Link>
          <Link className="rounded-full bg-white/15 px-3 py-1 hover:bg-white/25" to="/vendors">{t('nav.vendors')}</Link>
        </div>
      </div>
      {totals ? (
        <div className="grid grid-cols-2 gap-3 sm:gap-4 lg:grid-cols-6">
          <StatTile label={t('finance.gmv')} value={money(totals.gmv, totals.currency)} hint={t('finance.confirmedBookings')} />
          <StatTile label={t('finance.collected')} value={money(totals.collected, totals.currency)} hint={t('finance.succeededPayments')} />
          <StatTile label={t('finance.vendorCommission')} value={money(totals.platformCommission, totals.currency)} hint={t('finance.takenFromVendors')} />
          <StatTile
            label={superAdmin ? t('finance.hqEarnings') : t('finance.hqShare')}
            value={money(totals.hqEarnings, totals.currency)}
            hint={superAdmin ? t('finance.yourTake') : t('finance.owedToHq')}
          />
          <StatTile
            label={superAdmin ? t('finance.deskEarnings') : t('finance.yourEarnings')}
            value={money(totals.deskEarnings, totals.currency)}
            hint={superAdmin ? t('finance.desksKeep') : t('finance.afterHq')}
          />
          <StatTile label={t('finance.pendingPayouts')} value={money(totals.pendingVendorPayouts, totals.currency)} hint={t('finance.vendors')} />
        </div>
      ) : (
        <div className="grid grid-cols-2 gap-3 sm:gap-4 lg:grid-cols-6">
          <StatTile label={t('dashboard.bookings')} value={String(chart.reduce((s, r) => s + r.count, 0))} hint={t('common.allStatuses')} />
          <StatTile label={t('dashboard.vendors')} value={String(data?.vendors ?? 0)} hint={t('common.supply')} />
          <StatTile label={t('dashboard.customers')} value={String(data?.customers ?? 0)} hint={t('common.guests')} />
          <StatTile label={t('dashboard.events')} value={String(events.data?.total ?? data?.events ?? 0)} hint={t('common.planned')} />
          <StatTile label={t('dashboard.visits')} value={String(visits.data?.total ?? 0)} hint={t('common.needHost')} />
          <StatTile label={t('finance.desks')} value={String(finance?.byCountry.length ?? 0)} hint={t('finance.seeBelow')} />
        </div>
      )}
      {superAdmin && (finance?.byCountry.length ?? 0) > 0 ? (
        <Card>
          <CardHeader>
            <CardTitle>{t('finance.byCountry')}</CardTitle>
          </CardHeader>
          <CardContent className="overflow-x-auto">
            <table className="w-full min-w-[640px] text-sm">
              <thead>
                <tr className="text-start text-xs uppercase tracking-wide text-muted-foreground">
                  <th className="pb-2 text-start">{t('finance.desk')}</th>
                  <th className="pb-2 text-end">{t('finance.gmv')}</th>
                  <th className="pb-2 text-end">{t('finance.collected')}</th>
                  <th className="pb-2 text-end">{t('finance.vendorFee')}</th>
                  <th className="pb-2 text-end">{t('finance.hq')}</th>
                  <th className="pb-2 text-end">{t('finance.deskNet')}</th>
                </tr>
              </thead>
              <tbody>
                {(finance?.byCountry ?? []).map((row) => (
                  <tr key={`${row.country}-${row.currency}`} className="border-t">
                    <td className="py-2 font-semibold">
                      {countryName(row.country ?? '')} · {row.currency}
                    </td>
                    <td className="py-2 text-end">{money(row.gmv, row.currency)}</td>
                    <td className="py-2 text-end">{money(row.collected, row.currency)}</td>
                    <td className="py-2 text-end">{money(row.platformCommission, row.currency)}</td>
                    <td className="py-2 text-end font-bold">{money(row.hqEarnings, row.currency)}</td>
                    <td className="py-2 text-end">{money(row.deskEarnings, row.currency)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </CardContent>
        </Card>
      ) : null}
      <div className="grid gap-4 lg:grid-cols-5">
        <Card className="overflow-hidden lg:col-span-3">
          <CardHeader>
            <CardTitle>{t('finance.bookingMix')}</CardTitle>
          </CardHeader>
          <CardContent className="h-64 sm:h-80">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={chart}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e5eef7" />
                <XAxis dataKey="status" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="count" fill="#003580" radius={[6, 6, 0, 0]} />
                <Bar dataKey="revenue" fill="#0071c2" radius={[6, 6, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>{t('finance.pendingVendors')}</CardTitle>
          </CardHeader>
          <CardContent className="space-y-2">
            {(pendingVendors.data?.items ?? []).map((v) => (
              <Link key={v.id} to={`/vendors/${v.id}`} className="flex items-center justify-between rounded-xl border px-3 py-2 hover:bg-[#f5f7fa]">
                <span className="text-sm font-semibold">{loc(v.businessName, i18n.language)}</span>
                <StatusBadge status={v.status} />
              </Link>
            ))}
          </CardContent>
        </Card>
      </div>
      <Card>
        <CardHeader>
          <CardTitle>{t('finance.latestBookings')}</CardTitle>
        </CardHeader>
        <CardContent className="grid gap-2">
          {(recentBookings.data?.items ?? []).map((b) => (
            <Link key={b.id} to={`/bookings/${b.id}`} className="flex min-w-0 items-center justify-between gap-3 rounded-xl border px-3 py-2 hover:bg-[#f5f7fa]">
              <div>
                <p className="font-semibold">{b.bookingNumber}</p>
                <p className="text-xs text-muted-foreground">
                  {b.type} · {b.customer ? `${b.customer.firstName} ${b.customer.lastName}` : ''}
                </p>
              </div>
              <div className="text-end">
                <StatusBadge status={b.status} />
                <p className="mt-1 text-sm font-bold">{money(b.totalAmount, b.currency)}</p>
              </div>
            </Link>
          ))}
        </CardContent>
      </Card>
    </div>
  );
}
