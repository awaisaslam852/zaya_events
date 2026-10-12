import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { loc, money } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { StatusBadge } from '@/components/StatusBadge';
import { TableShell } from '@/components/AdminChrome';
import { toast } from 'sonner';

const schema = z.object({
  vendorId: z.string().uuid(),
  amount: z.coerce.number().positive(),
  currency: z.string().length(3),
});
type Form = z.infer<typeof schema>;

type Payout = {
  id: string;
  amount: string;
  currency: string;
  status: string;
  vendor: { id: string; businessName: unknown };
};

export function PayoutsPage() {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [status, setStatus] = useState('');
  const [open, setOpen] = useState(false);
  const form = useForm<Form>({ resolver: zodResolver(schema), defaultValues: { vendorId: '', amount: 0, currency: 'AED' } });
  const list = useQuery({
    queryKey: ['payouts', page, status],
    queryFn: () =>
      unwrap<Paginated<Payout>>(api.get('/api/v1/payouts', { params: { page, pageSize: 20, status: status || undefined } })),
  });
  const vendors = useQuery({
    queryKey: ['vendors-mini', q],
    queryFn: () =>
      unwrap<Paginated<{ id: string; businessName: unknown }>>(api.get('/api/v1/vendors', { params: { pageSize: 50, q } })),
  });
  const create = useMutation({
    mutationFn: (values: Form) => unwrap(api.post('/api/v1/payouts', values)),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['payouts'] });
      setOpen(false);
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const paid = useMutation({
    mutationFn: (id: string) => unwrap(api.post(`/api/v1/payouts/${id}/paid`)),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['payouts'] }),
    onError: (e: Error) => toast.error(e.message),
  });

  return (
    <div>
      <ListToolbar
        title={t('nav.payouts')}
        subtitle="Create partner payouts and mark them paid."
        search={q}
        onSearch={setQ}
        page={page}
        pageCount={list.data?.pageCount ?? 1}
        onPage={setPage}
        extra={
          <>
            <select className="h-10 rounded-md border px-2 text-sm" value={status} onChange={(e) => { setStatus(e.target.value); setPage(1); }}>
              <option value="">{t('common.status')}</option>
              {['PENDING', 'PROCESSING', 'PAID', 'FAILED', 'CANCELLED'].map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
            <Dialog open={open} onOpenChange={setOpen}>
              <DialogTrigger asChild>
                <Button>{t('common.create')}</Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>{t('common.create')}</DialogTitle>
                </DialogHeader>
                <form className="space-y-3" onSubmit={form.handleSubmit((v) => create.mutate(v))}>
                  <div>
                    <Label>vendorId</Label>
                    <select className="h-10 w-full rounded-md border px-2 text-sm" {...form.register('vendorId')}>
                      <option value="">—</option>
                      {(vendors.data?.items ?? []).map((v) => (
                        <option key={v.id} value={v.id}>
                          {loc(v.businessName, i18n.language)}
                        </option>
                      ))}
                    </select>
                  </div>
                  <Input type="number" step="0.01" {...form.register('amount')} />
                  <Input {...form.register('currency')} />
                  <Button type="submit">{t('common.save')}</Button>
                </form>
              </DialogContent>
            </Dialog>
          </>
        }
      />
      <TableShell>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>{t('nav.vendors')}</TableHead>
            <TableHead>{t('common.price')}</TableHead>
            <TableHead>{t('common.status')}</TableHead>
            <TableHead>{t('common.actions')}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {(list.data?.items ?? []).map((row) => (
            <TableRow key={row.id}>
              <TableCell className="font-semibold">{loc(row.vendor.businessName, i18n.language)}</TableCell>
              <TableCell>{money(row.amount, row.currency)}</TableCell>
              <TableCell><StatusBadge status={row.status} /></TableCell>
              <TableCell>
                <Button size="sm" disabled={row.status === 'PAID'} onClick={() => paid.mutate(row.id)}>
                  PAID
                </Button>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
      </TableShell>
    </div>
  );
}
