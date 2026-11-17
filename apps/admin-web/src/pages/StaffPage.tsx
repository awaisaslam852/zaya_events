import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Mail, Phone, Shield } from 'lucide-react';
import { api, unwrap, type Paginated } from '@/lib/api';
import { setDeskCountry } from '@/lib/auth';
import { COUNTRIES, countryName } from '@/lib/countries';
import { ListToolbar } from '@/components/ListToolbar';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { StatusBadge } from '@/components/StatusBadge';
import { EmptyHint, PersonAvatar } from '@/components/AdminChrome';
import { toast } from 'sonner';

type Staff = {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  phone: string | null;
  status: string;
  isSuperAdmin: boolean;
  allowedCountries: string[];
  lastLoginAt: string | null;
  createdAt: string;
};

const createSchema = z.object({
  firstName: z.string().min(1),
  lastName: z.string().min(1),
  email: z.string().email(),
  password: z.string().optional(),
  phone: z.string().optional(),
  allowedCountries: z.array(z.string().length(2)).min(1, 'Select at least one country'),
});
type CreateForm = z.infer<typeof createSchema>;

const editSchema = z.object({
  firstName: z.string().min(1),
  lastName: z.string().min(1),
  phone: z.string().optional(),
  password: z.string().optional(),
  status: z.enum(['ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING_VERIFICATION']),
  allowedCountries: z.array(z.string().length(2)).min(1, 'Select at least one country'),
});
type EditForm = z.infer<typeof editSchema>;

type CreateResult = Staff & { temporaryPassword?: string; emailSent?: boolean };

