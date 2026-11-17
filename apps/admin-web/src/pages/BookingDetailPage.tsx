import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap } from '@/lib/api';
import { loc, money } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { StatusBadge } from '@/components/StatusBadge';
import { BackLink, EmptyHint, Section, StatTile } from '@/components/AdminChrome';
import { toast } from 'sonner';

type Booking = {
  id: string;
  bookingNumber: string;
  type: string;
  status: string;
  startAt: string;
  endAt: string | null;
  guestCount: number | null;
  currency: string;
  subtotalAmount: string;
  commissionAmount: string;
  depositAmount: string;
  balanceAmount: string;
  totalAmount: string;
  notes: unknown;
  customer?: { id: string; firstName: string; lastName: string; email: string; phone: string | null };
  vendor?: { id: string; businessName: unknown };
  listing?: { id: string; title: unknown };
  venue?: { id: string; name: unknown };
  car?: { id: string; name: unknown };
  accommodation?: { id: string; name: unknown };
  honeymoon?: { id: string; name: unknown };
  statusHistory: Array<{ fromStatus: string | null; toStatus: string; createdAt: string; reason?: string | null }>;
  payments: Array<{ id: string; kind: string; status: string; amount: string; currency?: string }>;
  invoices?: Array<{
    id: string;
    invoiceNumber: string;
    status: string;
    vatAmount: string;
    totalAmount: string;
    currency: string;
  }>;
  commissions?: Array<{
    id: string;
    amount: string;
    status: string;
    rate: string;
    hqRate?: string;
    hqAmount?: string;
    deskAmount?: string;
    currency?: string;
  }>;
};

