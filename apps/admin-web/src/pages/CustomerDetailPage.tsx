import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap } from '@/lib/api';
import { COUNTRIES } from '@/lib/countries';
import { loc, mediaUrl, money } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { StatusBadge } from '@/components/StatusBadge';
import { BackLink, EmptyHint, PersonAvatar, Section, StatTile } from '@/components/AdminChrome';
import { FileUpload } from '@/components/FileUpload';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { toast } from 'sonner';

type Detail = {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  phone: string | null;
  status: string;
  locale: string;
  country: string | null;
  avatarKey: string | null;
  createdAt: string;
  lastLoginAt: string | null;
  events: Array<{ id: string; title: unknown; eventDate: string; city: string | null; guestCount: number | null; status: string; category?: { name: unknown } }>;
  bookings: Array<{
    id: string;
    bookingNumber: string;
    status: string;
    type: string;
    totalAmount: string;
    currency: string;
    startAt: string;
    vendor?: { id: string; businessName: unknown };
    listing?: { title: unknown };
    venue?: { name: unknown };
    car?: { name: unknown };
  }>;
  payments: Array<{ id: string; amount: string; status: string; kind: string; currency: string; createdAt: string }>;
  venueVisits: Array<{ id: string; status: string; scheduledAt: string; venue?: { name: unknown } }>;
  favorites: Array<{ id: string; resourceType: string; resourceId: string }>;
};

type EditForm = {
  firstName: string;
  lastName: string;
  phone: string;
  country: string;
  locale: string;
  avatarKey: string;
  password: string;
};

