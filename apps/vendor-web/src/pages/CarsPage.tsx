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
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { toast } from 'sonner';

const locSchema = z.object({ en: z.string().min(1), ar: z.string().min(1) });
const schema = z.object({
  name: locSchema,
  description: locSchema,
  make: z.string().min(1),
  model: z.string().min(1),
  year: z.coerce.number(),
  seats: z.coerce.number(),
  transmission: z.enum(['AUTOMATIC', 'MANUAL']),
  dailyRate: z.coerce.number(),
  coverKey: z.string().optional(),
  galleryKeys: z.array(z.string()).optional().default([]),
});
type Form = z.infer<typeof schema>;

export function CarsPage() {
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
      make: '',
      model: '',
      year: 2024,
      seats: 4,
      transmission: 'AUTOMATIC',
      dailyRate: 800,
      galleryKeys: [],
    },
  });
  const list = useQuery({
    queryKey: ['vendor-cars', page, q],
    queryFn: () =>
      unwrap<Paginated<{ id: string; name: unknown; make: string; dailyRate: string }>>(
        api.get('/api/v1/cars', { params: { page, pageSize: 20, q } }),
      ),
  });
  const create = useMutation({
    mutationFn: (values: Form) =>
      unwrap(
        api.post('/api/v1/cars', {
          ...values,
          coverKey: values.coverKey || values.galleryKeys?.[0],
          galleryKeys: values.galleryKeys ?? [],
        }),
      ),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['vendor-cars'] });
      setOpen(false);
      form.reset();
    },
    onError: (e: Error) => toast.error(e.message),
  });

  return (
    <div>
      <ListToolbar
        title={t('nav.cars')}
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
            <DialogContent className="max-h-[90vh] overflow-y-auto">
              <DialogHeader>
                <DialogTitle>{t('common.create')}</DialogTitle>
              </DialogHeader>
              <FormProvider {...form}>
                <form className="space-y-3" onSubmit={form.handleSubmit((v) => create.mutate(v))}>
                  <LocalizedFields name="name" />
                  <LocalizedFields name="description" textarea />
                  <Input placeholder="Make" {...form.register('make')} />
                  <Input placeholder="Model" {...form.register('model')} />
                  <Input type="number" placeholder="Year" {...form.register('year')} />
                  <Input type="number" placeholder="Seats" {...form.register('seats')} />
                  <select className="h-10 w-full rounded-md border px-2" {...form.register('transmission')}>
                    <option value="AUTOMATIC">AUTOMATIC</option>
                    <option value="MANUAL">MANUAL</option>
                  </select>
                  <Input type="number" placeholder="Daily rate" {...form.register('dailyRate')} />
                  <FileUpload label="Cover" folder="cars" onUploaded={(f) => form.setValue('coverKey', f.url || f.key)} />
                  <GalleryUpload
                    label={t('common.photos')}
                    folder="cars"
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
            <TableHead>Name</TableHead>
            <TableHead>{t('common.price')}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {(list.data?.items ?? []).map((row) => (
            <TableRow key={row.id}>
              <TableCell>{loc(row.name, i18n.language)}</TableCell>
              <TableCell>{money(row.dailyRate)}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