export function StaffPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Staff | null>(null);
  const form = useForm<CreateForm>({
    resolver: zodResolver(createSchema),
    defaultValues: {
      firstName: '',
      lastName: '',
      email: '',
      password: '',
      phone: '',
      allowedCountries: ['AE'],
    },
  });
  const editForm = useForm<EditForm>({
    resolver: zodResolver(editSchema),
  });
  const list = useQuery({
    queryKey: ['admins', page, q],
    queryFn: () => unwrap<Paginated<Staff>>(api.get('/api/v1/admins', { params: { page, pageSize: 20, q } })),
  });
  const create = useMutation({
    mutationFn: (values: CreateForm) =>
      unwrap<CreateResult>(
        api.post('/api/v1/admins', {
          ...values,
          phone: values.phone?.trim() || undefined,
          password: values.password?.trim() || undefined,
        }),
      ),
    onSuccess: (data) => {
      void qc.invalidateQueries({ queryKey: ['admins'] });
      setOpen(false);
      form.reset();
      if (data.temporaryPassword) {
        toast.success(`${t('staff.passwordOnce')}: ${data.temporaryPassword}`);
      } else {
        toast.success(data.emailSent ? t('staff.inviteSent') : t('common.create'));
      }
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const update = useMutation({
    mutationFn: (values: EditForm & { id: string }) =>
      unwrap(
        api.patch(`/api/v1/admins/${values.id}`, {
          firstName: values.firstName,
          lastName: values.lastName,
          phone: values.phone?.trim() || null,
          status: values.status,
          allowedCountries: values.allowedCountries,
          ...(values.password ? { password: values.password } : {}),
        }),
      ),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['admins'] });
      setEditing(null);
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const remove = useMutation({
    mutationFn: (id: string) => unwrap(api.delete(`/api/v1/admins/${id}`)),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['admins'] });
      toast.success(t('common.delete'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const items = list.data?.items ?? [];

  function openEdit(row: Staff) {
    setEditing(row);
    editForm.reset({
      firstName: row.firstName,
      lastName: row.lastName,
      phone: row.phone ?? '',
      password: '',
      status: row.status as EditForm['status'],
      allowedCountries: row.allowedCountries,
    });
  }

  function openDesk(row: Staff) {
    const country = row.allowedCountries[0];
    if (!country) {
      return;
    }
    setDeskCountry(country);
    navigate('/');
    window.location.reload();
  }

  return (
    <div>
      <ListToolbar
        title={t('nav.staff')}
        subtitle={t('staff.memberCount', { count: list.data?.total ?? items.length })}
        search={q}
        onSearch={(v) => {
          setQ(v);
          setPage(1);
        }}
        page={page}
        pageCount={list.data?.pageCount ?? 1}
        onPage={setPage}
        extra={
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
              <Button className="w-full sm:w-auto">{t('staff.create')}</Button>
            </DialogTrigger>
            <DialogContent className="max-h-[90vh] overflow-y-auto sm:max-w-lg">
              <DialogHeader>
                <DialogTitle>{t('staff.create')}</DialogTitle>
              </DialogHeader>
              <form className="space-y-3" onSubmit={form.handleSubmit((v) => create.mutate(v))}>
                <div className="grid gap-3 sm:grid-cols-2">
                  <Field label={t('common.firstName')}>
                    <Input {...form.register('firstName')} />
                  </Field>
                  <Field label={t('common.lastName')}>
                    <Input {...form.register('lastName')} />
                  </Field>
                  <Field label={t('auth.email')}>
                    <Input type="email" {...form.register('email')} />
                  </Field>
                  <Field label={t('staff.passwordOptionalCreate')}>
                    <Input type="password" {...form.register('password')} />
                  </Field>
                  <Field label={t('common.phone')}>
                    <Input {...form.register('phone')} />
                  </Field>
                </div>
                <CountryChecks
                  value={form.watch('allowedCountries')}
                  onChange={(next) => form.setValue('allowedCountries', next, { shouldValidate: true })}
                  error={form.formState.errors.allowedCountries?.message}
                />
                <Button type="submit" className="w-full sm:w-auto" disabled={create.isPending}>
                  {t('common.save')}
                </Button>
              </form>
            </DialogContent>
          </Dialog>
        }
      />
      {items.length === 0 ? (
        <EmptyHint>{t('common.empty')}</EmptyHint>
      ) : (
        <div className="grid gap-3">
          {items.map((row) => (
            <article key={row.id} className="overflow-hidden rounded-2xl border bg-white shadow-sm shadow-blue-900/5">
              <div className="flex items-start gap-3 p-4">
                <PersonAvatar first={row.firstName} last={row.lastName} />
                <div className="min-w-0 flex-1">
                  <div className="flex flex-wrap items-center gap-2">
                    <h2 className="truncate text-base font-extrabold text-[#003580]">
                      {row.firstName} {row.lastName}
                    </h2>
                    <StatusBadge status={row.isSuperAdmin ? 'SUPER' : row.status} />
                  </div>
                  <p className="mt-1 flex items-center gap-1.5 truncate text-sm text-muted-foreground">
                    <Mail className="h-3.5 w-3.5 shrink-0" />
                    {row.email}
                  </p>
                  {row.phone ? (
                    <p className="mt-0.5 flex items-center gap-1.5 truncate text-sm text-muted-foreground">
                      <Phone className="h-3.5 w-3.5 shrink-0" />
                      {row.phone}
                    </p>
                  ) : null}
                  <p className="mt-2 flex items-center gap-1.5 text-xs font-semibold text-[#003580]">
                    <Shield className="h-3.5 w-3.5 shrink-0" />
                    {row.isSuperAdmin ? t('staff.hqAccess') : t('staff.deskAccess')}
                  </p>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-2 border-t bg-[#f5f7fa] px-4 py-3 text-xs">
                <div>
                  <p className="uppercase tracking-wide text-muted-foreground">{t('staff.countries')}</p>
                  <p className="mt-1 font-semibold text-[#003580]">
                    {row.isSuperAdmin
                      ? t('staff.allCountries')
                      : row.allowedCountries.map((code) => countryName(code)).join(', ') || t('staff.noCountries')}
                  </p>
                </div>
                <div>
                  <p className="uppercase tracking-wide text-muted-foreground">{t('staff.lastLogin')}</p>
                  <p className="mt-1 font-semibold text-[#003580]">
                    {row.lastLoginAt ? new Date(row.lastLoginAt).toLocaleString() : t('common.neverLoggedIn')}
                  </p>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-2 p-3 sm:flex sm:flex-wrap">
                <Button size="sm" className="w-full sm:w-auto" onClick={() => navigate(`/staff/${row.id}`)}>
                  {t('staff.openProfile')}
                </Button>
                {!row.isSuperAdmin && row.allowedCountries[0] ? (
                  <Button size="sm" variant="outline" className="w-full sm:w-auto" onClick={() => openDesk(row)}>
                    {t('staff.openDesk')}
                  </Button>
                ) : null}
                {!row.isSuperAdmin ? (
                  <>
                    <Button size="sm" variant="outline" className="w-full sm:w-auto" onClick={() => openEdit(row)}>
                      {t('common.edit')}
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      className="w-full sm:w-auto"
                      onClick={() => {
                        if (window.confirm(t('common.confirmDelete'))) {
                          remove.mutate(row.id);
                        }
                      }}
                    >
                      {t('common.delete')}
                    </Button>
                  </>
                ) : null}
              </div>
            </article>
          ))}
        </div>
      )}
      <Dialog open={Boolean(editing)} onOpenChange={(next) => !next && setEditing(null)}>
        <DialogContent className="max-h-[90vh] overflow-y-auto sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>{t('common.edit')}</DialogTitle>
          </DialogHeader>
          {editing && (
            <form
              className="space-y-3"
              onSubmit={editForm.handleSubmit((v) => update.mutate({ ...v, id: editing.id }))}
            >
              <div className="grid gap-3 sm:grid-cols-2">
                <Field label={t('common.firstName')}>
                  <Input {...editForm.register('firstName')} />
                </Field>
                <Field label={t('common.lastName')}>
                  <Input {...editForm.register('lastName')} />
                </Field>
                <Field label={t('common.phone')}>
                  <Input {...editForm.register('phone')} />
                </Field>
                <Field label={t('auth.password')}>
                  <Input type="password" placeholder={t('staff.passwordOptional')} {...editForm.register('password')} />
                </Field>
                <Field label={t('common.status')}>
                  <select className="h-10 w-full rounded-md border px-2 text-sm" {...editForm.register('status')}>
                    {['ACTIVE', 'INACTIVE', 'SUSPENDED'].map((s) => (
                      <option key={s} value={s}>
                        {s}
                      </option>
                    ))}
                  </select>
                </Field>
              </div>
              <CountryChecks
                value={editForm.watch('allowedCountries')}
                onChange={(next) => editForm.setValue('allowedCountries', next, { shouldValidate: true })}
                error={editForm.formState.errors.allowedCountries?.message}
              />
              <Button type="submit" className="w-full sm:w-auto" disabled={update.isPending}>
                {t('common.save')}
              </Button>
            </form>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="space-y-1">
      <Label>{label}</Label>
      {children}
    </div>
  );
}

function CountryChecks({
  value,
  onChange,
  error,
}: {
  value: string[];
  onChange: (next: string[]) => void;
  error?: string;
}) {
  const { t } = useTranslation();
  return (
    <div className="space-y-2">
      <Label>{t('staff.countries')}</Label>
      <div className="grid max-h-56 grid-cols-1 gap-1 overflow-y-auto rounded-md border p-3 sm:grid-cols-2">
        {COUNTRIES.map((row) => {
          const checked = value.includes(row.code);
          return (
            <label key={row.code} className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={checked}
                onChange={() =>
                  onChange(checked ? value.filter((code) => code !== row.code) : [...value, row.code])
                }
              />
              {countryName(row.code)}
            </label>
          );
        })}
      </div>
      {error ? <p className="text-xs text-red-600">{error}</p> : null}
    </div>
  );
}
