import { useState } from 'react';
import { FormProvider, useForm } from 'react-hook-form';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap } from '@/lib/api';
import { asLoc, coverOf, loc, mediaUrl, money } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { StatusBadge } from '@/components/StatusBadge';
import { BackLink, EmptyHint, FactGrid, Section } from '@/components/AdminChrome';
import { LocalizedFields } from '@/components/LocalizedFields';
import { FileUpload, GalleryUpload } from '@/components/FileUpload';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { toast } from 'sonner';

type Kind = 'listings' | 'venues' | 'cars' | 'accommodations' | 'honeymoon';

const META: Record<Kind, { path: string; back: string; labelKey: string; kicker: string; folder: string }> = {
  listings: { path: '/api/v1/listings', back: '/listings', labelKey: 'nav.listings', kicker: 'Service listing', folder: 'listings' },
  venues: { path: '/api/v1/venues', back: '/venues', labelKey: 'nav.venues', kicker: 'Venue', folder: 'venues' },
  cars: { path: '/api/v1/cars', back: '/cars', labelKey: 'nav.cars', kicker: 'Car', folder: 'cars' },
  accommodations: { path: '/api/v1/accommodations', back: '/accommodations', labelKey: 'nav.accommodations', kicker: 'Stay', folder: 'stays' },
  honeymoon: { path: '/api/v1/honeymoon', back: '/honeymoon', labelKey: 'nav.honeymoon', kicker: 'Honeymoon', folder: 'honeymoon' },
};

type Catalog = {
  id: string;
  title?: unknown;
  name?: unknown;
  description?: unknown;
  address?: unknown;
  destination?: unknown;
  city?: string | null;
  country?: string | null;
  make?: string;
  model?: string;
  year?: number;
  seats?: number;
  transmission?: string;
  dailyRate?: string;
  nightlyRate?: string;
  startingPrice?: string;
  priceAmount?: string;
  currency?: string;
  capacityMin?: number;
  capacityMax?: number;
  maxGuests?: number;
  bedrooms?: number;
  bathrooms?: number;
  nights?: number;
  type?: string;
  isPublished?: boolean;
  coverKey?: string | null;
  galleryKeys?: unknown;
  vendor?: { id: string; businessName: unknown };
  category?: { name: unknown };
  packages?: Array<{ id: string; name?: unknown; title?: unknown; priceAmount?: string; price?: string }>;
};

type EditForm = {
  title: { en: string; ar: string };
  description: { en: string; ar: string };
  city: string;
  country: string;
  price: string;
  coverKey: string;
  galleryKeys: string[];
  isPublished: boolean;
};

function keysOf(value: unknown): string[] {
  return Array.isArray(value) ? value.map(String) : [];
}