export function CustomerDetailPage() {
  const { t, i18n } = useTranslation();
  const { id } = useParams();
  const navigate = useNavigate();
  const qc = useQueryClient();
  const [open, setOpen] = useState(false);
  const form = useForm<EditForm>();
  const q = useQuery({
    queryKey: ['customer', id],
    queryFn: () => unwrap<Detail>(api.get(`/api/v1/customers/${id}`)),
    enabled: Boolean(id),
  });
  const save = useMutation({
    mutationFn: (values: EditForm) =>
      unwrap(
        api.patch(`/api/v1/customers/${id}`, {
          firstName: values.firstName,
          lastName: values.lastName,
          phone: values.phone.trim() || null,
          country: values.country || undefined,
          locale: values.locale,
          avatarKey: values.avatarKey || undefined,
          password: values.password.trim() || undefined,
        }),
      ),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['customer', id] });
      setOpen(false);
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const remove = useMutation({
    mutationFn: () => unwrap(api.delete(`/api/v1/customers/${id}`)),
    onSuccess: () => {
      toast.success(t('common.delete'));
      navigate('/customers');
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const toggle = useMutation({
    mutationFn: () =>
      unwrap(api.post(`/api/v1/customers/${id}/${q.data?.status === 'ACTIVE' ? 'deactivate' : 'activate'}`)),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['customer', id] });
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const d = q.data;
  if (!d) {
    return <p>{t('common.loading')}</p>;
  }
  const spent = d.payments.filter((p) => p.status === 'PAID' || p.status === 'CAPTURED' || p.status === 'SUCCEEDED').reduce((s, p) => s + Number(p.amount), 0);

  return (
    <div className="space-y-5">
      <BackLink to="/customers" label={t('nav.customers')} />
      <div className="overflow-hidden rounded-3xl border bg-white shadow-sm shadow-blue-900/5">
        <div className="brand-hero px-6 py-8 text-white">
          <div className="flex flex-wrap items-start justify-between gap-4">
            <div className="flex items-center gap-4">
              <PersonAvatar first={d.firstName} last={d.lastName} src={d.avatarKey ? mediaUrl(d.avatarKey) : undefined} />
              <div>
                <p className="text-xs font-semibold uppercase tracking-[0.2em] text-[#FEBB02]">Customer</p>
                <h1 className="text-3xl font-extrabold">
                  {d.firstName} {d.lastName}
                </h1>
                <p className="text-white/80">{d.email}</p>
              </div>
            </div>
            <div className="flex flex-wrap items-center gap-2">
              <StatusBadge status={d.status} />
              <Button
                variant="secondary"
                onClick={() => {
                  form.reset({
                    firstName: d.firstName,
                    lastName: d.lastName,
                    phone: d.phone ?? '',
                    country: d.country ?? 'AE',
                    locale: d.locale || 'en',
                    avatarKey: d.avatarKey ?? '',
                    password: '',
                  });
                  setOpen(true);
                }}
              >
                {t('common.edit')}
              </Button>
              <Button variant="cta" onClick={() => toggle.mutate()}>
                {d.status === 'ACTIVE' ? t('common.deactivate') : t('common.activate')}
              </Button>
              <Button
                variant="destructive"
                onClick={() => {
                  if (window.confirm(t('common.confirmDelete'))) {
                    remove.mutate();
                  }
                }}
              >
                {t('common.delete')}
              </Button>
              <Button variant="secondary" asChild>
                <Link to={`/crm`}>CRM</Link>
              </Button>
            </div>
          </div>
        </div>
        <div className="grid gap-3 p-5 md:grid-cols-4">
          <StatTile label="Phone" value={d.phone || '—'} />
          <StatTile label="Locale" value={d.locale?.toUpperCase() || 'EN'} />
          <StatTile label="Joined" value={new Date(d.createdAt).toLocaleDateString()} hint={d.lastLoginAt ? `Last login ${new Date(d.lastLoginAt).toLocaleString()}` : 'Never logged in'} />
          <StatTile label="Paid" value={money(spent)} hint={`${d.bookings.length} bookings`} />
        </div>
      </div>

      <Section title={`${t('nav.bookings')} (${d.bookings.length})`}>
        {d.bookings.length === 0 ? (
          <EmptyHint>No bookings yet</EmptyHint>
        ) : (
          <div className="grid gap-2">
            {d.bookings.map((b) => (
              <Link key={b.id} to={`/bookings/${b.id}`} className="flex items-center justify-between gap-3 rounded-xl border px-3 py-3 hover:bg-[#f5f7fa]">
                <div>
                  <p className="font-extrabold text-[#003580]">{b.bookingNumber}</p>
                  <p className="text-xs text-muted-foreground">
                    {b.type} · {loc(b.vendor?.businessName ?? b.listing?.title ?? b.venue?.name ?? b.car?.name, i18n.language)} · {new Date(b.startAt).toLocaleString()}
                  </p>
                </div>
                <div className="text-end">
                  <StatusBadge status={b.status} />
                  <p className="mt-1 text-sm font-bold">{money(b.totalAmount, b.currency)}</p>
                </div>
              </Link>
            ))}
          </div>
        )}
      </Section>

      <div className="grid gap-4 lg:grid-cols-2">
        <Section title={`${t('dashboard.events')} (${d.events.length})`}>
          {d.events.length === 0 ? (
            <EmptyHint>No events</EmptyHint>
          ) : (
            <div className="space-y-2 text-sm">
              {d.events.map((e) => (
                <div key={e.id} className="rounded-xl border px-3 py-3">
                  <p className="font-semibold">{loc(e.title, i18n.language)}</p>
                  <p className="text-xs text-muted-foreground">
                    {loc(e.category?.name, i18n.language)} · {e.city || '—'} · {new Date(e.eventDate).toLocaleDateString()} · {e.guestCount ?? 0} guests
                  </p>
                </div>
              ))}
            </div>
          )}
        </Section>
        <Section title={`${t('nav.payments')} (${d.payments.length})`}>
          {d.payments.length === 0 ? (
            <EmptyHint>No payments</EmptyHint>
          ) : (
            <div className="space-y-2 text-sm">
              {d.payments.map((p) => (
                <div key={p.id} className="flex items-center justify-between rounded-xl border px-3 py-2">
                  <span>
                    {p.kind} · {new Date(p.createdAt).toLocaleDateString()}
                  </span>
                  <span className="flex items-center gap-2">
                    <StatusBadge status={p.status} />
                    {money(p.amount, p.currency)}
                  </span>
                </div>
              ))}
            </div>
          )}
        </Section>
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <Section title={`Venue visits (${d.venueVisits?.length ?? 0})`}>
          {(d.venueVisits ?? []).length === 0 ? (
            <EmptyHint>No visits</EmptyHint>
          ) : (
            <div className="space-y-2 text-sm">
              {d.venueVisits.map((v) => (
                <div key={v.id} className="flex items-center justify-between rounded-xl border px-3 py-2">
                  <span>{loc(v.venue?.name, i18n.language)}</span>
                  <StatusBadge status={v.status} />
                </div>
              ))}
            </div>
          )}
        </Section>
        <Section title={`Saved items (${d.favorites?.length ?? 0})`}>
          {(d.favorites ?? []).length === 0 ? (
            <EmptyHint>No favorites</EmptyHint>
          ) : (
            <div className="space-y-2 text-sm">
              {d.favorites.map((f) => (
                <div key={f.id} className="rounded-xl border px-3 py-2">
                  {f.resourceType} · {f.resourceId}
                </div>
              ))}
            </div>
          )}
        </Section>
      </div>
      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{t('common.edit')}</DialogTitle>
          </DialogHeader>
          <form className="space-y-3" onSubmit={form.handleSubmit((v) => save.mutate(v))}>
            <div className="grid gap-3 md:grid-cols-2">
              <div>
                <Label>{t('common.firstName')}</Label>
                <Input {...form.register('firstName')} />
              </div>
              <div>
                <Label>{t('common.lastName')}</Label>
                <Input {...form.register('lastName')} />
              </div>
              <div>
                <Label>{t('common.phone')}</Label>
                <Input {...form.register('phone')} />
              </div>
              <div>
                <Label>{t('common.country')}</Label>
                <select className="h-10 w-full rounded-md border px-2 text-sm" {...form.register('country')}>
                  {COUNTRIES.map((row) => (
                    <option key={row.code} value={row.code}>
                      {row.name}
                    </option>
                  ))}
                </select>
              </div>
            </div>
            <FileUpload label={t('common.upload')} folder="avatars" onUploaded={(f) => form.setValue('avatarKey', f.url || f.key)} />
            <div>
              <Label>{t('auth.password')}</Label>
              <Input type="password" placeholder="Leave blank to keep" {...form.register('password')} />
            </div>
            <Button type="submit">{t('common.save')}</Button>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
