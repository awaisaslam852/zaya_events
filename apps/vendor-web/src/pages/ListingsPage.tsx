import { useState } from 'react';
import { FormProvider, useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { loc, money } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { LocalizedFields } from '@/components/LocalizedFields';
import { FileUpload, GalleryUpload } from '@/components/FileUpload';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { toast } from 'sonner';

const locSchema = z.object({ en: z.string().min(1), ar: z.string().min(1) });
const schema = z.object({
  categoryId: z.string().uuid(),
  title: locSchema,
  description: locSchema,
  city: z.string().optional(),
  startingPrice: z.coerce.number(),
  coverKey: z.string().optional(),
  galleryKeys: z.array(z.string()).optional().default([]),
  customFieldValues: z.record(z.string()).optional(),
});
type Form = z.infer<typeof schema>;
const pkgSchema = z.object({
  name: locSchema,
  description: locSchema,
  priceAmount: z.coerce.number(),
  durationHours: z.coerce.number().optional(),
});
type Pkg = z.infer<typeof pkgSchema>;

type Category = { id: string; name: unknown; customFields?: Array<{ key: string; type: string; label: unknown; required: boolean }> };
type Listing = {
  id: string;
  title: unknown;
  city: string | null;
  startingPrice: string;
  isPublished: boolean;
  categoryId: string;
  packages: Array<{ id: string; name: unknown; priceAmount: string }>;
};

export function ListingsPage() {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [open, setOpen] = useState(false);
  const [pkgFor, setPkgFor] = useState<string | null>(null);
  const form = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: { title: { en: '', ar: '' }, description: { en: '', ar: '' }, city: '', startingPrice: 0, categoryId: '', galleryKeys: [] },
  });
  const pkg = useForm<Pkg>({
    resolver: zodResolver(pkgSchema),
    defaultValues: { name: { en: '', ar: '' }, description: { en: '', ar: '' }, priceAmount: 0 },
  });
  const cats = useQuery({
    queryKey: ['service-cats'],
    queryFn: () => unwrap<Paginated<Category>>(api.get('/api/v1/service-categories', { params: { pageSize: 50 } })),
  });
  const list = useQuery({
    queryKey: ['my-listings', page],
    queryFn: () => unwrap<Paginated<Listing>>(api.get('/api/v1/listings', { params: { page, pageSize: 20 } })),
  });
  const categoryId = form.watch('categoryId');
  const fields = (cats.data?.items ?? []).find((c) => c.id === categoryId)?.customFields ?? [];
  const create = useMutation({
    mutationFn: (values: Form) =>
      unwrap(
        api.post('/api/v1/listings', {
          ...values,
          coverKey: values.coverKey || values.galleryKeys?.[0],
          galleryKeys: values.galleryKeys ?? [],
          packages: [],
        }),
      ),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['my-listings'] });
      setOpen(false);
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const addPkg = useMutation({
    mutationFn: (p: { id: string; body: Pkg }) => unwrap(api.post(`/api/v1/listings/${p.id}/packages`, p.body)),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['my-listings'] });
      setPkgFor(null);
    },
    onError: (e: Error) => toast.error(e.message),
  });

  return (
    <div>
      <ListToolbar
        title={t('nav.listings')}
        search={q}
        onSearch={setQ}
        page={page}
        pageCount={list.data?.pageCount ?? 1}
        onPage={setPage}
        extra={
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
              <Button>{t('common.create')}</Button>
            </DialogTrigger>
            <DialogContent className="max-h-[90vh] overflow-y-auto max-w-2xl">
              <DialogHeader>
                <DialogTitle>{t('common.create')}</DialogTitle>
              </DialogHeader>
              <FormProvider {...form}>
                <form className="space-y-3" onSubmit={form.handleSubmit((v) => create.mutate(v))}>
                  <select className="h-10 w-full rounded-md border px-2 text-sm" {...form.register('categoryId')}>
                    <option value="">category</option>
                    {(cats.data?.items ?? []).map((c) => (
                      <option key={c.id} value={c.id}>
                        {loc(c.name, i18n.language)}
                      </option>
                    ))}
                  </select>
                  <LocalizedFields name="title" />
                  <LocalizedFields name="description" textarea />
                  <Input placeholder={t('common.city')} {...form.register('city')} />
                  <Input type="number" {...form.register('startingPrice')} />
                  {fields.map((f) => (
                    <div key={f.key}>
                      <Label>{loc(f.label, i18n.language)}</Label>
                      <Input {...form.register(`customFieldValues.${f.key}`)} />
                    </div>
                  ))}
                  <FileUpload
                    label="Cover"
                    folder="listings"
                    onUploaded={(f) => form.setValue('coverKey', f.url || f.key)}
                  />
                  <GalleryUpload
                    label={t('common.photos')}
                    folder="listings"
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
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Title</TableHead>
            <TableHead>{t('common.price')}</TableHead>
            <TableHead>{t('common.actions')}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {(list.data?.items ?? [])
            .filter((row) => !q || loc(row.title, i18n.language).toLowerCase().includes(q.toLowerCase()))
            .map((row) => (
              <TableRow key={row.id}>
                <TableCell>
                  {loc(row.title, i18n.language)} ({row.packages.length} pkg)
                </TableCell>
                <TableCell>{money(row.startingPrice)}</TableCell>
                <TableCell>
                  <Button size="sm" variant="outline" onClick={() => setPkgFor(row.id)}>
                    Package
                  </Button>
                </TableCell>
              </TableRow>
            ))}
        </TableBody>
      </Table>
      <Dialog open={Boolean(pkgFor)} onOpenChange={(v) => !v && setPkgFor(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Package</DialogTitle>
          </DialogHeader>
          <FormProvider {...pkg}>
            <form
              className="space-y-3"
              onSubmit={pkg.handleSubmit((v) => pkgFor && addPkg.mutate({ id: pkgFor, body: v }))}
            >
              <LocalizedFields name="name" />
              <LocalizedFields name="description" textarea />
              <Input type="number" {...pkg.register('priceAmount')} />
              <Input type="number" {...pkg.register('durationHours')} />
              <Button type="submit">{t('common.save')}</Button>
            </form>
          </FormProvider>
        </DialogContent>
      </Dialog>
    </div>
  );
}
