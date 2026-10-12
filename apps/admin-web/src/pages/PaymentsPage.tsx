import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { money } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { StatusBadge } from '@/components/StatusBadge';
import { TableShell } from '@/components/AdminChrome';
import { toast } from 'sonner';

const refundSchema = z.object({ amount: z.coerce.number().positive().optional() });
type RefundForm = z.infer<typeof refundSchema>;

type Payment = {
  id: string;
  kind: string;
  status: string;
  amount: string;
  currency: string;
  bookingId: string;
  booking?: { bookingNumber: string; depositAmount: string; balanceAmount: string };
};

export function PaymentsPage() {
  const { t } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const form = useForm<RefundForm>({ resolver: zodResolver(refundSchema) });
  const list = useQuery({
    queryKey: ['payments', page, q],
    queryFn: () => unwrap<Paginated<Payment>>(api.get('/api/v1/payments', { params: { page, pageSize: 20, q } })),
  });
  const refund = useMutation({
    mutationFn: (p: { id: string; amount?: number }) => unwrap(api.post(`/api/v1/payments/${p.id}/refund`, { amount: p.amount })),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['payments'] }),
    onError: (e: Error) => toast.error(e.message),
  });

  return (
    <div>
      <ListToolbar
        title={t('nav.payments')}
        subtitle="Deposits, balances, and refunds tied to bookings."
        search={q}
        onSearch={(v) => {
          setQ(v);
          setPage(1);
        }}
        page={page}
        pageCount={list.data?.pageCount ?? 1}
        onPage={setPage}
      />
      <form className="mb-3 flex max-w-sm gap-2">
        <Input type="number" step="0.01" placeholder="refund amount" {...form.register('amount')} />
      </form>
      <TableShell>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>#</TableHead>
            <TableHead>kind</TableHead>
            <TableHead>{t('common.status')}</TableHead>
            <TableHead>{t('common.price')}</TableHead>
            <TableHead>{t('common.actions')}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {(list.data?.items ?? []).map((row) => (
            <TableRow key={row.id}>
              <TableCell className="font-semibold">{row.booking?.bookingNumber ?? row.bookingId}</TableCell>
              <TableCell>{row.kind}</TableCell>
              <TableCell>
                <StatusBadge status={row.status} />
              </TableCell>
              <TableCell>{money(row.amount, row.currency)}</TableCell>
              <TableCell>
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => refund.mutate({ id: row.id, amount: form.getValues('amount') })}
                >
                  Refund
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
