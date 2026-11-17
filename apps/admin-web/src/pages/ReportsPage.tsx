import { useQuery } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Bar, BarChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { api, unwrap, type Paginated } from '@/lib/api';
import { getDeskCountry, isSuperAdmin } from '@/lib/auth';
import { downloadCsv } from '@/lib/csv';
import { countryName } from '@/lib/countries';
import { money } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { StatTile } from '@/components/AdminChrome';

type FinanceRow = {
  country?: string;
  currency: string;
  gmv: number;
  collected: number;
  platformCommission: number;
  hqEarnings: number;
  deskEarnings: number;
  pendingVendorPayouts: number;
};

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
  finance?: {
    mixedCurrencies: boolean;
    totals: FinanceRow | null;
    byCountry: FinanceRow[];
    byCurrency: FinanceRow[];
  };
};

export function ReportsPage() {
  const { t } = useTranslation();
  const superAdmin = isSuperAdmin();
  const overview = useQuery({
    queryKey: ['reports-overview-full', getDeskCountry()],
    queryFn: () => unwrap<Overview>(api.get('/api/v1/reports/overview')),
  });
  const bookings = useQuery({
    queryKey: ['reports-bookings'],
    queryFn: () => unwrap<Paginated<{ bookingNumber: string; status: string; type: string; totalAmount: string; currency?: string }>>(api.get('/api/v1/bookings', { params: { pageSize: 100 } })),
  });
  const data = overview.data;
  const finance = data?.finance;
  const totals = finance?.totals;
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
      },
      ...(finance?.byCountry ?? []).map((row) => ({
        country: row.country,
        currency: row.currency,
        gmv: row.gmv,
        collected: row.collected,
        vendorCommission: row.platformCommission,
        hqEarnings: row.hqEarnings,
        deskEarnings: row.deskEarnings,
      })),
      ...chart,
      ...(bookings.data?.items ?? []).map((b) => ({
        bookingNumber: b.bookingNumber,
        status: b.status,
        type: b.type,
        totalAmount: b.totalAmount,
        currency: b.currency,
      })),
    ]);
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-extrabold text-[#003580] sm:text-3xl">{t('nav.reports')}</h1>
          <p className="text-sm text-muted-foreground">
            {superAdmin ? t('finance.reportsSuper') : t('finance.reportsCountry')}
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button variant="outline" className="flex-1 sm:flex-none" onClick={() => void exportErp()}>
            {t('common.exportErp')}
          </Button>
          <Button className="flex-1 sm:flex-none" onClick={exportCsv}>{t('common.exportCsv')}</Button>
        </div>
      </div>
      {totals ? (
        <div className="grid grid-cols-2 gap-3 sm:gap-4 lg:grid-cols-6">
          <StatTile label={t('finance.gmv')} value={money(totals.gmv, totals.currency)} />
          <StatTile label={t('finance.collected')} value={money(totals.collected, totals.currency)} />
          <StatTile label={t('finance.vendorCommission')} value={money(totals.platformCommission, totals.currency)} />
          <StatTile label={superAdmin ? t('finance.hqEarnings') : t('finance.hqShare')} value={money(totals.hqEarnings, totals.currency)} />
          <StatTile label={superAdmin ? t('finance.deskEarnings') : t('finance.yourEarnings')} value={money(totals.deskEarnings, totals.currency)} />
          <StatTile label={t('finance.pendingPayouts')} value={money(totals.pendingVendorPayouts, totals.currency)} />
        </div>
      ) : (
        <div className="grid grid-cols-2 gap-3 sm:gap-4 md:grid-cols-4">
          <StatTile label={t('nav.venues')} value={String(data?.venues ?? 0)} />
          <StatTile label={t('nav.accommodations')} value={String(data?.accommodations ?? 0)} />
          <StatTile label={t('finance.desks')} value={String(finance?.byCountry.length ?? 0)} />
          <StatTile label={t('finance.currencies')} value={(finance?.byCurrency ?? []).map((row) => row.currency).join(' · ') || '—'} />
        </div>
      )}
      {(finance?.byCountry.length ?? 0) > 0 ? (
        <div className="overflow-x-auto rounded-2xl border bg-white p-5 shadow-sm">
          <h2 className="mb-4 text-base font-extrabold text-[#003580]">{t('finance.pnlByCountry')}</h2>
          <table className="w-full min-w-[720px] text-sm">
            <thead>
              <tr className="text-xs uppercase tracking-wide text-muted-foreground">
                <th className="pb-2 text-start">{t('finance.desk')}</th>
                <th className="pb-2 text-end">{t('finance.gmv')}</th>
                <th className="pb-2 text-end">{t('finance.collected')}</th>
                <th className="pb-2 text-end">{t('finance.vendorFee')}</th>
                <th className="pb-2 text-end">{t('finance.hq')}</th>
                <th className="pb-2 text-end">{t('finance.deskNet')}</th>
                <th className="pb-2 text-end">{t('finance.payoutsDue')}</th>
              </tr>
            </thead>
            <tbody>
              {(finance?.byCountry ?? []).map((row) => (
                <tr key={`${row.country}-${row.currency}`} className="border-t">
                  <td className="py-2 font-semibold">
                    {countryName(row.country ?? '')} · {row.currency}
                  </td>
                  <td className="py-2 text-end">{money(row.gmv, row.currency)}</td>
                  <td className="py-2 text-end">{money(row.collected, row.currency)}</td>
                  <td className="py-2 text-end">{money(row.platformCommission, row.currency)}</td>
                  <td className="py-2 text-end font-bold">{money(row.hqEarnings, row.currency)}</td>
                  <td className="py-2 text-end">{money(row.deskEarnings, row.currency)}</td>
                  <td className="py-2 text-end">{money(row.pendingVendorPayouts, row.currency)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : null}
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
