import { useState, type ReactNode } from 'react';
import { FormProvider, useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { Link } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { COUNTRIES } from '@/lib/countries';
import { coverOf, loc } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { LocalizedFields } from '@/components/LocalizedFields';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { StatusBadge } from '@/components/StatusBadge';
import { EmptyHint } from '@/components/AdminChrome';
import { toast } from 'sonner';

type Vendor = {
  id: string;
  status: string;
  city: string | null;
  phone: string | null;
  ratingAvg: string;
  coverKey: string | null;
  galleryKeys?: unknown;
  businessName: unknown;
  user: { email: string; firstName: string; lastName: string };
  _count?: { listings: number; bookings: number; cars: number; venues: number };
};

const locSchema = z.object({ en: z.string().min(1), ar: z.string().min(1) });
const createSchema = z.object({
  firstName: z.string().min(1),
  lastName: z.string().min(1),
  email: z.string().email(),
  password: z.string().min(8),
  phone: z.string().min(8),
  country: z.string().min(2),
  city: z.string().min(1),
  legalName: z.string().min(1),
  taxId: z.string().optional(),
  website: z.string().optional(),
  businessName: locSchema,
});
type CreateForm = z.infer<typeof createSchema>;

export function VendorsPage() {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [status, setStatus] = useState('');
  const [open, setOpen] = useState(false);
  const form = useForm<CreateForm>({
    resolver: zodResolver(createSchema),
    defaultValues: {
      firstName: '',
      lastName: '',
      email: '',
      password: '',
      phone: '',
      country: 'AE',
      city: '',
      legalName: '',
      taxId: '',
      website: '',
      businessName: { en: '', ar: '' },
    },
  });
  const list = useQuery({
    queryKey: ['vendors', page, q, status],
    queryFn: () =>
      unwrap<Paginated<Vendor>>(api.get('/api/v1/vendors', { params: { page, pageSize: 20, q, status: status || undefined } })),
  });
  const act = useMutation({
    mutationFn: (p: { id: string; action: 'approve' | 'reject' }) => unwrap(api.post(`/api/v1/vendors/${p.id}/${p.action}`, {})),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['vendors'] }),
    onError: (e: Error) => toast.error(e.message),
  });
  const create = useMutation({
    mutationFn: (values: CreateForm) =>
      unwrap(
        api.post('/api/v1/vendors', {
          ...values,
          taxId: values.taxId?.trim() || undefined,
          website: values.website?.trim() || undefined,
        }),
      ),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['vendors'] });
      setOpen(false);
      form.reset();
      toast.success(t('common.create'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const items = list.data?.items ?? [];

  return (
    <div>
      <ListToolbar
        title={t('nav.vendors')}
        subtitle="Approve partners and inspect listings, cars, venues, and bookings."
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
            <select
              className="h-10 rounded-md border px-2 text-sm"
              value={status}
              onChange={(e) => {
                setStatus(e.target.value);
                setPage(1);
              }}
            >
              <option value="">{t('common.status')}</option>
              {['PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED'].map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>
            <Dialog open={open} onOpenChange={setOpen}>
              <DialogTrigger asChild>
                <Button>{t('common.create')}</Button>
              </DialogTrigger>
              <DialogContent className="max-h-[90vh] max-w-2xl overflow-y-auto">
                <DialogHeader>
                  <DialogTitle>{t('common.createVendor')}</DialogTitle>
                </DialogHeader>
                <FormProvider {...form}>
                  <form className="space-y-3" onSubmit={form.handleSubmit((v) => create.mutate(v))}>
                    <div className="grid gap-3 md:grid-cols-2">
                      <Field label={t('common.firstName')}>
                        <Input {...form.register('firstName')} />
                      </Field>
                      <Field label={t('common.lastName')}>
                        <Input {...form.register('lastName')} />
                      </Field>
                      <Field label={t('auth.email')}>
                        <Input type="email" {...form.register('email')} />
                      </Field>
                      <Field label={t('auth.password')}>
                        <Input type="password" {...form.register('password')} />
                      </Field>
                      <Field label={t('common.phone')}>
                        <Input {...form.register('phone')} />
                      </Field>
                      <Field label={t('common.country')}>
                        <select className="h-10 w-full rounded-md border px-2 text-sm" {...form.register('country')}>
                          {COUNTRIES.map((row) => (
                            <option key={row.code} value={row.code}>
                              {row.name}
                            </option>
                          ))}
                        </select>
                      </Field>
                      <Field label={t('common.city')}>
                        <Input {...form.register('city')} />
                      </Field>
                      <Field label={t('common.legalName')}>
                        <Input {...form.register('legalName')} />
                      </Field>
                      <Field label={t('common.taxId')}>
                        <Input {...form.register('taxId')} />
                      </Field>
                      <Field label={t('common.website')}>
                        <Input {...form.register('website')} />
                      </Field>
                    </div>
                    <LocalizedFields name="businessName" />
                    <Button type="submit" disabled={create.isPending}>
                      {t('common.save')}
                    </Button>
                  </form>
                </FormProvider>
              </DialogContent>
            </Dialog>
          </>
        }
      />
      {items.length === 0 ? (
        <EmptyHint>{t('common.empty')}</EmptyHint>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {items.map((row) => {
            const photo = coverOf(row);
            return (
              <article key={row.id} className="overflow-hidden rounded-2xl border bg-white shadow-sm shadow-blue-900/5">
                <div className="relative h-36 bg-[#003580]">
                  {photo ? <img src={photo} alt="" className="h-full w-full object-cover" /> : null}
                  <div className="absolute end-3 top-3">
                    <StatusBadge status={row.status} />
                  </div>
                </div>
                <div className="space-y-3 p-4">
                  <div>
                    <Link to={`/vendors/${row.id}`} className="text-lg font-extrabold text-[#003580] hover:underline">
                      {loc(row.businessName, i18n.language)}
                    </Link>
                    <p className="text-sm text-muted-foreground">
                      {row.user.firstName} {row.user.lastName} · {row.user.email}
                    </p>
                    <p className="text-xs text-muted-foreground">
                      {row.city || '—'} · {row.phone || 'No phone'} · ★ {row.ratingAvg}
                    </p>
                  </div>
                  <div className="grid grid-cols-4 gap-1 text-center text-[11px]">
                    <Count n={row._count?.listings} l="Listings" />
                    <Count n={row._count?.venues} l="Venues" />
                    <Count n={row._count?.cars} l="Cars" />
                    <Count n={row._count?.bookings} l="Bookings" />
                  </div>
                  <div className="flex gap-2">
                    <Button size="sm" className="flex-1" asChild>
                      <Link to={`/vendors/${row.id}`}>{t('common.detail')}</Link>
                    </Button>
                    <Button size="sm" onClick={() => act.mutate({ id: row.id, action: 'approve' })}>
                      {t('common.approve')}
                    </Button>
                    <Button size="sm" variant="destructive" onClick={() => act.mutate({ id: row.id, action: 'reject' })}>
                      {t('common.reject')}
                    </Button>
                  </div>
                </div>
              </article>
            );
          })}
        </div>
      )}
    </div>
  );
}

function Field({ label, children }: { label: string; children: ReactNode }) {
  return (
    <div className="space-y-1">
      <Label>{label}</Label>
      {children}
    </div>
  );
}

function Count({ n, l }: { n?: number; l: string }) {
  return (
    <div className="rounded-lg bg-[#f5f7fa] py-2">
      <p className="font-extrabold text-[#003580]">{n ?? 0}</p>
      <p className="text-muted-foreground">{l}</p>
    </div>
  );
}
