import { useQuery } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap } from '@/lib/api';
import { money } from '@/lib/utils';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';

type Earnings = {
  totals: { total: number; deposits: number; balances: number };
  bookings: Array<{ id: string; bookingNumber: string; status: string; totalAmount: string; depositAmount: string; balanceAmount: string }>;
  payouts: Array<{ id: string; amount: string; currency: string; status: string; createdAt: string }>;
};

export function EarningsPage() {
  const { t } = useTranslation();
  const data = useQuery({
    queryKey: ['vendor-earnings'],
    queryFn: () => unwrap<Earnings>(api.get('/api/v1/vendors/me/earnings')),
  });
  const e = data.data;

  return (
    <div className="space-y-4">
      <h1 className="text-3xl font-extrabold tracking-tight text-[#003580]">{t('nav.earnings')}</h1>
      <p className="text-sm text-muted-foreground">{t('earnings.hint')}</p>
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle>{t('earnings.totals')}</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-semibold">{money(e?.totals.total)}</CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>{t('earnings.deposits')}</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-semibold">{money(e?.totals.deposits)}</CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>{t('earnings.balances')}</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-semibold">{money(e?.totals.balances)}</CardContent>
        </Card>
      </div>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>#</TableHead>
            <TableHead>{t('earnings.deposits')}</TableHead>
            <TableHead>{t('earnings.balances')}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {(e?.bookings ?? []).map((b) => (
            <TableRow key={b.id}>
              <TableCell>
                {b.bookingNumber} {b.status} {money(b.totalAmount)}
              </TableCell>
              <TableCell>{money(b.depositAmount)}</TableCell>
              <TableCell>{money(b.balanceAmount)}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
      <h2 className="font-semibold">{t('earnings.history')}</h2>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>{t('common.price')}</TableHead>
            <TableHead>{t('common.status')}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {(e?.payouts ?? []).map((p) => (
            <TableRow key={p.id}>
              <TableCell>{money(p.amount, p.currency)}</TableCell>
              <TableCell>{p.status}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