export function BookingDetailPage() {
  const { t, i18n } = useTranslation();
  const { id } = useParams();
  const qc = useQueryClient();
  const q = useQuery({
    queryKey: ['booking', id],
    queryFn: () => unwrap<Booking>(api.get(`/api/v1/bookings/${id}`)),
    enabled: Boolean(id),
  });
  const act = useMutation({
    mutationFn: (action: string) => unwrap(api.post(`/api/v1/bookings/${id}/${action}`, {})),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['booking', id] });
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const d = q.data;
  if (!d) {
    return <p>{t('common.loading')}</p>;
  }
  const resource = loc(d.listing?.title ?? d.venue?.name ?? d.car?.name ?? d.accommodation?.name ?? d.honeymoon?.name, i18n.language);

  return (
    <div className="space-y-5">
      <BackLink to="/bookings" label={t('nav.bookings')} />
      <div className="rounded-2xl border bg-white p-4 shadow-sm sm:rounded-3xl sm:p-6">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.2em] text-[#0071c2]">{d.type}</p>
            <h1 className="text-2xl font-extrabold text-[#003580] sm:text-3xl">{d.bookingNumber}</h1>
            <p className="text-sm text-muted-foreground">{resource || t('booking.marketplace')}</p>
          </div>
          <StatusBadge status={d.status} />
        </div>
        <div className="mt-4 flex flex-wrap gap-2">
          <Button size="sm" onClick={() => act.mutate('under-review')}>{t('bookings.underReview')}</Button>
          <Button size="sm" onClick={() => act.mutate('confirm')}>{t('bookings.confirm')}</Button>
          <Button size="sm" onClick={() => act.mutate('complete')}>{t('bookings.complete')}</Button>
          <Button size="sm" variant="destructive" onClick={() => act.mutate('cancel')}>{t('bookings.cancel')}</Button>
          <Button size="sm" variant="destructive" onClick={() => act.mutate('reject')}>{t('common.reject')}</Button>
        </div>
      </div>
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <StatTile label={t('booking.total')} value={money(d.totalAmount, d.currency)} />
        <StatTile label={t('booking.deposit')} value={money(d.depositAmount, d.currency)} />
        <StatTile label={t('booking.balance')} value={money(d.balanceAmount, d.currency)} />
        <StatTile label={t('booking.vendorCommission')} value={money(d.commissionAmount, d.currency)} />
      </div>
      {d.commissions?.[0] ? (
        <div className="grid gap-3 md:grid-cols-3">
          <StatTile label={t('finance.takenFromVendor')} value={money(d.commissions[0].amount, d.commissions[0].currency ?? d.currency)} hint={`${d.commissions[0].rate}%`} />
          <StatTile
            label={t('finance.hqShare')}
            value={money(d.commissions[0].hqAmount ?? 0, d.commissions[0].currency ?? d.currency)}
            hint={d.commissions[0].hqRate ? t('finance.hqPercentHint', { rate: d.commissions[0].hqRate }) : undefined}
          />
          <StatTile label={t('finance.deskNet')} value={money(d.commissions[0].deskAmount ?? 0, d.commissions[0].currency ?? d.currency)} />
        </div>
      ) : null}
      <div className="grid gap-4 lg:grid-cols-2">
        <Section title={t('booking.customer')}>
          {d.customer ? (
            <Link to={`/customers/${d.customer.id}`} className="block rounded-xl border p-3 hover:bg-[#f5f7fa]">
              <p className="font-extrabold">
                {d.customer.firstName} {d.customer.lastName}
              </p>
              <p className="text-sm text-muted-foreground">{d.customer.email}</p>
              <p className="text-xs">{d.customer.phone}</p>
            </Link>
          ) : (
            <EmptyHint>—</EmptyHint>
          )}
        </Section>
        <Section title={t('booking.vendor')}>
          {d.vendor ? (
            <Link to={`/vendors/${d.vendor.id}`} className="block rounded-xl border p-3 hover:bg-[#f5f7fa]">
              <p className="font-extrabold">{loc(d.vendor.businessName, i18n.language)}</p>
            </Link>
          ) : (
            <EmptyHint>{t('booking.direct')}</EmptyHint>
          )}
        </Section>
      </div>
      <Section title={t('booking.schedule')}>
        <p className="text-sm">
          {new Date(d.startAt).toLocaleString()} → {d.endAt ? new Date(d.endAt).toLocaleString() : '—'} · {d.guestCount ?? 0} {t('booking.guests')}
        </p>
        {d.notes ? <p className="mt-2 text-sm text-muted-foreground">{loc(d.notes, i18n.language)}</p> : null}
        <ModifyBooking id={d.id} startAt={d.startAt} guestCount={d.guestCount} />
      </Section>
      <div className="grid gap-4 lg:grid-cols-2">
        <Section title={t('booking.history')}>
          {(d.statusHistory ?? []).length === 0 ? (
            <EmptyHint>{t('booking.noHistory')}</EmptyHint>
          ) : (
            <ol className="space-y-2 text-sm">
              {d.statusHistory.map((h, i) => (
                <li key={i} className="rounded-xl border px-3 py-2">
                  {(h.fromStatus ?? 'NEW')} → {h.toStatus}
                  <span className="block text-xs text-muted-foreground">{new Date(h.createdAt).toLocaleString()}</span>
                </li>
              ))}
            </ol>
          )}
        </Section>
        <Section title={t('booking.payments')}>
          <div className="space-y-2 text-sm">
            {(d.payments ?? []).map((p) => (
              <div key={p.id} className="flex justify-between rounded-xl border px-3 py-2">
                <span>{p.kind}</span>
                <span className="flex items-center gap-2">
                  <StatusBadge status={p.status} />
                  {money(p.amount, p.currency)}
                </span>
              </div>
            ))}
            {(d.invoices ?? []).map((inv) => (
              <div key={inv.id} className="flex justify-between rounded-xl border px-3 py-2">
                <span>{inv.invoiceNumber}</span>
                <span className="flex items-center gap-2">
                  <StatusBadge status={inv.status} />
                  {money(inv.totalAmount, inv.currency)}
                </span>
              </div>
            ))}
            {(d.commissions ?? []).map((c) => (
              <div key={c.id} className="rounded-xl border px-3 py-2">
                <div className="flex justify-between">
                  <span>{t('nav.vendors')} {c.rate}%</span>
                  <span className="flex items-center gap-2">
                    <StatusBadge status={c.status} />
                    {money(c.amount, c.currency ?? d.currency)}
                  </span>
                </div>
                <p className="mt-1 text-xs text-muted-foreground">
                  {t('finance.hq')} {money(c.hqAmount ?? 0, c.currency ?? d.currency)} · {t('finance.desk')} {money(c.deskAmount ?? 0, c.currency ?? d.currency)}
                </p>
              </div>
            ))}
          </div>
        </Section>
      </div>
    </div>
  );
}

function ModifyBooking({ id, startAt, guestCount }: { id: string; startAt: string; guestCount: number | null }) {
  const { t } = useTranslation();
  const qc = useQueryClient();
  const [guests, setGuests] = useState(String(guestCount ?? ''));
  const [when, setWhen] = useState(startAt.slice(0, 16));
  const patch = useMutation({
    mutationFn: () =>
      unwrap(
        api.patch(`/api/v1/bookings/${id}`, {
          startAt: new Date(when).toISOString(),
          guestCount: guests ? Number(guests) : undefined,
        }),
      ),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['booking', id] });
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  return (
    <form
      className="mt-3 flex flex-wrap items-end gap-2"
      onSubmit={(e) => {
        e.preventDefault();
        patch.mutate();
      }}
    >
      <Input type="datetime-local" value={when} onChange={(e) => setWhen(e.target.value)} className="w-56" />
      <Input type="number" min={1} value={guests} onChange={(e) => setGuests(e.target.value)} className="w-28" placeholder={t('common.guests')} />
      <Button type="submit" size="sm" disabled={patch.isPending}>
        {t('common.save')}
      </Button>
    </form>
  );
}
