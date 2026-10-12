import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { money } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { Button } from '@/components/ui/button';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { toast } from 'sonner';

type Booking = {
  id: string;
  bookingNumber: string;
  type: string;
  status: string;
  startAt: string;
  totalAmount: string;
};

export function BookingsPage() {
  const { t } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [status, setStatus] = useState('');
  const [cal, setCal] = useState(false);
  const list = useQuery({
    queryKey: ['vendor-bookings', page, status],
    queryFn: () =>
      unwrap<Paginated<Booking>>(api.get('/api/v1/bookings', { params: { page, pageSize: 20, status: status || undefined } })),
  });
  const act = useMutation({
    mutationFn: (p: { id: string; action: string }) => unwrap(api.post(`/api/v1/bookings/${p.id}/${p.action}`, {})),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['vendor-bookings'] }),
    onError: (e: Error) => toast.error(e.message),
  });
  const items = (list.data?.items ?? []).filter((r) => !q || r.bookingNumber.toLowerCase().includes(q.toLowerCase()));

  return (
    <div className="space-y-4">
      <ListToolbar
        title={t('nav.bookings')}
        search={q}
        onSearch={setQ}
        page={page}
        pageCount={list.data?.pageCount ?? 1}
        onPage={setPage}
        extra={
          <>
            <select className="h-10 rounded-md border px-2 text-sm" value={status} onChange={(e) => { setStatus(e.target.value); setPage(1); }}>
              <option value="">{t('common.status')}</option>
              {['PENDING', 'UNDER_REVIEW', 'CONFIRMED', 'PAID', 'COMPLETED'].map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
            <Button size="sm" variant="outline" onClick={() => setCal((v) => !v)}>
              {t('bookings.calendar')}
            </Button>
          </>
        }
      />
      {cal ? (
        <div className="grid gap-2 md:grid-cols-2">
          {items.map((row) => (
            <div key={row.id} className="rounded border p-3 text-sm">
              {new Date(row.startAt).toLocaleString()} · {row.bookingNumber} · {row.status}
            </div>
          ))}
        </div>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>#</TableHead>
              <TableHead>{t('common.status')}</TableHead>
              <TableHead>{t('common.actions')}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {items.map((row) => (
              <TableRow key={row.id}>
                <TableCell>
                  {row.bookingNumber} {row.type} {money(row.totalAmount)}
                </TableCell>
                <TableCell>{row.status}</TableCell>
                <TableCell className="space-x-1">
                  <Button size="sm" onClick={() => act.mutate({ id: row.id, action: 'under-review' })}>
                    {t('bookings.underReview')}
                  </Button>
                  <Button size="sm" onClick={() => act.mutate({ id: row.id, action: 'confirm' })}>
                    {t('bookings.confirm')}
                  </Button>
                  <Button size="sm" variant="destructive" onClick={() => act.mutate({ id: row.id, action: 'reject' })}>
                    {t('common.reject')}
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
