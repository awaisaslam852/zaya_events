import { useState } from 'react';
import { FormProvider, useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { APP_CURRENCIES } from '@/lib/countries';
import { loc, coverOf, money } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { LocalizedFields } from '@/components/LocalizedFields';
import { FileUpload, GalleryUpload } from '@/components/FileUpload';
import { EmptyHint, Field, FormSection, NativeSelect, PhotoCard } from '@/components/AdminChrome';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { toast } from 'sonner';

const locSchema = z.object({ en: z.string().min(1), ar: z.string().min(1) });
const schema = z.object({
  name: locSchema,
  description: locSchema,
  address: locSchema,
  city: z.string().min(1),
  latitude: z.coerce.number(),
  longitude: z.coerce.number(),
  capacityMin: z.coerce.number(),
  capacityMax: z.coerce.number(),
  startingPrice: z.coerce.number().nonnegative(),
  currency: z.string().length(3),
  pricingModel: z.enum(['HIRE', 'PER_GUEST', 'HYBRID']),
  coverKey: z.string().optional(),
  galleryKeys: z.array(z.string()).optional().default([]),
});
type Form = z.infer<typeof schema>;

export function VenuesPage() {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [open, setOpen] = useState(false);
  const form = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: {
      name: { en: '', ar: '' },
      description: { en: '', ar: '' },
      address: { en: '', ar: '' },
      city: '',
      latitude: 25.2,
      longitude: 55.2,
      capacityMin: 50,
      capacityMax: 300,
      startingPrice: 0,
      currency: 'AED',
      pricingModel: 'HYBRID',
      galleryKeys: [],
    },
  });
  const list = useQuery({
    queryKey: ['venues', page, q],
    queryFn: () =>
      unwrap<
        Paginated<{
          id: string;
          name: unknown;
          city: string;
          capacityMax: number;
          startingPrice?: string;
          currency?: string;
          pricingModel?: string;
          coverKey?: string | null;
          galleryKeys?: unknown;
        }>
      >(api.get('/api/v1/venues', { params: { page, pageSize: 20, city: q || undefined } })),
  });
  const create = useMutation({
    mutationFn: (values: Form) =>
      unwrap(api.post('/api/v1/venues', { ...values, amenities: [], galleryKeys: values.galleryKeys ?? [] })),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['venues'] });
      setOpen(false);
      form.reset();
    },
    onError: (e: Error) => toast.error(e.message),
  });

  return (
    <div>
      <ListToolbar
        title={t('nav.venues')}
        subtitle={t('pages.venues')}
        search={q}
        onSearch={(v) => {
          setQ(v);
          setPage(1);
        }}
        page={page}
        pageCount={list.data?.pageCount ?? 1}
        onPage={setPage}
        extra={
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
              <Button>{t('common.create')}</Button>
            </DialogTrigger>
            <DialogContent className="max-w-3xl">
              <DialogHeader>
                <DialogTitle>{t('common.create')}</DialogTitle>
                <DialogDescription>{t('pricing.editHint')}</DialogDescription>
              </DialogHeader>
              <FormProvider {...form}>
                <form className="space-y-4" onSubmit={form.handleSubmit((v) => create.mutate(v))}>
                  <FormSection title={t('pricing.details')}>
                    <LocalizedFields name="name" />
                    <LocalizedFields name="description" textarea />
                    <LocalizedFields name="address" />
                    <div className="grid gap-3 sm:grid-cols-2">
                      <Field label={t('common.city')}>
                        <Input {...form.register('city')} />
                      </Field>
                      <Field label="Lat">
                        <Input type="number" step="any" {...form.register('latitude')} />
                      </Field>
                      <Field label="Lng">
                        <Input type="number" step="any" {...form.register('longitude')} />
                      </Field>
                    </div>
                  </FormSection>
                  <FormSection title={t('pricing.title')} hint={t('pricing.sectionHint')}>
                    <Field label={t('pricing.model')}>
                      <NativeSelect {...form.register('pricingModel')}>
                        <option value="HIRE">{t('pricing.modelHIRE')}</option>
                        <option value="PER_GUEST">{t('pricing.modelPER_GUEST')}</option>
                        <option value="HYBRID">{t('pricing.modelHYBRID')}</option>
                      </NativeSelect>
                    </Field>
                    <div className="grid gap-3 sm:grid-cols-3">
                      <Field label={t('pricing.startingFrom')}>
                        <Input type="number" min="0" step="any" {...form.register('startingPrice')} />
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
                      <Field label={t('pricing.minGuests')}>
                        <Input type="number" {...form.register('capacityMin')} />
                      </Field>
                      <Field label={t('pricing.maxGuests')}>
                        <Input type="number" {...form.register('capacityMax')} />
                      </Field>
                    </div>
                  </FormSection>
                  <FormSection title={t('common.photos')}>
                    <FileUpload label={t('common.cover')} folder="venues" onUploaded={(f) => form.setValue('coverKey', f.url || f.key)} />
                    <GalleryUpload
                      label={t('common.photos')}
                      folder="venues"
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
                    <Button type="submit" disabled={create.isPending}>
                      {t('common.save')}
                    </Button>
                  </DialogFooter>
                </form>
              </FormProvider>
            </DialogContent>
          </Dialog>
        }
      />
      {(list.data?.items ?? []).length === 0 ? (
        <EmptyHint>{t('common.empty')}</EmptyHint>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          {(list.data?.items ?? []).map((row) => (
            <PhotoCard
              key={row.id}
              to={`/venues/${row.id}`}
              photo={coverOf(row)}
              title={loc(row.name, i18n.language)}
              meta={`${row.city} · up to ${row.capacityMax} guests`}
              price={
                Number(row.startingPrice ?? 0) > 0
                  ? `${money(row.startingPrice, row.currency)}${row.pricingModel === 'PER_GUEST' ? ` ${t('pricing.perGuest')}` : ''}`
                  : undefined
              }
            />
          ))}
        </div>
      )}
    </div>
  );
}
