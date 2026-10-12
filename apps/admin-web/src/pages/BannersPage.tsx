import { useState } from 'react';
import { FormProvider, useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { loc, mediaUrl } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { EmptyHint } from '@/components/AdminChrome';
import { StatusBadge } from '@/components/StatusBadge';
import { LocalizedFields } from '@/components/LocalizedFields';
import { FileUpload } from '@/components/FileUpload';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { toast } from 'sonner';

const locSchema = z.object({ en: z.string().min(1), ar: z.string().min(1) });
const schema = z.object({
  title: locSchema,
  subtitle: locSchema.optional(),
  imageKey: z.string().min(1),
  linkUrl: z.string().url().optional().or(z.literal('')),
  placement: z.enum(['HOME_HERO', 'HOME_SECONDARY', 'DISCOVERY', 'VENDOR_DASHBOARD']),
  sortOrder: z.coerce.number(),
  isActive: z.boolean(),
});
type Form = z.infer<typeof schema>;

type Banner = { id: string; title: unknown; placement: string; isActive: boolean; imageKey: string };

export function BannersPage() {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [placement, setPlacement] = useState('');
  const [open, setOpen] = useState(false);
  const form = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: {
      title: { en: '', ar: '' },
      subtitle: { en: '', ar: '' },
      imageKey: '',
      linkUrl: '',
      placement: 'HOME_HERO',
      sortOrder: 0,
      isActive: true,
    },
  });
  const list = useQuery({
    queryKey: ['banners', page, placement],
    queryFn: () =>
      unwrap<Paginated<Banner>>(
        api.get('/api/v1/banners', { params: { page, pageSize: 20, placement: placement || undefined } }),
      ),
  });
  const create = useMutation({
    mutationFn: (values: Form) =>
      unwrap(api.post('/api/v1/banners', { ...values, linkUrl: values.linkUrl || undefined, subtitle: values.subtitle })),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['banners'] });
      setOpen(false);
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const remove = useMutation({
    mutationFn: (id: string) => unwrap(api.delete(`/api/v1/banners/${id}`)),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['banners'] }),
    onError: (e: Error) => toast.error(e.message),
  });

  return (
    <div>
      <ListToolbar
        title={t('nav.banners')}
        subtitle="Hero and discovery creatives shown in the customer app."
        search={q}
        onSearch={setQ}
        page={page}
        pageCount={list.data?.pageCount ?? 1}
        onPage={setPage}
        extra={
          <>
            <select className="h-10 rounded-md border px-2 text-sm" value={placement} onChange={(e) => { setPlacement(e.target.value); setPage(1); }}>
              <option value="">placement</option>
              {['HOME_HERO', 'HOME_SECONDARY', 'DISCOVERY', 'VENDOR_DASHBOARD'].map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
            <Dialog open={open} onOpenChange={setOpen}>
              <DialogTrigger asChild>
                <Button>{t('common.create')}</Button>
              </DialogTrigger>
              <DialogContent className="max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                  <DialogTitle>{t('common.create')}</DialogTitle>
                </DialogHeader>
                <FormProvider {...form}>
                  <form className="space-y-3" onSubmit={form.handleSubmit((v) => create.mutate(v))}>
                    <LocalizedFields name="title" />
                    <LocalizedFields name="subtitle" />
                    <FileUpload
                      label="image"
                      folder="banners"
                      onUploaded={(f) =>
                        form.setValue('imageKey', f.url || f.key, { shouldDirty: true, shouldValidate: true })
                      }
                    />
                    {form.watch('imageKey') ? (
                      <img src={mediaUrl(form.watch('imageKey'))} alt="" className="h-28 w-full rounded-md object-cover" />
                    ) : (
                      <p className="text-xs text-muted-foreground">Choose an image from your computer before saving.</p>
                    )}
                    <Input placeholder="https://" {...form.register('linkUrl')} />
                    <select className="h-10 w-full rounded-md border px-2 text-sm" {...form.register('placement')}>
                      {['HOME_HERO', 'HOME_SECONDARY', 'DISCOVERY', 'VENDOR_DASHBOARD'].map((s) => (
                        <option key={s} value={s}>{s}</option>
                      ))}
                    </select>
                    <Input type="number" {...form.register('sortOrder')} />
                    <label className="flex gap-2 text-sm">
                      <input type="checkbox" {...form.register('isActive')} /> isActive
                    </label>
                    <Button type="submit">{t('common.save')}</Button>
                  </form>
                </FormProvider>
              </DialogContent>
            </Dialog>
          </>
        }
      />
      {(list.data?.items ?? []).filter((row) => !q || loc(row.title, i18n.language).toLowerCase().includes(q.toLowerCase())).length === 0 ? (
        <EmptyHint>{t('common.empty')}</EmptyHint>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
          {(list.data?.items ?? [])
            .filter((row) => !q || loc(row.title, i18n.language).toLowerCase().includes(q.toLowerCase()))
            .map((row) => (
              <article key={row.id} className="overflow-hidden rounded-2xl border bg-white shadow-sm">
                <div className="h-36 bg-[#d6e6f5]">
                  {row.imageKey ? <img src={mediaUrl(row.imageKey)} alt="" className="h-36 w-full object-cover" /> : null}
                </div>
                <div className="space-y-2 p-3">
                  <StatusBadge status={row.isActive ? 'ACTIVE' : 'INACTIVE'} />
                  <h2 className="font-extrabold text-[#003580]">{loc(row.title, i18n.language)}</h2>
                  <p className="text-xs text-muted-foreground">{row.placement}</p>
                  <Button size="sm" variant="destructive" onClick={() => remove.mutate(row.id)}>
                    {t('common.delete')}
                  </Button>
                </div>
              </article>
            ))}
        </div>
      )}
    </div>
  );
}
