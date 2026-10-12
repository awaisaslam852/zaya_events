import { useState } from 'react';
import { Link } from 'react-router-dom';
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
import { StatusBadge } from '@/components/StatusBadge';
import { EmptyHint, TableShell } from '@/components/AdminChrome';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { toast } from 'sonner';

const reasonSchema = z.object({ reason: z.string().max(500).optional() });

type Booking = {
  id: string;
  bookingNumber: string;
  type: string;
  status: string;
  totalAmount: string;
  depositAmount: string;
  balanceAmount: string;
  commissionAmount?: string;
  startAt: string;
  customer?: { id: string; firstName: string; lastName: string; email: string };
  vendor?: { id: string; businessName: unknown };
};

const STATUSES = ['INQUIRY', 'PENDING', 'UNDER_REVIEW', 'CONFIRMED', 'PAID', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'REJECTED'];
const TYPES = ['VENUE', 'LISTING', 'CAR', 'ACCOMMODATION', 'HONEYMOON', 'FLIGHT', 'HOTEL'];

export function BookingsPage() {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [status, setStatus] = useState('');
  const [type, setType] = useState('');
  const form = useForm<z.infer<typeof reasonSchema>>({ resolver: zodResolver(reasonSchema), defaultValues: { reason: '' } });
  const list = useQuery({
    queryKey: ['bookings', page, q, status, type],
    queryFn: () =>
      unwrap<Paginated<Booking>>(
        api.get('/api/v1/bookings', { params: { page, pageSize: 20, q, status: status || undefined, type: type || undefined } }),
      ),
  });
  const act = useMutation({
    mutationFn: (p: { id: string; action: string; reason?: string }) =>
      unwrap(api.post(`/api/v1/bookings/${p.id}/${p.action}`, { reason: p.reason })),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['bookings'] });
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const items = list.data?.items ?? [];

  return (
    <div className="space-y-4">
      <ListToolbar
        title={t('nav.bookings')}
        subtitle="Confirm, reject, and inspect every reservation — including customer and vendor."
        search={q}
        onSearch={(v) => {
          setQ(v);
          setPage(1);
        }}
        page={page}
        pageCount={list.data?.pageCount ?? 1}
        onPage={setPage}
        extra={
          <>
            <select className="h-10 rounded-md border px-2 text-sm" value={status} onChange={(e) => { setStatus(e.target.value); setPage(1); }}>
              <option value="">{t('common.status')}</option>
              {STATUSES.map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
            <select className="h-10 rounded-md border px-2 text-sm" value={type} onChange={(e) => { setType(e.target.value); setPage(1); }}>
              <option value="">Type</option>
              {TYPES.map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
          </>
        }
      />
      <Input placeholder="Reason for confirm / reject (optional)" {...form.register('reason')} />
      {items.length === 0 ? (
        <EmptyHint>{t('common.empty')}</EmptyHint>
      ) : (
        <TableShell>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Booking</TableHead>
                <TableHead>Customer</TableHead>
                <TableHead>Vendor</TableHead>
                <TableHead>{t('common.status')}</TableHead>
                <TableHead>{t('common.price')}</TableHead>
                <TableHead>{t('common.actions')}</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {items.map((row) => (
                <TableRow key={row.id}>
                  <TableCell>
                    <Link className="font-extrabold text-[#003580] hover:underline" to={`/bookings/${row.id}`}>
                      {row.bookingNumber}
                    </Link>
                    <p className="text-xs text-muted-foreground">
                      {row.type} · {new Date(row.startAt).toLocaleString()}
                    </p>
                  </TableCell>
                  <TableCell>
                    {row.customer ? (
                      <Link className="text-sm hover:underline" to={`/customers/${row.customer.id}`}>
                        {row.customer.firstName} {row.customer.lastName}
                      </Link>
                    ) : (
                      '—'
                    )}
                  </TableCell>
                  <TableCell>
                    {row.vendor ? (
                      <Link className="text-sm hover:underline" to={`/vendors/${row.vendor.id}`}>
                        {loc(row.vendor.businessName, i18n.language)}
                      </Link>
                    ) : (
                      '—'
                    )}
                  </TableCell>
                  <TableCell>
                    <StatusBadge status={row.status} />
                  </TableCell>
                  <TableCell className="text-sm">
                    <p className="font-bold">{money(row.totalAmount)}</p>
                    <p className="text-xs text-muted-foreground">
                      dep {money(row.depositAmount)} · fee {money(row.commissionAmount)}
                    </p>
                  </TableCell>
                  <TableCell className="space-x-1">
                    <Button size="sm" variant="outline" asChild>
                      <Link to={`/bookings/${row.id}`}>{t('common.detail')}</Link>
                    </Button>
                    <Button size="sm" onClick={() => act.mutate({ id: row.id, action: 'confirm', reason: form.getValues('reason') })}>
                      {t('bookings.confirm')}
                    </Button>
                    <Button size="sm" variant="destructive" onClick={() => act.mutate({ id: row.id, action: 'reject', reason: form.getValues('reason') })}>
                      {t('common.reject')}
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableShell>
      )}
    </div>
  );
}
