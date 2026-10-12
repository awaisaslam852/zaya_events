import { useState } from 'react';
import { Link } from 'react-router-dom';
import { FormProvider, useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { loc, money, coverOf } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { EmptyHint, PhotoCard, TableShell } from '@/components/AdminChrome';
import { LocalizedFields } from '@/components/LocalizedFields';
import { FileUpload, GalleryUpload } from '@/components/FileUpload';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { toast } from 'sonner';

const locSchema = z.object({ en: z.string().min(1), ar: z.string().min(1) });
const schema = z.object({
  name: locSchema,
  description: locSchema,
  destination: locSchema,
  nights: z.coerce.number(),
  priceAmount: z.coerce.number(),
  coverKey: z.string().optional(),
  galleryKeys: z.array(z.string()).optional().default([]),
});
type Form = z.infer<typeof schema>;

export function HoneymoonPage() {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [open, setOpen] = useState(false);
  const form = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: { name: { en: '', ar: '' }, description: { en: '', ar: '' }, destination: { en: '', ar: '' }, nights: 7, priceAmount: 12000, galleryKeys: [] },
  });
  const list = useQuery({
    queryKey: ['honeymoon', page, q],
    queryFn: () => unwrap<Paginated<{ id: string; name: unknown; priceAmount: string; nights: number; destination?: unknown; coverKey?: string | null; galleryKeys?: unknown }>>(api.get('/api/v1/honeymoon', { params: { page, pageSize: 20, q } })),
  });
  const inquiries = useQuery({
    queryKey: ['honeymoon-inquiries'],
    queryFn: () => unwrap<Paginated<{ id: string; bookingNumber: string; status: string }>>(api.get('/api/v1/bookings', { params: { type: 'HONEYMOON', pageSize: 20 } })),
  });
  const create = useMutation({
    mutationFn: (values: Form) =>
      unwrap(api.post('/api/v1/honeymoon', { ...values, inclusions: [], galleryKeys: values.galleryKeys ?? [] })),
    onSuccess: () => { void qc.invalidateQueries({ queryKey: ['honeymoon'] }); setOpen(false); },
    onError: (e: Error) => toast.error(e.message),
  });

  return (
    <div className="space-y-8">
      <ListToolbar title={t('nav.honeymoon')} subtitle="Packages and destination inquiries from guests." search={q} onSearch={setQ} page={page} pageCount={list.data?.pageCount ?? 1} onPage={setPage} extra={
        <Dialog open={open} onOpenChange={setOpen}>
          <DialogTrigger asChild><Button>{t('common.create')}</Button></DialogTrigger>
          <DialogContent>
            <DialogHeader><DialogTitle>{t('common.create')}</DialogTitle></DialogHeader>
            <FormProvider {...form}>
              <form className="space-y-3" onSubmit={form.handleSubmit((v) => create.mutate(v))}>
                <LocalizedFields name="name" />
                <LocalizedFields name="description" textarea />
                <LocalizedFields name="destination" />
                <Input type="number" {...form.register('nights')} />
                <Input type="number" {...form.register('priceAmount')} />
                <FileUpload label="Cover" folder="honeymoon" onUploaded={(f) => form.setValue('coverKey', f.url || f.key)} />
                <GalleryUpload
                  label={t('common.photos')}
                  folder="honeymoon"
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
              to={`/honeymoon/${row.id}`}
              photo={coverOf(row)}
              title={loc(row.name, i18n.language)}
              meta={`${row.nights} nights · ${loc(row.destination, i18n.language)}`}
              price={money(row.priceAmount)}
            />
          ))}
        </div>
      )}
      <h2 className="text-lg font-extrabold text-[#003580]">Inquiries</h2>
      <TableShell>
      <Table>
        <TableHeader><TableRow><TableHead>#</TableHead><TableHead>{t('common.status')}</TableHead></TableRow></TableHeader>
        <TableBody>
          {(inquiries.data?.items ?? []).map((row) => (
            <TableRow key={row.id}>
              <TableCell className="font-semibold">
                <Link className="text-[#0071c2] hover:underline" to={`/bookings/${row.id}`}>{row.bookingNumber}</Link>
              </TableCell>
              <TableCell>{row.status}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
      </TableShell>
    </div>
  );
}
