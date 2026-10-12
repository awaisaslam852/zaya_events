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
  commissions?: Array<{ id: string; amount: string; status: string; rate: string }>;
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
      <div className="rounded-3xl border bg-white p-6 shadow-sm">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.2em] text-[#0071c2]">{d.type}</p>
            <h1 className="text-3xl font-extrabold text-[#003580]">{d.bookingNumber}</h1>
            <p className="text-sm text-muted-foreground">{resource || 'Marketplace booking'}</p>
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
      <div className="grid gap-3 md:grid-cols-4">
        <StatTile label="Total" value={money(d.totalAmount, d.currency)} />
        <StatTile label="Deposit" value={money(d.depositAmount, d.currency)} />
        <StatTile label="Balance" value={money(d.balanceAmount, d.currency)} />
        <StatTile label="Commission" value={money(d.commissionAmount, d.currency)} />
      </div>
      <div className="grid gap-4 lg:grid-cols-2">
        <Section title="Customer">
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
        <Section title="Vendor">
          {d.vendor ? (
            <Link to={`/vendors/${d.vendor.id}`} className="block rounded-xl border p-3 hover:bg-[#f5f7fa]">
              <p className="font-extrabold">{loc(d.vendor.businessName, i18n.language)}</p>
            </Link>
          ) : (
            <EmptyHint>Direct / no vendor</EmptyHint>
          )}
        </Section>
      </div>
      <Section title="Schedule">
        <p className="text-sm">
          {new Date(d.startAt).toLocaleString()} → {d.endAt ? new Date(d.endAt).toLocaleString() : '—'} · {d.guestCount ?? 0} guests
        </p>
        {d.notes ? <p className="mt-2 text-sm text-muted-foreground">{loc(d.notes, i18n.language)}</p> : null}
        <ModifyBooking id={d.id} startAt={d.startAt} guestCount={d.guestCount} />
      </Section>
      <div className="grid gap-4 lg:grid-cols-2">
        <Section title="Status history">
          {(d.statusHistory ?? []).length === 0 ? (
            <EmptyHint>No history</EmptyHint>
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
        <Section title="Payments & commissions">
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
              <div key={c.id} className="flex justify-between rounded-xl border px-3 py-2">
                <span>Commission {c.rate}%</span>
                <span>
                  {money(c.amount)} <StatusBadge status={c.status} />
                </span>
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
      <Input type="number" min={1} value={guests} onChange={(e) => setGuests(e.target.value)} className="w-28" placeholder="Guests" />
      <Button type="submit" size="sm" disabled={patch.isPending}>
        {t('common.save')}
      </Button>
    </form>
  );
}
