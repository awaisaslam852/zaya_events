import { useState } from 'react';
import { FormProvider, useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { loc, money, coverOf } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { EmptyHint, PhotoCard } from '@/components/AdminChrome';
import { LocalizedFields } from '@/components/LocalizedFields';
import { FileUpload, GalleryUpload } from '@/components/FileUpload';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { toast } from 'sonner';

const locSchema = z.object({ en: z.string().min(1), ar: z.string().min(1) });
const schema = z.object({
  name: locSchema,
  description: locSchema,
  address: locSchema,
  type: z.enum(['HOTEL_ROOM', 'VILLA', 'APARTMENT', 'RESORT', 'CHALET', 'BUNGALOW']),
  city: z.string().min(1),
  country: z.string().min(1),
  maxGuests: z.coerce.number(),
  bedrooms: z.coerce.number(),
  bathrooms: z.coerce.number(),
  nightlyRate: z.coerce.number(),
  coverKey: z.string().optional(),
  galleryKeys: z.array(z.string()).optional().default([]),
});
type Form = z.infer<typeof schema>;

export function AccommodationsPage() {
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
      type: 'VILLA',
      city: '',
      country: 'AE',
      maxGuests: 6,
      bedrooms: 3,
      bathrooms: 2,
      nightlyRate: 1500,
      galleryKeys: [],
    },
  });
  const list = useQuery({
    queryKey: ['stays', page, q],
    queryFn: () => unwrap<Paginated<{ id: string; name: unknown; city: string; type: string; nightlyRate: string; coverKey?: string | null; galleryKeys?: unknown }>>(
      api.get('/api/v1/accommodations', { params: { page, pageSize: 20, city: q || undefined } }),
    ),
  });
  const create = useMutation({
    mutationFn: (values: Form) =>
      unwrap(api.post('/api/v1/accommodations', { ...values, amenities: [], galleryKeys: values.galleryKeys ?? [] })),
    onSuccess: () => { void qc.invalidateQueries({ queryKey: ['stays'] }); setOpen(false); },
    onError: (e: Error) => toast.error(e.message),
  });

  return (
    <div>
      <ListToolbar title={t('nav.accommodations')} subtitle="Villas, hotels, and apartments with nightly rates and galleries." search={q} onSearch={(v) => { setQ(v); setPage(1); }} page={page} pageCount={list.data?.pageCount ?? 1} onPage={setPage} extra={
        <Dialog open={open} onOpenChange={setOpen}>
          <DialogTrigger asChild><Button>{t('common.create')}</Button></DialogTrigger>
          <DialogContent className="max-h-[90vh] overflow-y-auto max-w-2xl">
            <DialogHeader><DialogTitle>{t('common.create')}</DialogTitle></DialogHeader>
            <FormProvider {...form}>
              <form className="space-y-3" onSubmit={form.handleSubmit((v) => create.mutate(v))}>
                <LocalizedFields name="name" />
                <LocalizedFields name="description" textarea />
                <LocalizedFields name="address" />
                <Label>Type</Label>
                <select className="h-10 w-full rounded-md border px-2" {...form.register('type')}>
                  {['HOTEL_ROOM', 'VILLA', 'APARTMENT', 'RESORT', 'CHALET', 'BUNGALOW'].map((x) => <option key={x}>{x}</option>)}
                </select>
                <div className="grid grid-cols-2 gap-2">
                  <Input placeholder={t('common.city')} {...form.register('city')} />
                  <Input placeholder="Country" {...form.register('country')} />
                  <Input type="number" placeholder="Guests" {...form.register('maxGuests')} />
                  <Input type="number" placeholder="Rate" {...form.register('nightlyRate')} />
                  <Input type="number" placeholder="Bedrooms" {...form.register('bedrooms')} />
                  <Input type="number" placeholder="Bathrooms" {...form.register('bathrooms')} />
                </div>
                <FileUpload label="Cover" folder="stays" onUploaded={(f) => form.setValue('coverKey', f.url || f.key)} />
                <GalleryUpload
                  label={t('common.photos')}
                  folder="stays"
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
      } />
      {(list.data?.items ?? []).length === 0 ? (
        <EmptyHint>{t('common.empty')}</EmptyHint>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          {(list.data?.items ?? []).map((row) => (
            <PhotoCard
              key={row.id}
              to={`/accommodations/${row.id}`}
              photo={coverOf(row)}
              title={loc(row.name, i18n.language)}
              meta={`${row.type} · ${row.city}`}
              price={money(row.nightlyRate)}
            />
          ))}
        </div>
      )}
    </div>
  );
}
