import { useState } from 'react';
import { FormProvider, useForm } from 'react-hook-form';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap } from '@/lib/api';
import { APP_CURRENCIES, assignableCountries, countryName } from '@/lib/countries';
import { asLoc, coverOf, loc, mediaUrl, money } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { BackLink, EmptyHint, FactGrid, Field, FormSection, NativeSelect, Section } from '@/components/AdminChrome';
import { LocalizedFields } from '@/components/LocalizedFields';
import { FileUpload, GalleryUpload } from '@/components/FileUpload';
import { StatusBadge } from '@/components/StatusBadge';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { toast } from 'sonner';

type Kind = 'listings' | 'venues' | 'cars' | 'accommodations' | 'honeymoon';
type PricingModel = 'HIRE' | 'PER_GUEST' | 'HYBRID';
type PricingUnit = 'EVENT' | 'GUEST';

const META: Record<Kind, { path: string; back: string; labelKey: string; kicker: string; folder: string }> = {
  listings: { path: '/api/v1/listings', back: '/listings', labelKey: 'nav.listings', kicker: 'Service listing', folder: 'listings' },
  venues: { path: '/api/v1/venues', back: '/venues', labelKey: 'nav.venues', kicker: 'Venue', folder: 'venues' },
  cars: { path: '/api/v1/cars', back: '/cars', labelKey: 'nav.cars', kicker: 'Car', folder: 'cars' },
  accommodations: { path: '/api/v1/accommodations', back: '/accommodations', labelKey: 'nav.accommodations', kicker: 'Stay', folder: 'stays' },
  honeymoon: { path: '/api/v1/honeymoon', back: '/honeymoon', labelKey: 'nav.honeymoon', kicker: 'Honeymoon', folder: 'honeymoon' },
};

type CatalogPackage = {
  id: string;
  name?: unknown;
  title?: unknown;
  description?: unknown;
  priceAmount?: string;
  price?: string;
  currency?: string;
  pricingUnit?: PricingUnit;
  guestCountMin?: number;
  guestCountMax?: number;
  durationHours?: number;
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
  pricingModel?: PricingModel;
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
  vendor?: { id: string; businessName: unknown; country?: string | null };
  category?: { name: unknown };
  packages?: CatalogPackage[];
};

type EditForm = {
  title: { en: string; ar: string };
  description: { en: string; ar: string };
  address: { en: string; ar: string };
  city: string;
  country: string;
  price: string;
  currency: string;
  pricingModel: PricingModel;
  capacityMin: string;
  capacityMax: string;
  coverKey: string;
  galleryKeys: string[];
  isPublished: boolean;
};

type PackageForm = {
  name: { en: string; ar: string };
  description: { en: string; ar: string };
  priceAmount: string;
  pricingUnit: PricingUnit;
  guestCountMin: string;
  guestCountMax: string;
  durationHours: string;
};

function keysOf(value: unknown): string[] {
  return Array.isArray(value) ? value.map(String) : [];
}

function priceOf(row: Catalog): string {
  return String(row.startingPrice ?? row.dailyRate ?? row.nightlyRate ?? row.priceAmount ?? '');
}

