import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { loc } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { StatusBadge } from '@/components/StatusBadge';
import { TableShell } from '@/components/AdminChrome';
import { toast } from 'sonner';

const locSchema = z.object({ en: z.string().min(1), ar: z.string().min(1) });
const rescheduleSchema = z.object({ scheduledAt: z.string().min(1), notes: locSchema.optional() });
const assignSchema = z.object({ representativeId: z.string().uuid() });
const notesSchema = z.object({ notes: locSchema });

type Visit = {
  id: string;
  status: string;
  scheduledAt: string;
  venue: { id: string; name: unknown; vendorId: string };
  customer: { email: string; firstName: string; lastName: string };
  representative: { id: string; name: unknown } | null;
};

export function VenueVisitsPage() {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [status, setStatus] = useState('');
  const [active, setActive] = useState<Visit | null>(null);
  const list = useQuery({
    queryKey: ['visits', page, q, status],
    queryFn: () =>
      unwrap<Paginated<Visit>>(
        api.get('/api/v1/venue-visits', { params: { page, pageSize: 20, q, status: status || undefined } }),
      ),
  });
  const approve = useMutation({
    mutationFn: (id: string) => unwrap(api.post(`/api/v1/venue-visits/${id}/approve`)),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['visits'] }),
    onError: (e: Error) => toast.error(e.message),
  });
  const complete = useMutation({
    mutationFn: (id: string) => unwrap(api.post(`/api/v1/venue-visits/${id}/complete`)),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['visits'] }),
    onError: (e: Error) => toast.error(e.message),
  });
  const cancel = useMutation({
    mutationFn: (id: string) => unwrap(api.post(`/api/v1/venue-visits/${id}/cancel`)),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['visits'] }),
    onError: (e: Error) => toast.error(e.message),
  });

  return (
    <div className="space-y-4">
      <ListToolbar
        title={t('nav.visits')}
        subtitle="Approve, reschedule, and assign venue walkthroughs."
        search={q}
        onSearch={(v) => {
          setQ(v);
          setPage(1);
        }}
        page={page}
        pageCount={list.data?.pageCount ?? 1}
        onPage={setPage}
        extra={
          <select className="h-10 rounded-md border px-2 text-sm" value={status} onChange={(e) => { setStatus(e.target.value); setPage(1); }}>
            <option value="">{t('common.status')}</option>
            {['REQUESTED', 'APPROVED', 'RESCHEDULED', 'CONFIRMED', 'COMPLETED', 'DECIDED', 'CANCELLED'].map((s) => (
              <option key={s} value={s}>{s}</option>
            ))}
          </select>
        }
      />
      <TableShell>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>{t('nav.venues')}</TableHead>
            <TableHead>{t('nav.customers')}</TableHead>
            <TableHead>{t('common.status')}</TableHead>
            <TableHead>{t('common.actions')}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {(list.data?.items ?? []).map((row) => (
            <TableRow key={row.id}>
              <TableCell>{loc(row.venue.name, i18n.language)}</TableCell>
              <TableCell>
                {row.customer.firstName} {row.customer.lastName} — {row.customer.email}
              </TableCell>
              <TableCell>
                <StatusBadge status={row.status} />
                <p className="mt-1 text-xs text-muted-foreground">{new Date(row.scheduledAt).toLocaleString()}</p>
              </TableCell>
              <TableCell className="space-x-1">
                <Button size="sm" onClick={() => approve.mutate(row.id)}>
                  {t('common.approve')}
                </Button>
                <Button size="sm" variant="outline" onClick={() => complete.mutate(row.id)}>
                  Complete
                </Button>
                <Button size="sm" variant="outline" onClick={() => setActive(row)}>
                  {t('common.edit')}
                </Button>
                <Button size="sm" variant="destructive" onClick={() => cancel.mutate(row.id)}>
                  {t('common.delete') === 'Delete' ? 'Cancel' : t('common.delete')}
                </Button>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
      </TableShell>
      {active ? <VisitActions visit={active} onDone={() => { setActive(null); void qc.invalidateQueries({ queryKey: ['visits'] }); }} /> : null}
    </div>
  );
}

function VisitActions({ visit, onDone }: { visit: Visit; onDone: () => void }) {
  const { t, i18n } = useTranslation();
  const reschedule = useForm<z.infer<typeof rescheduleSchema>>({
    resolver: zodResolver(rescheduleSchema),
    defaultValues: { scheduledAt: visit.scheduledAt.slice(0, 16), notes: { en: '', ar: '' } },
  });
  const assign = useForm<z.infer<typeof assignSchema>>({ resolver: zodResolver(assignSchema) });
  const notes = useForm<z.infer<typeof notesSchema>>({
    resolver: zodResolver(notesSchema),
    defaultValues: { notes: { en: '', ar: '' } },
  });
  const vendor = useQuery({
    queryKey: ['vendor-reps', visit.venue.vendorId],
    queryFn: () =>
      unwrap<{ representatives: Array<{ id: string; name: unknown }> }>(api.get(`/api/v1/vendors/${visit.venue.vendorId}`)),
  });

  async function post(path: string, body: unknown): Promise<void> {
    try {
      await unwrap(api.post(path, body));
      onDone();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : t('common.error'));
    }
  }

  return (
    <div className="grid gap-4 rounded-2xl border bg-white p-4 md:grid-cols-3 shadow-sm">
      <form className="space-y-2" onSubmit={reschedule.handleSubmit((v) => void post(`/api/v1/venue-visits/${visit.id}/reschedule`, { scheduledAt: new Date(v.scheduledAt).toISOString(), notes: v.notes }))}>
        <p className="font-medium">Reschedule</p>
        <Input type="datetime-local" {...reschedule.register('scheduledAt')} />
        <Input placeholder={t('common.english')} {...reschedule.register('notes.en')} />
        <Input dir="rtl" placeholder={t('common.arabic')} {...reschedule.register('notes.ar')} />
        <Button type="submit" size="sm">{t('common.save')}</Button>
      </form>
      <form className="space-y-2" onSubmit={assign.handleSubmit((v) => void post(`/api/v1/venue-visits/${visit.id}/assign`, v))}>
        <p className="font-medium">Assign</p>
        <select className="h-10 w-full rounded-md border px-2 text-sm" {...assign.register('representativeId')}>
          <option value="">—</option>
          {(vendor.data?.representatives ?? []).map((r) => (
            <option key={r.id} value={r.id}>
              {loc(r.name, i18n.language)}
            </option>
          ))}
        </select>
        <Button type="submit" size="sm">{t('common.save')}</Button>
      </form>
      <form className="space-y-2" onSubmit={notes.handleSubmit((v) => void post(`/api/v1/venue-visits/${visit.id}/notes`, v))}>
        <p className="font-medium">{t('common.notes')}</p>
        <Input {...notes.register('notes.en')} />
        <Input dir="rtl" {...notes.register('notes.ar')} />
        <Button type="submit" size="sm">{t('common.save')}</Button>
      </form>
    </div>
  );
}
