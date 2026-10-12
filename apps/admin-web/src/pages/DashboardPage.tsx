import { Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { api, unwrap, type Paginated } from '@/lib/api';
import { loc, money } from '@/lib/utils';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { StatusBadge } from '@/components/StatusBadge';
import { StatTile } from '@/components/AdminChrome';

type Overview = {
  customers: number;
  vendors: number;
  events: number;
  payments: { _sum: { amount: unknown }; _count: number };
  bookings: Array<{ status: string; _count: number; _sum: { totalAmount: unknown } }>;
};

type Booking = { id: string; bookingNumber: string; status: string; totalAmount: string; type: string; customer?: { firstName: string; lastName: string } };
type Vendor = { id: string; status: string; businessName: unknown; city: string | null };

export function DashboardPage() {
  const { t, i18n } = useTranslation();
  const overview = useQuery({
    queryKey: ['reports-overview'],
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
  const chart = (data?.bookings ?? []).map((row) => ({
    status: row.status,
    count: row._count,
    revenue: Number(row._sum.totalAmount ?? 0),
  }));

  return (
    <div className="space-y-6">
      <div className="overflow-hidden rounded-3xl brand-hero p-6 text-white">
        <p className="text-xs font-semibold uppercase tracking-[0.25em] text-[#FEBB02]">Operations</p>
        <h1 className="mt-1 text-3xl font-extrabold tracking-tight">Today at a glance</h1>
        <p className="mt-1 max-w-2xl text-sm text-white/80">Bookings, partners, guests, and cash movement across the Zaya marketplace.</p>
        <div className="mt-4 flex flex-wrap gap-2 text-sm">
          <Link className="rounded-full bg-white/15 px-3 py-1 hover:bg-white/25" to="/customers">Customers</Link>
          <Link className="rounded-full bg-white/15 px-3 py-1 hover:bg-white/25" to="/vendors">Vendors</Link>
          <Link className="rounded-full bg-white/15 px-3 py-1 hover:bg-white/25" to="/bookings">Bookings</Link>
          <Link className="rounded-full bg-white/15 px-3 py-1 hover:bg-white/25" to="/listings">Listings</Link>
        </div>
      </div>
      <div className="grid gap-4 md:grid-cols-3 lg:grid-cols-6">
        <StatTile label={t('dashboard.revenue')} value={money(data?.payments?._sum.amount)} hint="Collected" />
        <StatTile label={t('dashboard.bookings')} value={String(chart.reduce((s, r) => s + r.count, 0))} hint="All statuses" />
        <StatTile label={t('dashboard.vendors')} value={String(data?.vendors ?? 0)} hint="Supply" />
        <StatTile label={t('dashboard.customers')} value={String(data?.customers ?? 0)} hint="Guests" />
        <StatTile label={t('dashboard.events')} value={String(events.data?.total ?? data?.events ?? 0)} hint="Planned" />
        <StatTile label={t('dashboard.visits')} value={String(visits.data?.total ?? 0)} hint="Need a host" />
      </div>
      <div className="grid gap-4 lg:grid-cols-5">
        <Card className="overflow-hidden lg:col-span-3">
          <CardHeader>
            <CardTitle>Booking mix</CardTitle>
          </CardHeader>
          <CardContent className="h-80">
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
            <CardTitle>Pending vendors</CardTitle>
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
          <CardTitle>Latest bookings</CardTitle>
        </CardHeader>
        <CardContent className="grid gap-2">
          {(recentBookings.data?.items ?? []).map((b) => (
            <Link key={b.id} to={`/bookings/${b.id}`} className="flex items-center justify-between rounded-xl border px-3 py-2 hover:bg-[#f5f7fa]">
              <div>
                <p className="font-semibold">{b.bookingNumber}</p>
                <p className="text-xs text-muted-foreground">
                  {b.type} · {b.customer ? `${b.customer.firstName} ${b.customer.lastName}` : ''}
                </p>
              </div>
              <div className="text-end">
                <StatusBadge status={b.status} />
                <p className="mt-1 text-sm font-bold">{money(b.totalAmount)}</p>
              </div>
            </Link>
          ))}
        </CardContent>
      </Card>
    </div>
  );
}
