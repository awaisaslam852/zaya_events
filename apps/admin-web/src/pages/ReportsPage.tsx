import { useQuery } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Bar, BarChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { api, unwrap, type Paginated } from '@/lib/api';
import { downloadCsv } from '@/lib/csv';
import { money } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { StatTile } from '@/components/AdminChrome';

type Overview = {
  customers: number;
  vendors: number;
  events: number;
  venues: number;
  accommodations: number;
  flights: number;
  hotels: number;
  activity: number;
  payments: { _sum: { amount: unknown }; _count: number };
  commissions: { _sum: { amount: unknown }; _count: number };
  bookings: Array<{ status: string; _count: number; _sum: { totalAmount: unknown } }>;
};

export function ReportsPage() {
  const { t } = useTranslation();
  const overview = useQuery({
    queryKey: ['reports-overview-full'],
    queryFn: () => unwrap<Overview>(api.get('/api/v1/reports/overview')),
  });
  const bookings = useQuery({
    queryKey: ['reports-bookings'],
    queryFn: () => unwrap<Paginated<{ bookingNumber: string; status: string; type: string; totalAmount: string }>>(api.get('/api/v1/bookings', { params: { pageSize: 100 } })),
  });
  const data = overview.data;
  const chart = (data?.bookings ?? []).map((row) => ({
    status: row.status,
    count: row._count,
    revenue: Number(row._sum.totalAmount ?? 0),
  }));

  async function exportErp(): Promise<void> {
    const res = await api.get('/api/v1/finance/erp', { params: { format: 'csv' }, responseType: 'blob' });
    const blob = new Blob([res.data as BlobPart], { type: 'text/csv;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'zaya-erp-invoices.csv';
    a.click();
    URL.revokeObjectURL(url);
  }

  function exportCsv(): void {
    downloadCsv('zaya-report.csv', [
      {
        customers: data?.customers,
        vendors: data?.vendors,
        events: data?.events,
        venues: data?.venues,
        accommodations: data?.accommodations,
        flights: data?.flights,
        hotels: data?.hotels,
        activity: data?.activity,
        payments: data?.payments?._sum.amount,
        commissions: data?.commissions?._sum.amount,
      },
      ...chart,
      ...(bookings.data?.items ?? []).map((b) => ({ bookingNumber: b.bookingNumber, status: b.status, type: b.type, totalAmount: b.totalAmount })),
    ]);
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-extrabold text-[#003580]">{t('nav.reports')}</h1>
          <p className="text-sm text-muted-foreground">Revenue, bookings mix, and CSV export for finance.</p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => void exportErp()}>
            {t('common.exportErp')}
          </Button>
          <Button onClick={exportCsv}>{t('common.exportCsv')}</Button>
        </div>
      </div>
      <div className="grid gap-4 md:grid-cols-4">
        <StatTile label={t('dashboard.revenue')} value={money(data?.payments?._sum.amount)} />
        <StatTile label={t('nav.commissions')} value={money(data?.commissions?._sum.amount)} />
        <StatTile label={t('nav.venues')} value={String(data?.venues ?? 0)} />
        <StatTile label={t('nav.accommodations')} value={String(data?.accommodations ?? 0)} />
      </div>
      <div className="rounded-2xl border bg-white p-5 shadow-sm">
        <h2 className="mb-4 text-base font-extrabold text-[#003580]">{t('dashboard.bookings')}</h2>
        <div className="h-80">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={chart}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="status" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="count" fill="#003580" />
              <Bar dataKey="revenue" fill="#FEBB02" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}
