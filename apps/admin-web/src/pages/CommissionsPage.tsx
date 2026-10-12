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
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { StatusBadge } from '@/components/StatusBadge';
import { Section, TableShell } from '@/components/AdminChrome';
import { toast } from 'sonner';

const locSchema = z.object({ en: z.string().min(1), ar: z.string().min(1) });
const schema = z.object({
  name: locSchema,
  rate: z.coerce.number().min(0).max(100),
  bookingType: z.enum(['VENUE', 'LISTING', 'CAR', 'ACCOMMODATION', 'HONEYMOON', 'FLIGHT', 'HOTEL']).optional(),
  isDefault: z.boolean(),
  isActive: z.boolean(),
});
type Form = z.infer<typeof schema>;

type Rate = { id: string; name: unknown; rate: string; bookingType: string | null; isDefault: boolean; isActive: boolean };
type Ledger = {
  id: string;
  amount: string;
  rate: string;
  status: string;
  booking?: { bookingNumber: string };
  vendor?: { businessName: unknown };
};

export function CommissionsPage() {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [open, setOpen] = useState(false);
  const form = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: { name: { en: '', ar: '' }, rate: 10, isDefault: false, isActive: true },
  });
  const rates = useQuery({
    queryKey: ['commission-rates'],
    queryFn: () => unwrap<{ items: Rate[] }>(api.get('/api/v1/commissions/rates')),
  });
  const rateItems = rates.data?.items ?? [];
  const ledger = useQuery({
    queryKey: ['commission-ledger', page],
    queryFn: () => unwrap<Paginated<Ledger>>(api.get('/api/v1/commissions', { params: { page, pageSize: 20 } })),
  });
  const create = useMutation({
    mutationFn: (values: Form) => unwrap(api.post('/api/v1/commissions/rates', { ...values, bookingType: values.bookingType || undefined })),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['commission-rates'] });
      setOpen(false);
    },
    onError: (e: Error) => toast.error(e.message),
  });

  return (
    <div className="space-y-8">
      <ListToolbar
        title={t('nav.commissions')}
        subtitle="Default rates, booking-type overrides, and the live ledger."
        search={q}
        onSearch={setQ}
        page={page}
        pageCount={ledger.data?.pageCount ?? 1}
        onPage={setPage}
        extra={
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
              <Button>{t('common.create')}</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>{t('common.create')}</DialogTitle>
              </DialogHeader>
              <FormProvider {...form}>
                <form className="space-y-3" onSubmit={form.handleSubmit((v) => create.mutate(v))}>
                  <LocalizedFields name="name" />
                  <Input type="number" step="0.01" {...form.register('rate')} />
                  <select className="h-10 w-full rounded-md border px-2 text-sm" {...form.register('bookingType')}>
                    <option value="">default</option>
                    {['VENUE', 'LISTING', 'CAR', 'ACCOMMODATION', 'HONEYMOON', 'FLIGHT', 'HOTEL'].map((s) => (
                      <option key={s} value={s}>{s}</option>
                    ))}
                  </select>
                  <label className="flex gap-2 text-sm">
                    <input type="checkbox" {...form.register('isDefault')} /> isDefault
                  </label>
                  <label className="flex gap-2 text-sm">
                    <input type="checkbox" {...form.register('isActive')} /> isActive
                  </label>
                  <Button type="submit">{t('common.save')}</Button>
                </form>
              </FormProvider>
            </DialogContent>
          </Dialog>
        }
      />
      <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-4">
        {rateItems
          .filter((r) => !q || loc(r.name, i18n.language).toLowerCase().includes(q.toLowerCase()))
          .map((row) => (
            <article key={row.id} className="rounded-2xl border bg-white p-4 shadow-sm">
              <StatusBadge status={row.isActive ? 'ACTIVE' : 'INACTIVE'} />
              <h2 className="mt-2 font-extrabold text-[#003580]">{loc(row.name, i18n.language)}</h2>
              <p className="text-2xl font-extrabold">{row.rate}%</p>
              <p className="text-xs text-muted-foreground">{row.bookingType ?? 'default'}{row.isDefault ? ' · default' : ''}</p>
            </article>
          ))}
      </div>
      <Section title="Ledger">
      <TableShell>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>#</TableHead>
            <TableHead>{t('nav.vendors')}</TableHead>
            <TableHead>{t('common.price')}</TableHead>
            <TableHead>{t('common.status')}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {(ledger.data?.items ?? []).map((row) => (
            <TableRow key={row.id}>
              <TableCell className="font-semibold">{row.booking?.bookingNumber}</TableCell>
              <TableCell>{loc(row.vendor?.businessName, i18n.language)}</TableCell>
              <TableCell>
                {money(row.amount)} ({row.rate}%)
              </TableCell>
              <TableCell><StatusBadge status={row.status} /></TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
      </TableShell>
      </Section>
    </div>
  );
}
