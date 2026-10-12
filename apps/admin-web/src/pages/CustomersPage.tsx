import { useState, type ReactNode } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { Link } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { COUNTRIES } from '@/lib/countries';
import { ListToolbar } from '@/components/ListToolbar';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { StatusBadge } from '@/components/StatusBadge';
import { EmptyHint, PersonAvatar } from '@/components/AdminChrome';
import { toast } from 'sonner';

type Customer = {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  status: string;
  phone: string | null;
  locale: string;
  country: string | null;
  createdAt: string;
  lastLoginAt: string | null;
  _count?: { bookings: number; events: number };
};

const createSchema = z.object({
  firstName: z.string().min(1),
  lastName: z.string().min(1),
  email: z.string().email(),
  password: z.string().min(8),
  phone: z.string().optional(),
  country: z.string().min(2),
  locale: z.enum(['en', 'ar']),
});
type CreateForm = z.infer<typeof createSchema>;

export function CustomersPage() {
  const { t } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [status, setStatus] = useState('');
  const [open, setOpen] = useState(false);
  const form = useForm<CreateForm>({
    resolver: zodResolver(createSchema),
    defaultValues: { firstName: '', lastName: '', email: '', password: '', phone: '', country: 'AE', locale: 'en' },
  });
  const list = useQuery({
    queryKey: ['customers', page, q, status],
    queryFn: () =>
      unwrap<Paginated<Customer>>(api.get('/api/v1/customers', { params: { page, pageSize: 20, q, status: status || undefined } })),
  });
  const toggle = useMutation({
    mutationFn: (row: Customer) =>
      unwrap(api.post(`/api/v1/customers/${row.id}/${row.status === 'ACTIVE' ? 'deactivate' : 'activate'}`)),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['customers'] }),
    onError: (e: Error) => toast.error(e.message),
  });
  const create = useMutation({
    mutationFn: (values: CreateForm) =>
      unwrap(api.post('/api/v1/customers', { ...values, phone: values.phone?.trim() || undefined })),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['customers'] });
      setOpen(false);
      form.reset({ firstName: '', lastName: '', email: '', password: '', phone: '', country: 'AE', locale: 'en' });
      toast.success(t('common.create'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const items = list.data?.items ?? [];

  return (
    <div>
      <ListToolbar
        title={t('nav.customers')}
        subtitle="Every guest account, their bookings, and access control."
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
              {['ACTIVE', 'INACTIVE', 'PENDING_VERIFICATION', 'SUSPENDED'].map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>
            <Dialog open={open} onOpenChange={setOpen}>
              <DialogTrigger asChild>
                <Button>{t('common.create')}</Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>{t('common.createCustomer')}</DialogTitle>
                </DialogHeader>
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
                  </div>
                  <Button type="submit" disabled={create.isPending}>
                    {t('common.save')}
                  </Button>
                </form>
              </DialogContent>
            </Dialog>
          </>
        }
      />
      {items.length === 0 ? (
        <EmptyHint>{t('common.empty')}</EmptyHint>
      ) : (
        <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
          {items.map((row) => (
            <article key={row.id} className="rounded-2xl border bg-white p-4 shadow-sm shadow-blue-900/5">
              <div className="flex items-start gap-3">
                <PersonAvatar first={row.firstName} last={row.lastName} />
                <div className="min-w-0 flex-1">
                  <Link to={`/customers/${row.id}`} className="block truncate text-base font-extrabold text-[#003580] hover:underline">
                    {row.firstName} {row.lastName}
                  </Link>
                  <p className="truncate text-sm text-muted-foreground">{row.email}</p>
                  <p className="mt-1 text-xs text-muted-foreground">
                    {row.phone || 'No phone'}
                    {row.country ? ` · ${row.country}` : ''}
                  </p>
                </div>
                <StatusBadge status={row.status} />
              </div>
              <div className="mt-4 grid grid-cols-3 gap-2 text-center text-xs">
                <div className="rounded-lg bg-[#f5f7fa] py-2">
                  <p className="font-extrabold text-[#003580]">{row._count?.bookings ?? 0}</p>
                  <p className="text-muted-foreground">Bookings</p>
                </div>
                <div className="rounded-lg bg-[#f5f7fa] py-2">
                  <p className="font-extrabold text-[#003580]">{row._count?.events ?? 0}</p>
                  <p className="text-muted-foreground">Events</p>
                </div>
                <div className="rounded-lg bg-[#f5f7fa] py-2">
                  <p className="font-extrabold text-[#003580]">{row.locale?.toUpperCase()}</p>
                  <p className="text-muted-foreground">Locale</p>
                </div>
              </div>
              <div className="mt-4 flex gap-2">
                <Button size="sm" className="flex-1" asChild>
                  <Link to={`/customers/${row.id}`}>{t('common.detail')}</Link>
                </Button>
                <Button size="sm" variant="outline" onClick={() => toggle.mutate(row)}>
                  {row.status === 'ACTIVE' ? t('common.deactivate') : t('common.activate')}
                </Button>
              </div>
            </article>
          ))}
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
