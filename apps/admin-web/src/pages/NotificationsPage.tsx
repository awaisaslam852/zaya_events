import { useState } from 'react';
import { FormProvider, useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { loc } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { LocalizedFields } from '@/components/LocalizedFields';
import { Button } from '@/components/ui/button';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { StatusBadge } from '@/components/StatusBadge';
import { TableShell } from '@/components/AdminChrome';
import { toast } from 'sonner';

const locSchema = z.object({ en: z.string().min(1), ar: z.string().min(1) });
const schema = z.object({
  title: locSchema,
  body: locSchema,
  role: z.enum(['CUSTOMER', 'VENDOR', '']).optional(),
});
type Form = z.infer<typeof schema>;

type Row = { id: string; title: unknown; body: unknown; status: string; createdAt: string };

export function NotificationsPage() {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const form = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: { title: { en: '', ar: '' }, body: { en: '', ar: '' }, role: '' },
  });
  const history = useQuery({
    queryKey: ['notif-history', page],
    queryFn: () => unwrap<Paginated<Row>>(api.get('/api/v1/notifications/admin/history', { params: { page, pageSize: 20 } })),
  });
  const send = useMutation({
    mutationFn: (values: Form) =>
      unwrap(api.post('/api/v1/notifications/broadcast', { title: values.title, body: values.body, role: values.role || undefined })),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['notif-history'] });
      toast.success(t('notifications.broadcast'));
    },
    onError: (e: Error) => toast.error(e.message),
  });

  return (
    <div className="space-y-6">
      <ListToolbar title={t('nav.notifications')} subtitle="Broadcast to customers or vendors and review history." search={q} onSearch={setQ} page={page} pageCount={history.data?.pageCount ?? 1} onPage={setPage} />
      <FormProvider {...form}>
        <form className="max-w-2xl space-y-3 rounded-2xl border bg-white p-5 shadow-sm" onSubmit={form.handleSubmit((v) => send.mutate(v))}>
          <h2 className="font-semibold">{t('notifications.broadcast')}</h2>
          <LocalizedFields name="title" />
          <LocalizedFields name="body" textarea />
          <select className="h-10 rounded-md border px-2 text-sm" {...form.register('role')}>
            <option value="">{t('notifications.audience')}</option>
            <option value="CUSTOMER">CUSTOMER</option>
            <option value="VENDOR">VENDOR</option>
          </select>
          <Button type="submit">{t('notifications.broadcast')}</Button>
        </form>
      </FormProvider>
      <h2 className="font-semibold">{t('notifications.history')}</h2>
      <TableShell>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>{t('notifications.title')}</TableHead>
            <TableHead>{t('common.status')}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {(history.data?.items ?? [])
            .filter((row) => !q || loc(row.title, i18n.language).toLowerCase().includes(q.toLowerCase()))
            .map((row) => (
              <TableRow key={row.id}>
                <TableCell>
                  <p className="font-semibold">{loc(row.title, i18n.language)}</p>
                  <p className="text-muted-foreground text-xs">{loc(row.body, i18n.language)}</p>
                </TableCell>
                <TableCell><StatusBadge status={row.status} /></TableCell>
              </TableRow>
            ))}
        </TableBody>
      </Table>
      </TableShell>
    </div>
  );
}
