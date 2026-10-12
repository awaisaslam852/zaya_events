import { useState } from 'react';
import { FormProvider, useForm } from 'react-hook-form';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { asLoc, coverOf, loc, money } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { StatusBadge } from '@/components/StatusBadge';
import { BackLink, EmptyHint, GalleryStrip, Section, StatTile } from '@/components/AdminChrome';
import { LocalizedFields } from '@/components/LocalizedFields';
import { FileUpload, GalleryUpload } from '@/components/FileUpload';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { toast } from 'sonner';

type Catalog = {
  id: string;
  title?: unknown;
  name?: unknown;
  startingPrice?: string;
  dailyRate?: string;
  nightlyRate?: string;
  priceAmount?: string;
  city?: string | null;
  coverKey?: string | null;
  galleryKeys?: unknown;
  isPublished?: boolean;
  category?: { name: unknown };
};

type Vendor = {
  id: string;
  status: string;
  commissionRate: string;
  city: string | null;
  country: string | null;
  phone: string | null;
  website: string | null;
  ratingAvg: string;
  ratingCount: number;
  coverKey: string | null;
  galleryKeys?: unknown;
  businessName: unknown;
  description: unknown;
  legalName: string | null;
  taxId: string | null;
  user: { id: string; email: string; firstName: string; lastName: string; phone: string | null };
  listings: Catalog[];
  cars: Catalog[];
  venues: Catalog[];
  accommodations: Catalog[];
  honeymoonPackages: Catalog[];
  representatives: Array<{ id: string; name: unknown }>;
  payouts: Array<{ id: string; amount: string; status: string; currency?: string }>;
};

type VendorEdit = {
  firstName: string;
  lastName: string;
  businessName: { en: string; ar: string };
  description: { en: string; ar: string };
  city: string;
  phone: string;
  legalName: string;
  taxId: string;
  website: string;
  coverKey: string;
  galleryKeys: string[];
};

