import { useQuery } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { money } from '@/lib/utils';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';

type Profile = { status: string; businessName?: { en?: string } };
type Booking = { id: string; bookingNumber: string; status: string; startAt: string; totalAmount: string };
type Earnings = { totals: { total: number; deposits: number; balances: number } };

export function DashboardPage() {
  const { t } = useTranslation();
  const me = useQuery({ queryKey: ['vendor-me'], queryFn: () => unwrap<Profile>(api.get('/api/v1/vendors/me')) });
  const bookings = useQuery({
    queryKey: ['vendor-bookings-dash'],
    queryFn: () => unwrap<Paginated<Booking>>(api.get('/api/v1/bookings', { params: { pageSize: 8 } })),
  });
  const requests = useQuery({
    queryKey: ['vendor-requests'],
    queryFn: () => unwrap<Paginated<Booking>>(api.get('/api/v1/bookings', { params: { status: 'PENDING', pageSize: 5 } })),
  });
  const visits = useQuery({
    queryKey: ['vendor-visits-dash'],
    queryFn: () => unwrap<Paginated<unknown>>(api.get('/api/v1/venue-visits', { params: { status: 'REQUESTED', pageSize: 5 } })),
  });
  const earnings = useQuery({
    queryKey: ['vendor-earnings-dash'],
    queryFn: () => unwrap<Earnings>(api.get('/api/v1/vendors/me/earnings')),
  });
  const upcoming = (bookings.data?.items ?? []).filter((b) => ['CONFIRMED', 'PAID', 'IN_PROGRESS'].includes(b.status));
  const name = me.data?.businessName?.en ?? 'Your property';

  return (
    <div className="space-y-6">
      <div className="brand-hero rounded-2xl p-6 text-white shadow-lg">
        <p className="text-xs font-semibold uppercase tracking-widest text-[#FEBB02]">Tonight’s occupancy</p>
        <h1 className="mt-1 text-3xl font-extrabold">{name}</h1>
        <p className="mt-2 max-w-xl text-sm text-white/80">Review requests, keep availability fresh, and message guests — the same flow customers use in the app.</p>
        <div className="mt-4 flex flex-wrap gap-2">
          <Button asChild variant="cta">
            <Link to="/bookings">Open bookings</Link>
          </Button>
          <Button asChild variant="secondary">
            <Link to="/availability">Calendar</Link>
          </Button>
        </div>
      </div>
      {me.data?.status && me.data.status !== 'APPROVED' ? (
        <p className="rounded-xl border border-amber-200 bg-amber-50 p-3 text-sm">{t('dashboard.pending')} ({me.data.status})</p>
      ) : null}
      <div className="grid gap-4 md:grid-cols-4">
        <Kpi title={t('dashboard.bookings')} value={String(bookings.data?.total ?? 0)} />
        <Kpi title={t('dashboard.upcoming')} value={String(upcoming.length)} />
        <Kpi title={t('dashboard.requests')} value={String((requests.data?.total ?? 0) + (visits.data?.total ?? 0))} />
        <Kpi title={t('dashboard.earnings')} value={money(earnings.data?.totals.total)} />
      </div>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>Latest reservations</CardTitle>
          <Button asChild variant="outline" size="sm">
            <Link to="/bookings">View all</Link>
          </Button>
        </CardHeader>
        <CardContent className="divide-y">
          {(bookings.data?.items ?? []).length === 0 ? (
            <p className="py-6 text-sm text-muted-foreground">No bookings yet. Seed demo data to walk the full flow.</p>
          ) : (
            (bookings.data?.items ?? []).map((b) => (
              <div key={b.id} className="flex items-center justify-between py-3 text-sm">
                <div>
                  <p className="font-semibold">{b.bookingNumber}</p>
                  <p className="text-muted-foreground">{new Date(b.startAt).toLocaleString()}</p>
                </div>
                <div className="text-end">
                  <span className="rounded-full bg-[#003580]/10 px-2 py-0.5 text-xs font-semibold text-[#003580]">{b.status}</span>
                  <p className="mt-1 font-bold">{money(b.totalAmount)}</p>
                </div>
              </div>
            ))
          )}
        </CardContent>
      </Card>
    </div>
  );
}

function Kpi({ title, value }: { title: string; value: string }) {
  return (
    <Card className="border-0 shadow-md shadow-blue-900/5">
      <CardHeader className="p-4 pb-2">
        <CardTitle className="text-sm text-muted-foreground">{title}</CardTitle>
      </CardHeader>
      <CardContent className="p-4 pt-0 text-2xl font-extrabold text-[#003580]">{value}</CardContent>
    </Card>
  );
}