export function CatalogDetailPage({ kind }: { kind: Kind }) {
  const { t, i18n } = useTranslation();
  const { id } = useParams();
  const navigate = useNavigate();
  const qc = useQueryClient();
  const meta = META[kind];
  const [open, setOpen] = useState(false);
  const [pkgOpen, setPkgOpen] = useState(false);
  const form = useForm<EditForm>({
    defaultValues: {
      title: { en: '', ar: '' },
      description: { en: '', ar: '' },
      address: { en: '', ar: '' },
      city: '',
      country: '',
      price: '',
      currency: 'AED',
      pricingModel: 'HYBRID',
      capacityMin: '50',
      capacityMax: '300',
      coverKey: '',
      galleryKeys: [],
      isPublished: true,
    },
  });
  const pkgForm = useForm<PackageForm>({
    defaultValues: {
      name: { en: '', ar: '' },
      description: { en: '', ar: '' },
      priceAmount: '',
      pricingUnit: 'EVENT',
      guestCountMin: '50',
      guestCountMax: '300',
      durationHours: '4',
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
      const price = values.price.trim() === '' ? 0 : Number(values.price);
      const body: Record<string, unknown> = {
        description: values.description,
        city: values.city || undefined,
        coverKey: values.coverKey || undefined,
        galleryKeys: values.galleryKeys,
        isPublished: values.isPublished,
      };
      if (kind === 'listings') {
        body.title = values.title;
        body.startingPrice = price;
        body.currency = values.currency;
      } else {
        body.name = values.title;
        if (kind === 'cars') {
          body.dailyRate = price;
        } else if (kind === 'accommodations') {
          body.address = values.address;
          body.nightlyRate = price;
        } else if (kind === 'honeymoon') {
          body.priceAmount = price;
        } else if (kind === 'venues') {
          body.address = values.address;
          body.startingPrice = price;
          body.currency = values.currency;
          body.pricingModel = values.pricingModel;
          body.capacityMin = Number(values.capacityMin) || undefined;
          body.capacityMax = Number(values.capacityMax) || undefined;
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
  const savePackage = useMutation({
    mutationFn: (values: PackageForm) => {
      const amount = Number(values.priceAmount);
      if (!values.name.en.trim() || !Number.isFinite(amount) || amount < 0) {
        throw new Error(t('common.requiredFields', { defaultValue: 'Fill the package name and price.' }));
      }
      return unwrap(
        api.post(`${meta.path}/${id}/packages`, {
          name: values.name,
          description: values.description.en.trim() ? values.description : values.name,
          priceAmount: amount,
          pricingUnit: values.pricingUnit,
          guestCountMin: Number(values.guestCountMin) || 1,
          guestCountMax: Number(values.guestCountMax) || 500,
          durationHours: Number(values.durationHours) || 4,
          currency: q.data?.currency,
        }),
      );
    },
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: [kind, id] });
      setPkgOpen(false);
      pkgForm.reset();
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const removePackage = useMutation({
    mutationFn: (packageId: string) => unwrap(api.delete(`${meta.path}/${id}/packages/${packageId}`)),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: [kind, id] });
      toast.success(t('common.delete'));
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
  const storedPrice = priceOf(d);
  const showPrice = Number(storedPrice) > 0;
  const priceLabel =
    kind === 'cars' ? t('common.dailyRate') : kind === 'accommodations' ? t('pricing.nightly') : t('pricing.startingFrom');
  const pricingHint =
    d.pricingModel === 'PER_GUEST'
      ? t('pricing.perGuestHint')
      : d.pricingModel === 'HIRE'
        ? t('pricing.hireHint')
        : t('pricing.hybridHint');
  const facts = [
    {
      label: t('common.city'),
      value: [d.city, countryName(d.vendor?.country ?? d.country ?? '')].filter(Boolean).join(', '),
    },
    {
      label: priceLabel,
      value: showPrice
        ? `${money(storedPrice, d.currency)}${d.pricingModel === 'PER_GUEST' ? ` ${t('pricing.perGuest')}` : ''}`
        : t('pricing.missing'),
    },
    {
      label: t('common.capacity'),
      value: d.capacityMax
        ? `${d.capacityMin ?? 0}–${d.capacityMax}`
        : d.maxGuests
          ? `${d.maxGuests} ${t('common.guests')}`
          : d.seats
            ? `${d.seats} ${t('common.seats')}`
            : '',
    },
    { label: t('pricing.model'), value: d.pricingModel ? t(`pricing.model${d.pricingModel}`) : '' },
    { label: t('common.type'), value: d.type ?? d.transmission ?? d.make ?? loc(d.category?.name, i18n.language) },
    { label: t('common.rooms'), value: d.bedrooms ? `${d.bedrooms} · ${d.bathrooms ?? 0}` : d.nights ? String(d.nights) : d.year ? String(d.year) : '' },
    { label: t('common.model'), value: [d.make, d.model].filter(Boolean).join(' ') },
  ].filter((f) => f.value);

  function openEdit(row: Catalog) {
    const currentPrice = priceOf(row);
    form.reset({
      title: asLoc(row.title ?? row.name),
      description: asLoc(row.description),
      address: asLoc(row.address),
      city: row.city ?? '',
      country: row.vendor?.country ?? row.country ?? '',
      price: Number(currentPrice) > 0 ? String(Number(currentPrice)) : '',
      currency: row.currency ?? 'AED',
      pricingModel: row.pricingModel ?? 'HYBRID',
      capacityMin: String(row.capacityMin ?? 50),
      capacityMax: String(row.capacityMax ?? 300),
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
          <div className="absolute bottom-4 start-4 end-4 flex flex-wrap items-end justify-between gap-3 text-white sm:bottom-5 sm:start-6 sm:end-6">
            <div className="min-w-0">
              <p className="text-xs font-semibold uppercase tracking-[0.2em] text-[#FEBB02]">{meta.kicker}</p>
              <h1 className="text-2xl font-extrabold sm:text-3xl">{title}</h1>
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
          {kind === 'venues' ? <p className="text-sm text-muted-foreground">{pricingHint}</p> : null}
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
          <EmptyHint>{t('common.noPhotos')}</EmptyHint>
        )}
      </Section>
      {kind === 'venues' || kind === 'listings' ? (
        <Section
          title={`${t('pricing.packages')} (${d.packages?.length ?? 0})`}
          action={
            kind === 'venues' ? (
              <Button
                size="sm"
                onClick={() => {
                  pkgForm.reset({
                    name: { en: '', ar: '' },
                    description: { en: '', ar: '' },
                    priceAmount: '',
                    pricingUnit: d.pricingModel === 'PER_GUEST' ? 'GUEST' : 'EVENT',
                    guestCountMin: String(d.capacityMin ?? 50),
                    guestCountMax: String(d.capacityMax ?? 300),
                    durationHours: '4',
                  });
                  setPkgOpen(true);
                }}
              >
                {t('pricing.addPackage')}
              </Button>
            ) : null
          }
        >
          {(d.packages ?? []).length === 0 ? (
            <EmptyHint>{t('pricing.noPackages')}</EmptyHint>
          ) : (
            <div className="grid gap-2 md:grid-cols-2">
              {(d.packages ?? []).map((pkg) => (
                <div key={pkg.id} className="flex items-start justify-between gap-3 rounded-xl border px-3 py-3">
                  <div>
                    <p className="font-semibold">{loc(pkg.name ?? pkg.title, i18n.language) || t('pricing.package')}</p>
                    <p className="text-sm text-muted-foreground">
                      {pkg.priceAmount || pkg.price
                        ? `${money(pkg.priceAmount ?? pkg.price, pkg.currency ?? d.currency)} ${
                            pkg.pricingUnit === 'GUEST' ? t('pricing.perGuest') : t('pricing.perEvent')
                          }`
                        : '—'}
                    </p>
                    <p className="text-xs text-muted-foreground">
                      {pkg.guestCountMin ?? 1}–{pkg.guestCountMax ?? d.capacityMax ?? 0} {t('common.guests')}
                      {pkg.durationHours ? ` · ${pkg.durationHours}h` : ''}
                    </p>
                  </div>
                  {kind === 'venues' ? (
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => {
                        if (window.confirm(t('common.confirmDelete'))) {
                          removePackage.mutate(pkg.id);
                        }
                      }}
                    >
                      {t('common.delete')}
                    </Button>
                  ) : null}
                </div>
              ))}
            </div>
          )}
        </Section>
      ) : null}

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="max-w-3xl">
          <DialogHeader>
            <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-[#003580]/55">{meta.kicker}</p>
            <DialogTitle>{t('common.edit')}</DialogTitle>
            <DialogDescription>{kind === 'venues' ? t('pricing.editHint') : t('common.languageHint')}</DialogDescription>
          </DialogHeader>
          <FormProvider {...form}>
            <form className="space-y-4" onSubmit={form.handleSubmit((v) => save.mutate(v))}>
              <FormSection title={t('pricing.details')}>
                <LocalizedFields name="title" label={kind === 'listings' ? 'Title' : t('common.name')} />
                <LocalizedFields name="description" textarea />
                {kind === 'venues' || kind === 'accommodations' ? (
                  <LocalizedFields name="address" label={t('common.address')} />
                ) : null}
                <div className="grid gap-3 sm:grid-cols-2">
                  <Field label={t('common.city')}>
                    <Input {...form.register('city')} />
                  </Field>
                  {kind !== 'venues' && kind !== 'accommodations' && kind !== 'listings' && kind !== 'cars' ? (
                    <Field label={t('common.country')}>
                      <NativeSelect {...form.register('country')}>
                        {assignableCountries().map((row) => (
                          <option key={row.code} value={row.code}>
                            {row.name}
                          </option>
                        ))}
                      </NativeSelect>
                    </Field>
                  ) : null}
                </div>
              </FormSection>
              {kind === 'venues' ? (
                <FormSection title={t('pricing.title')} hint={t('pricing.sectionHint')}>
                  <Field label={t('pricing.model')} hint={t('pricing.modelHelp')}>
                    <NativeSelect {...form.register('pricingModel')}>
                      <option value="HIRE">{t('pricing.modelHIRE')}</option>
                      <option value="PER_GUEST">{t('pricing.modelPER_GUEST')}</option>
                      <option value="HYBRID">{t('pricing.modelHYBRID')}</option>
                    </NativeSelect>
                  </Field>
                  <div className="grid gap-3 sm:grid-cols-3">
                    <Field
                      label={form.watch('pricingModel') === 'PER_GUEST' ? t('pricing.perGuestRate') : t('pricing.startingFrom')}
                      hint={t('pricing.startingHelp')}
                    >
                      <Input type="number" min="0" step="any" {...form.register('price')} />
                    </Field>
                    <Field label={t('pricing.currency')}>
                      <NativeSelect {...form.register('currency')}>
                        {APP_CURRENCIES.map((code) => (
                          <option key={code} value={code}>
                            {code}
                          </option>
                        ))}
                      </NativeSelect>
                    </Field>
                    <Field label={t('common.published')}>
                      <label className="flex h-10 items-center gap-2 text-sm">
                        <input type="checkbox" {...form.register('isPublished')} />
                        {t('common.published')}
                      </label>
                    </Field>
                  </div>
                  <div className="grid gap-3 sm:grid-cols-2">
                    <Field label={t('pricing.minGuests')}>
                      <Input type="number" min="1" {...form.register('capacityMin')} />
                    </Field>
                    <Field label={t('pricing.maxGuests')}>
                      <Input type="number" min="1" {...form.register('capacityMax')} />
                    </Field>
                  </div>
                </FormSection>
              ) : (
                <FormSection title={t('common.price')}>
                  <div className="grid gap-3 sm:grid-cols-2">
                    <Field label={priceLabel}>
                      <Input type="number" min="0" step="any" {...form.register('price')} />
                    </Field>
                    <Field label={t('common.published')}>
                      <label className="flex h-10 items-center gap-2 text-sm">
                        <input type="checkbox" {...form.register('isPublished')} />
                        {t('common.published')}
                      </label>
                    </Field>
                  </div>
                </FormSection>
              )}
              <FormSection title={t('common.photos')} hint={t('common.photosHint')}>
                <FileUpload label={t('common.cover')} folder={meta.folder} onUploaded={(f) => form.setValue('coverKey', f.url || f.key)} />
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
              </FormSection>
              <DialogFooter>
                <Button type="button" variant="outline" onClick={() => setOpen(false)}>
                  {t('common.cancel')}
                </Button>
                <Button type="submit" disabled={save.isPending}>
                  {t('common.save')}
                </Button>
              </DialogFooter>
            </form>
          </FormProvider>
        </DialogContent>
      </Dialog>

      <Dialog open={pkgOpen} onOpenChange={setPkgOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{t('pricing.addPackage')}</DialogTitle>
            <DialogDescription>{t('pricing.packageHint')}</DialogDescription>
          </DialogHeader>
          <FormProvider {...pkgForm}>
            <form className="space-y-4" onSubmit={pkgForm.handleSubmit((v) => savePackage.mutate(v))}>
              <LocalizedFields name="name" label={t('pricing.packageName')} />
              <LocalizedFields name="description" textarea label={t('common.notes')} />
              <Field label={t('pricing.chargeHow')}>
                <NativeSelect {...pkgForm.register('pricingUnit')}>
                  <option value="EVENT">{t('pricing.perEvent')}</option>
                  <option value="GUEST">{t('pricing.perGuest')}</option>
                </NativeSelect>
              </Field>
              <div className="grid gap-3 sm:grid-cols-2">
                <Field label={pkgForm.watch('pricingUnit') === 'GUEST' ? t('pricing.perGuestRate') : t('pricing.eventRate')}>
                  <Input type="number" min="0" step="any" {...pkgForm.register('priceAmount')} />
                </Field>
                <Field label={t('pricing.hours')}>
                  <Input type="number" min="1" {...pkgForm.register('durationHours')} />
                </Field>
                <Field label={t('pricing.minGuests')}>
                  <Input type="number" min="1" {...pkgForm.register('guestCountMin')} />
                </Field>
                <Field label={t('pricing.maxGuests')}>
                  <Input type="number" min="1" {...pkgForm.register('guestCountMax')} />
                </Field>
              </div>
              <DialogFooter>
                <Button type="button" variant="outline" onClick={() => setPkgOpen(false)}>
                  {t('common.cancel')}
                </Button>
                <Button type="submit" disabled={savePackage.isPending}>
                  {t('common.save')}
                </Button>
              </DialogFooter>
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