export function CatalogDetailPage({ kind }: { kind: Kind }) {
  const { t, i18n } = useTranslation();
  const { id } = useParams();
  const navigate = useNavigate();
  const qc = useQueryClient();
  const meta = META[kind];
  const [open, setOpen] = useState(false);
  const form = useForm<EditForm>({
    defaultValues: {
      title: { en: '', ar: '' },
      description: { en: '', ar: '' },
      city: '',
      country: '',
      price: '',
      coverKey: '',
      galleryKeys: [],
      isPublished: true,
    },
  });
  const q = useQuery({
    queryKey: [kind, id],
    queryFn: () => unwrap<Catalog>(api.get(`${meta.path}/${id}`)),
    enabled: Boolean(id),
  });
  const publish = useMutation({
    mutationFn: () => unwrap(api.patch(`${meta.path}/${id}`, { isPublished: !q.data?.isPublished })),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: [kind, id] });
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const save = useMutation({
    mutationFn: (values: EditForm) => {
      const price = values.price ? Number(values.price) : undefined;
      const body: Record<string, unknown> = {
        description: values.description,
        city: values.city || undefined,
        country: values.country || undefined,
        coverKey: values.coverKey || undefined,
        galleryKeys: values.galleryKeys,
        isPublished: values.isPublished,
      };
      if (kind === 'listings') {
        body.title = values.title;
        if (price !== undefined) {
          body.startingPrice = price;
        }
      } else {
        body.name = values.title;
        if (price !== undefined) {
          if (kind === 'cars') {
            body.dailyRate = price;
          } else if (kind === 'accommodations') {
            body.nightlyRate = price;
          } else if (kind === 'honeymoon') {
            body.priceAmount = price;
          }
        }
      }
      return unwrap(api.patch(`${meta.path}/${id}`, body));
    },
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: [kind, id] });
      setOpen(false);
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const remove = useMutation({
    mutationFn: () => unwrap(api.delete(`${meta.path}/${id}`)),
    onSuccess: () => {
      toast.success(t('common.delete'));
      navigate(meta.back);
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const d = q.data;
  if (!d) {
    return <p>{t('common.loading')}</p>;
  }
  const title = loc(d.title ?? d.name, i18n.language);
  const hero = coverOf(d);
  const gallery = keysOf(d.galleryKeys).map((k) => mediaUrl(String(k)));
  const price = d.startingPrice ?? d.dailyRate ?? d.nightlyRate ?? d.priceAmount;
  const facts = [
    { label: t('common.city'), value: [d.city, d.country].filter(Boolean).join(', ') },
    { label: t('common.price'), value: price ? money(price, d.currency) : '' },
    { label: 'Capacity', value: d.capacityMax ? `${d.capacityMin ?? 0}–${d.capacityMax}` : d.maxGuests ? `${d.maxGuests} guests` : d.seats ? `${d.seats} seats` : '' },
    { label: 'Type', value: d.type ?? d.transmission ?? d.make ?? loc(d.category?.name, i18n.language) },
    { label: 'Rooms', value: d.bedrooms ? `${d.bedrooms} bed · ${d.bathrooms ?? 0} bath` : d.nights ? `${d.nights} nights` : d.year ? String(d.year) : '' },
    { label: 'Model', value: [d.make, d.model].filter(Boolean).join(' ') },
  ].filter((f) => f.value);

  function openEdit(row: Catalog) {
    const currentPrice = row.startingPrice ?? row.dailyRate ?? row.nightlyRate ?? row.priceAmount;
    form.reset({
      title: asLoc(row.title ?? row.name),
      description: asLoc(row.description),
      city: row.city ?? '',
      country: row.country ?? '',
      price: String(currentPrice ?? ''),
      coverKey: row.coverKey ?? '',
      galleryKeys: keysOf(row.galleryKeys),
      isPublished: row.isPublished !== false,
    });
    setOpen(true);
  }

  return (
    <div className="space-y-5">
      <BackLink to={meta.back} label={t(meta.labelKey)} />
      <div className="overflow-hidden rounded-3xl border bg-white shadow-sm">
        <div className="relative h-56 bg-[#003580]">
          {hero ? <img src={hero} alt="" className="h-full w-full object-cover opacity-85" /> : null}
          <div className="absolute inset-0 bg-gradient-to-t from-[#003580] to-transparent" />
          <div className="absolute bottom-5 start-6 end-6 flex flex-wrap items-end justify-between gap-3 text-white">
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.2em] text-[#FEBB02]">{meta.kicker}</p>
              <h1 className="text-3xl font-extrabold">{title}</h1>
              {d.vendor ? (
                <Link className="text-sm text-white/85 underline" to={`/vendors/${d.vendor.id}`}>
                  {loc(d.vendor.businessName, i18n.language)}
                </Link>
              ) : null}
            </div>
            {d.isPublished !== undefined ? <StatusBadge status={d.isPublished ? 'ACTIVE' : 'INACTIVE'} /> : null}
          </div>
        </div>
        <div className="space-y-4 p-5">
          <div className="flex flex-wrap gap-2">
            <Button size="sm" onClick={() => openEdit(d)}>
              {t('common.edit')}
            </Button>
            {d.isPublished !== undefined ? (
              <Button size="sm" variant="outline" onClick={() => publish.mutate()}>
                {d.isPublished ? 'Unpublish' : 'Publish'}
              </Button>
            ) : null}
            <Button
              size="sm"
              variant="destructive"
              onClick={() => {
                if (window.confirm(t('common.confirmDelete'))) {
                  remove.mutate();
                }
              }}
            >
              {t('common.delete')}
            </Button>
          </div>
          <FactGrid items={facts} />
          {d.description ? <p className="text-sm leading-relaxed text-muted-foreground">{loc(d.description, i18n.language)}</p> : null}
          {d.address ? <p className="text-sm">{loc(d.address, i18n.language)}</p> : null}
          {d.destination ? <p className="text-sm">{loc(d.destination, i18n.language)}</p> : null}
        </div>
      </div>
      <Section title={`Photos (${gallery.length || (hero ? 1 : 0)})`}>
        {gallery.length || hero ? (
          <div className="grid grid-cols-2 gap-2 md:grid-cols-4">
            {(gallery.length ? gallery : [hero]).map((src) => (
              <a key={src} href={src} target="_blank" rel="noreferrer">
                <img src={src} alt="" className="h-32 w-full rounded-xl object-cover" />
              </a>
            ))}
          </div>
        ) : (
          <EmptyHint>No photos yet</EmptyHint>
        )}
      </Section>
      <Section title={`Packages (${d.packages?.length ?? 0})`}>
        {(d.packages ?? []).length === 0 ? (
          <EmptyHint>{t('common.empty')}</EmptyHint>
        ) : (
          <div className="grid gap-2 md:grid-cols-2">
            {(d.packages ?? []).map((pkg) => (
              <div key={pkg.id} className="rounded-xl border px-3 py-2">
                <p className="font-semibold">{loc(pkg.name ?? pkg.title, i18n.language) || 'Package'}</p>
                <p className="text-sm text-muted-foreground">{pkg.priceAmount || pkg.price ? money(pkg.priceAmount ?? pkg.price) : '—'}</p>
              </div>
            ))}
          </div>
        )}
      </Section>
      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="max-h-[90vh] max-w-2xl overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{t('common.edit')}</DialogTitle>
          </DialogHeader>
          <FormProvider {...form}>
            <form className="space-y-3" onSubmit={form.handleSubmit((v) => save.mutate(v))}>
              <LocalizedFields name="title" label={kind === 'listings' ? 'Title' : 'Name'} />
              <LocalizedFields name="description" textarea />
              <div className="grid grid-cols-2 gap-2">
                <div>
                  <Label>{t('common.city')}</Label>
                  <Input {...form.register('city')} />
                </div>
                <div>
                  <Label>Country</Label>
                  <Input {...form.register('country')} />
                </div>
                <div>
                  <Label>{t('common.price')}</Label>
                  <Input type="number" step="any" {...form.register('price')} />
                </div>
              </div>
              <label className="flex items-center gap-2 text-sm">
                <input type="checkbox" {...form.register('isPublished')} />
                {t('common.status')}
              </label>
              <FileUpload label="Cover" folder={meta.folder} onUploaded={(f) => form.setValue('coverKey', f.url || f.key)} />
              <GalleryUpload
                label={t('common.photos')}
                folder={meta.folder}
                keys={form.watch('galleryKeys') ?? []}
                onChange={(keys) => {
                  form.setValue('galleryKeys', keys);
                  if (!form.getValues('coverKey') && keys[0]) {
                    form.setValue('coverKey', keys[0]);
                  }
                }}
              />
              <Button type="submit">{t('common.save')}</Button>
            </form>
          </FormProvider>
        </DialogContent>
      </Dialog>
    </div>
  );
}

export function ListingDetailPage() {
  return <CatalogDetailPage kind="listings" />;
}
export function VenueDetailPage() {
  return <CatalogDetailPage kind="venues" />;
}
export function CarDetailPage() {
  return <CatalogDetailPage kind="cars" />;
}
export function StayDetailPage() {
  return <CatalogDetailPage kind="accommodations" />;
}
export function HoneymoonDetailPage() {
  return <CatalogDetailPage kind="honeymoon" />;
}
