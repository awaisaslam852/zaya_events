import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { money } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { StatusBadge } from '@/components/StatusBadge';
import { TableShell } from '@/components/AdminChrome';

type Invoice = {
  id: string;
  invoiceNumber: string;
  status: string;
  subtotalAmount: string;
  vatRate: string;
  vatAmount: string;
  totalAmount: string;
  currency: string;
  issuedAt: string;
  bookingId: string;
  booking?: { bookingNumber: string; type: string };
  payment?: { kind: string; status: string } | null;
};

export function InvoicesPage() {
  const { t } = useTranslation();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const list = useQuery({
    queryKey: ['invoices', page, q],
    queryFn: () => unwrap<Paginated<Invoice>>(api.get('/api/v1/invoices', { params: { page, pageSize: 20, q } })),
  });

  return (
    <div>
      <ListToolbar
        title={t('nav.invoices')}
        subtitle="Tax invoices with 5% VAT inclusive reverse-calc, ready for ERP export."
        search={q}
        onSearch={(v) => {
          setQ(v);
          setPage(1);
        }}
        page={page}
        pageCount={list.data?.pageCount ?? 1}
        onPage={setPage}
      />
      <TableShell>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>#</TableHead>
              <TableHead>{t('nav.bookings')}</TableHead>
              <TableHead>VAT</TableHead>
              <TableHead>{t('common.price')}</TableHead>
              <TableHead>{t('common.status')}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {(list.data?.items ?? []).map((row) => (
              <TableRow key={row.id}>
                <TableCell className="font-semibold">{row.invoiceNumber}</TableCell>
                <TableCell>
                  <Link className="text-[#0071c2] hover:underline" to={`/bookings/${row.bookingId}`}>
                    {row.booking?.bookingNumber ?? row.bookingId}
                  </Link>
                  <span className="block text-xs text-muted-foreground">{row.payment?.kind}</span>
                </TableCell>
                <TableCell>
                  {money(row.vatAmount, row.currency)}
                  <span className="block text-xs text-muted-foreground">{Number(row.vatRate)}%</span>
                </TableCell>
                <TableCell>{money(row.totalAmount, row.currency)}</TableCell>
                <TableCell>
                  <StatusBadge status={row.status} />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableShell>
    </div>
  );
}