export function VendorDetailPage() {
  const { t, i18n } = useTranslation();
  const { id } = useParams();
  const navigate = useNavigate();
  const qc = useQueryClient();
  const [rate, setRate] = useState('');
  const [open, setOpen] = useState(false);
  const form = useForm<VendorEdit>();
  const vendor = useQuery({
    queryKey: ['vendor', id],
    queryFn: async () => {
      const data = await unwrap<Vendor>(api.get(`/api/v1/vendors/${id}`));
      setRate(String(data.commissionRate));
      return data;
    },
    enabled: Boolean(id),
  });
  const bookings = useQuery({
    queryKey: ['vendor-bookings', id],
    queryFn: () =>
      unwrap<Paginated<{ id: string; bookingNumber: string; status: string; totalAmount: string; type: string }>>(
        api.get('/api/v1/bookings', { params: { vendorId: id, pageSize: 40 } }),
      ),
    enabled: Boolean(id),
  });
  const commissions = useQuery({
    queryKey: ['vendor-commissions', id],
    queryFn: () => unwrap<Paginated<{ id: string; amount: string; status: string }>>(api.get('/api/v1/commissions', { params: { vendorId: id } })),
    enabled: Boolean(id),
  });
  const act = useMutation({
    mutationFn: (action: 'approve' | 'reject') => unwrap(api.post(`/api/v1/vendors/${id}/${action}`, {})),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['vendor', id] }),
    onError: (e: Error) => toast.error(e.message),
  });
  const patch = useMutation({
    mutationFn: (body: Record<string, unknown>) => unwrap(api.patch(`/api/v1/vendors/${id}`, body)),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['vendor', id] });
      setOpen(false);
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const remove = useMutation({
    mutationFn: () => unwrap(api.delete(`/api/v1/vendors/${id}`)),
    onSuccess: () => {
      toast.success(t('common.delete'));
      navigate('/vendors');
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const v = vendor.data;
  if (!v) {
    return <p>{t('common.loading')}</p>;
  }
  const hero = coverOf(v);

  return (
    <div className="space-y-5">
      <BackLink to="/vendors" label={t('nav.vendors')} />
      <div className="overflow-hidden rounded-3xl border bg-white shadow-sm">
        <div className="relative h-52 bg-[#003580]">
          {hero ? <img src={hero} alt="" className="h-full w-full object-cover opacity-80" /> : null}
          <div className="absolute inset-0 bg-gradient-to-t from-[#003580] to-transparent" />
          <div className="absolute bottom-5 start-6 end-6 flex flex-wrap items-end justify-between gap-3 text-white">
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.2em] text-[#FEBB02]">Vendor partner</p>
              <h1 className="text-3xl font-extrabold">{loc(v.businessName, i18n.language)}</h1>
              <p className="text-white/80">
                {v.user.firstName} {v.user.lastName} · {v.user.email}
              </p>
            </div>
            <StatusBadge status={v.status} />
          </div>
        </div>
        <div className="flex flex-wrap gap-2 p-4">
          <Button
            variant="secondary"
            onClick={() => {
              form.reset({
                firstName: v.user.firstName,
                lastName: v.user.lastName,
                businessName: asLoc(v.businessName),
                description: asLoc(v.description),
                city: v.city ?? '',
                phone: v.phone ?? v.user.phone ?? '',
                legalName: v.legalName ?? '',
                taxId: v.taxId ?? '',
                website: v.website ?? '',
                coverKey: v.coverKey ?? '',
                galleryKeys: Array.isArray(v.galleryKeys) ? v.galleryKeys.map(String) : [],
              });
              setOpen(true);
            }}
          >
            {t('common.edit')}
          </Button>
          <Button onClick={() => act.mutate('approve')}>{t('common.approve')}</Button>
          <Button variant="destructive" onClick={() => act.mutate('reject')}>
            {t('common.reject')}
          </Button>
          <Button variant="outline" onClick={() => patch.mutate({ status: 'SUSPENDED' })}>
            Suspend
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
          <div className="ms-auto flex items-center gap-2">
            <Input className="w-24" value={rate} onChange={(e) => setRate(e.target.value)} />
            <Button variant="cta" onClick={() => patch.mutate({ commissionRate: Number(rate) })}>
              Save rate %
            </Button>
          </div>
        </div>
      </div>

      <div className="grid gap-3 md:grid-cols-4">
        <StatTile label="City" value={v.city || '—'} hint={v.country || ''} />
        <StatTile label="Phone" value={v.phone || v.user.phone || '—'} />
        <StatTile label="Commission" value={`${v.commissionRate}%`} />
        <StatTile label="Rating" value={`${v.ratingAvg} ★`} hint={`${v.ratingCount} reviews`} />
      </div>
      <Section title="About">
        <p className="text-sm leading-6 text-muted-foreground">{loc(v.description, i18n.language)}</p>
        <p className="mt-2 text-xs text-muted-foreground">
          Legal: {v.legalName || '—'} · Tax: {v.taxId || '—'} · {v.website || ''}
        </p>
        <div className="mt-4">
          <GalleryStrip items={[v, ...v.venues, ...v.listings, ...v.cars]} />
        </div>
      </Section>

      <CatalogGrid title={`Listings (${v.listings.length})`} items={v.listings} lang={i18n.language} href="/listings" />
      <CatalogGrid title={`Cars (${v.cars?.length ?? 0})`} items={v.cars ?? []} lang={i18n.language} href="/cars" />
      <CatalogGrid title={`Venues (${v.venues?.length ?? 0})`} items={v.venues ?? []} lang={i18n.language} href="/venues" />
      <CatalogGrid title={`Stays (${v.accommodations?.length ?? 0})`} items={v.accommodations ?? []} lang={i18n.language} href="/accommodations" />
      <CatalogGrid title={`Honeymoon (${v.honeymoonPackages?.length ?? 0})`} items={v.honeymoonPackages ?? []} lang={i18n.language} href="/honeymoon" />

      <div className="grid gap-4 lg:grid-cols-2">
        <Section title={`${t('nav.bookings')} (${bookings.data?.total ?? 0})`}>
          {(bookings.data?.items ?? []).length === 0 ? (
            <EmptyHint>No bookings</EmptyHint>
          ) : (
            <div className="space-y-2">
              {(bookings.data?.items ?? []).map((b) => (
                <Link key={b.id} to={`/bookings/${b.id}`} className="flex items-center justify-between rounded-xl border px-3 py-2 hover:bg-[#f5f7fa]">
                  <span className="text-sm font-semibold">
                    {b.bookingNumber} · {b.type}
                  </span>
                  <StatusBadge status={b.status} />
                </Link>
              ))}
            </div>
          )}
        </Section>
        <Section title={`${t('nav.payouts')} / ${t('nav.commissions')}`}>
          <div className="space-y-2 text-sm">
            {v.payouts.map((p) => (
              <div key={p.id} className="flex justify-between rounded-xl border px-3 py-2">
                <span>{money(p.amount, p.currency)}</span>
                <StatusBadge status={p.status} />
              </div>
            ))}
            {(commissions.data?.items ?? []).map((c) => (
              <div key={c.id} className="flex justify-between rounded-xl border px-3 py-2">
                <span>{money(c.amount)}</span>
                <StatusBadge status={c.status} />
              </div>
            ))}
            {v.representatives.length > 0 ? (
              <p className="pt-2 text-xs text-muted-foreground">
                Reps: {v.representatives.map((r) => loc(r.name, i18n.language)).join(', ')}
              </p>
            ) : null}
          </div>
        </Section>
      </div>
      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="max-h-[90vh] max-w-2xl overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{t('common.edit')}</DialogTitle>
          </DialogHeader>
          <FormProvider {...form}>
            <form
              className="space-y-3"
              onSubmit={form.handleSubmit((values) =>
                patch.mutate({
                  firstName: values.firstName,
                  lastName: values.lastName,
                  businessName: values.businessName,
                  description: values.description,
                  city: values.city || undefined,
                  phone: values.phone || undefined,
                  legalName: values.legalName || undefined,
                  taxId: values.taxId || undefined,
                  website: values.website.trim() || undefined,
                  coverKey: values.coverKey || undefined,
                  galleryKeys: values.galleryKeys,
                }),
              )}
            >
              <div className="grid grid-cols-2 gap-2">
                <div>
                  <Label>{t('common.firstName')}</Label>
                  <Input {...form.register('firstName')} />
                </div>
                <div>
                  <Label>{t('common.lastName')}</Label>
                  <Input {...form.register('lastName')} />
                </div>
                <div>
                  <Label>{t('common.city')}</Label>
                  <Input {...form.register('city')} />
                </div>
                <div>
                  <Label>{t('common.phone')}</Label>
                  <Input {...form.register('phone')} />
                </div>
                <div>
                  <Label>{t('common.legalName')}</Label>
                  <Input {...form.register('legalName')} />
                </div>
                <div>
                  <Label>{t('common.taxId')}</Label>
                  <Input {...form.register('taxId')} />
                </div>
              </div>
              <div>
                <Label>{t('common.website')}</Label>
                <Input {...form.register('website')} />
              </div>
              <LocalizedFields name="businessName" />
              <LocalizedFields name="description" textarea />
              <FileUpload label="Cover" folder="vendors" onUploaded={(f) => form.setValue('coverKey', f.url || f.key)} />
              <GalleryUpload
                label={t('common.photos')}
                folder="vendors"
                keys={form.watch('galleryKeys') ?? []}
                onChange={(keys) => form.setValue('galleryKeys', keys)}
              />
              <Button type="submit">{t('common.save')}</Button>
            </form>
          </FormProvider>
        </DialogContent>
      </Dialog>
    </div>
  );
}

function CatalogGrid({
  title,
  items,
  lang,
  href,
}: {
  title: string;
  items: Catalog[];
  lang: string;
  href: string;
}) {
  return (
    <Section title={title}>
      {items.length === 0 ? (
        <EmptyHint>Nothing published here</EmptyHint>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
          {items.map((item) => {
            const photo = coverOf(item);
            const price = item.startingPrice ?? item.dailyRate ?? item.nightlyRate ?? item.priceAmount;
            return (
              <Link key={item.id} to={`${href}/${item.id}`} className="overflow-hidden rounded-xl border hover:shadow-md">
                <div className="h-28 bg-[#d6e6f5]">{photo ? <img src={photo} alt="" className="h-28 w-full object-cover" /> : null}</div>
                <div className="p-3">
                  <p className="line-clamp-2 text-sm font-bold">{loc(item.title ?? item.name, lang)}</p>
                  <p className="mt-1 text-xs text-muted-foreground">{item.city || loc(item.category?.name, lang)}</p>
                  {price ? <p className="mt-1 text-sm font-extrabold text-[#003580]">{money(price)}</p> : null}
                </div>
              </Link>
            );
          })}
        </div>
      )}
    </Section>
  );
}
