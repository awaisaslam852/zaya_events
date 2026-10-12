import { useState } from 'react';
import { FormProvider, useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { loc, coverOf } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { LocalizedFields } from '@/components/LocalizedFields';
import { FileUpload, GalleryUpload } from '@/components/FileUpload';
import { EmptyHint, PhotoCard } from '@/components/AdminChrome';
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
  city: z.string().min(1),
  country: z.string().min(1),
  latitude: z.coerce.number(),
  longitude: z.coerce.number(),
  capacityMin: z.coerce.number(),
  capacityMax: z.coerce.number(),
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
      country: 'AE',
      latitude: 25.2,
      longitude: 55.2,
      capacityMin: 50,
      capacityMax: 300,
      galleryKeys: [],
    },
  });
  const list = useQuery({
    queryKey: ['venues', page, q],
    queryFn: () => unwrap<Paginated<{ id: string; name: unknown; city: string; capacityMax: number; coverKey?: string | null; galleryKeys?: unknown }>>(api.get('/api/v1/venues', { params: { page, pageSize: 20, city: q || undefined } })),
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
        subtitle="Halls, capacity, photos, and packages — open a venue for the full record."
        search={q}
        onSearch={(v) => { setQ(v); setPage(1); }}
        page={page}
        pageCount={list.data?.pageCount ?? 1}
        onPage={setPage}
        extra={
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
              <Button>{t('common.create')}</Button>
            </DialogTrigger>
            <DialogContent className="max-h-[90vh] overflow-y-auto max-w-2xl">
              <DialogHeader><DialogTitle>{t('common.create')}</DialogTitle></DialogHeader>
              <FormProvider {...form}>
                <form className="space-y-3" onSubmit={form.handleSubmit((v) => create.mutate(v))}>
                  <LocalizedFields name="name" />
                  <LocalizedFields name="description" textarea />
                  <LocalizedFields name="address" />
                  <div className="grid grid-cols-2 gap-2">
                    <div><Label>{t('common.city')}</Label><Input {...form.register('city')} /></div>
                    <div><Label>Country</Label><Input {...form.register('country')} /></div>
                    <div><Label>Lat</Label><Input type="number" step="any" {...form.register('latitude')} /></div>
                    <div><Label>Lng</Label><Input type="number" step="any" {...form.register('longitude')} /></div>
                    <div><Label>Min</Label><Input type="number" {...form.register('capacityMin')} /></div>
                    <div><Label>Max</Label><Input type="number" {...form.register('capacityMax')} /></div>
                  </div>
                  <FileUpload label="Cover" folder="venues" onUploaded={(f) => form.setValue('coverKey', f.url || f.key)} />
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
                  <Button type="submit">{t('common.save')}</Button>
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
            />
          ))}
        </div>
      )}
    </div>
  );
}
