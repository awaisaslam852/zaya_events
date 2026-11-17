import { useState } from 'react';
import { FormProvider, useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { api, unwrap, type Paginated } from '@/lib/api';
import { isSuperAdmin } from '@/lib/auth';
import { countryName } from '@/lib/countries';
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
type Policy = { country: string; hqShareRate: number; defaultVendorRate: number };
type Ledger = {
  id: string;
  amount: string;
  rate: string;
  hqRate?: string;
  hqAmount?: string;
  deskAmount?: string;
  currency?: string;
  status: string;
  booking?: { bookingNumber: string };
  vendor?: { id?: string; businessName: unknown };
};

export function CommissionsPage() {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const superAdmin = isSuperAdmin();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [open, setOpen] = useState(false);
  const [hqDraft, setHqDraft] = useState<Record<string, string>>({});
  const [vendorDraft, setVendorDraft] = useState<Record<string, string>>({});
  const form = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: { name: { en: '', ar: '' }, rate: 10, isDefault: false, isActive: true },
  });
  const policies = useQuery({
    queryKey: ['commission-policies'],
    queryFn: () => unwrap<{ items: Policy[] }>(api.get('/api/v1/commissions/policies')),
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
  const savePolicy = useMutation({
    mutationFn: ({ country, body }: { country: string; body: { hqShareRate?: number; defaultVendorRate?: number } }) =>
      unwrap(api.put(`/api/v1/commissions/policies/${country}`, body)),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['commission-policies'] });
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
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
        subtitle={superAdmin ? t('finance.superSubtitle') : t('finance.countrySubtitle')}
        search={q}
        onSearch={setQ}
        page={page}
        pageCount={ledger.data?.pageCount ?? 1}
        onPage={setPage}
        extra={
          superAdmin ? (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
              <Button variant="outline">{t('finance.bookingTemplate')}</Button>
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
                    <option value="">{t('common.isDefault')}</option>
                    {['VENUE', 'LISTING', 'CAR', 'ACCOMMODATION', 'HONEYMOON', 'FLIGHT', 'HOTEL'].map((s) => (
                      <option key={s} value={s}>{s}</option>
                    ))}
                  </select>
                  <label className="flex gap-2 text-sm">
                    <input type="checkbox" {...form.register('isDefault')} /> {t('common.isDefault')}
                  </label>
                  <label className="flex gap-2 text-sm">
                    <input type="checkbox" {...form.register('isActive')} /> {t('common.isActive')}
                  </label>
                  <Button type="submit">{t('common.save')}</Button>
                </form>
              </FormProvider>
            </DialogContent>
          </Dialog>
          ) : (
            <Button asChild variant="outline">
              <Link to="/vendors">{t('finance.setVendorRate')}</Link>
            </Button>
          )
        }
      />
      <Section title={superAdmin ? t('finance.hqPolicies') : t('finance.yourDeskRates')}>
        <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
          {(policies.data?.items ?? []).map((policy) => (
            <article key={policy.country} className="rounded-2xl border bg-white p-4 shadow-sm">
              <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">{policy.country}</p>
              <h2 className="mt-1 font-extrabold text-[#003580]">{countryName(policy.country)}</h2>
              <div className="mt-3 space-y-3">
                <label className="block text-sm">
                  <span className="text-muted-foreground">{t('finance.hqShareOfIncome')}</span>
                  <div className="mt-1 flex gap-2">
                    <Input
                      type="number"
                      min={0}
                      max={100}
                      step="0.01"
                      disabled={!superAdmin}
                      value={hqDraft[policy.country] ?? String(policy.hqShareRate)}
                      onChange={(e) => setHqDraft((prev) => ({ ...prev, [policy.country]: e.target.value }))}
                    />
                    {superAdmin ? (
                      <Button
                        size="sm"
                        onClick={() =>
                          savePolicy.mutate({
                            country: policy.country,
                            body: { hqShareRate: Number(hqDraft[policy.country] ?? policy.hqShareRate) },
                          })
                        }
                      >
                        {t('common.save')}
                      </Button>
                    ) : null}
                  </div>
                  {!superAdmin ? <p className="mt-1 text-xs text-muted-foreground">{t('finance.hqLocked')}</p> : null}
                </label>
                <label className="block text-sm">
                  <span className="text-muted-foreground">{t('finance.defaultVendorRate')}</span>
                  <div className="mt-1 flex gap-2">
                    <Input
                      type="number"
                      min={0}
                      max={100}
                      step="0.01"
                      value={vendorDraft[policy.country] ?? String(policy.defaultVendorRate)}
                      onChange={(e) => setVendorDraft((prev) => ({ ...prev, [policy.country]: e.target.value }))}
                    />
                    <Button
                      size="sm"
                      variant="cta"
                      onClick={() =>
                        savePolicy.mutate({
                          country: policy.country,
                          body: { defaultVendorRate: Number(vendorDraft[policy.country] ?? policy.defaultVendorRate) },
                        })
                      }
                    >
                      {t('common.save')}
                    </Button>
                  </div>
                </label>
              </div>
            </article>
          ))}
        </div>
      </Section>
      {superAdmin && rateItems.length > 0 ? (
      <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-4">
        {rateItems
          .filter((r) => !q || loc(r.name, i18n.language).toLowerCase().includes(q.toLowerCase()))
          .map((row) => (
            <article key={row.id} className="rounded-2xl border bg-white p-4 shadow-sm">
              <StatusBadge status={row.isActive ? 'ACTIVE' : 'INACTIVE'} />
              <h2 className="mt-2 font-extrabold text-[#003580]">{loc(row.name, i18n.language)}</h2>
              <p className="text-2xl font-extrabold">{row.rate}%</p>
              <p className="text-xs text-muted-foreground">{row.bookingType ?? t('common.isDefault')}{row.isDefault ? ` · ${t('common.isDefault')}` : ''}</p>
            </article>
          ))}
      </div>
      ) : null}
      <Section title={t('finance.ledger')}>
      <TableShell>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>#</TableHead>
            <TableHead>{t('nav.vendors')}</TableHead>
            <TableHead>{t('finance.vendorRate')}</TableHead>
            <TableHead>{t('finance.takenFromVendor')}</TableHead>
            <TableHead>{t('finance.hq')}</TableHead>
            <TableHead>{t('finance.deskNet')}</TableHead>
            <TableHead>{t('common.status')}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {(ledger.data?.items ?? []).map((row) => (
            <TableRow key={row.id}>
              <TableCell className="font-semibold">{row.booking?.bookingNumber}</TableCell>
              <TableCell>
                {row.vendor?.id ? (
                  <Link to={`/vendors/${row.vendor.id}`} className="text-[#0071c2] hover:underline">
                    {loc(row.vendor.businessName, i18n.language)}
                  </Link>
                ) : (
                  loc(row.vendor?.businessName, i18n.language)
                )}
              </TableCell>
              <TableCell>{row.rate}%</TableCell>
              <TableCell>{money(row.amount, row.currency)}</TableCell>
              <TableCell>
                {money(row.hqAmount ?? 0, row.currency)}
                {row.hqRate ? ` (${row.hqRate}%)` : ''}
              </TableCell>
              <TableCell className="font-semibold">{money(row.deskAmount ?? 0, row.currency)}</TableCell>
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
