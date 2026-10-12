import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { loc } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { toast } from 'sonner';

const schema = z.object({
  resourceType: z.enum(['LISTING', 'CAR', 'ACCOMMODATION']),
  resourceId: z.string().uuid(),
  startAt: z.string().min(1),
  endAt: z.string().min(1),
  status: z.enum(['AVAILABLE', 'UNAVAILABLE', 'RESERVED']),
  source: z.enum(['internal', 'external']),
  isBlocked: z.boolean(),
});
type Form = z.infer<typeof schema>;
type Slot = { id: string; startAt: string; endAt: string; status: string; source: string; isBlocked: boolean };
type Named = { id: string; name?: unknown; title?: unknown };

export function AvailabilityPage() {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const form = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: { resourceType: 'LISTING', resourceId: '', startAt: '', endAt: '', status: 'AVAILABLE', source: 'internal', isBlocked: false },
  });
  const type = form.watch('resourceType');
  const resourceId = form.watch('resourceId');
  const listings = useQuery({
    queryKey: ['avail-listings'],
    queryFn: () => unwrap<Paginated<Named>>(api.get('/api/v1/listings', { params: { pageSize: 50 } })),
  });
  const cars = useQuery({
    queryKey: ['avail-cars'],
    queryFn: () => unwrap<Paginated<Named>>(api.get('/api/v1/cars', { params: { pageSize: 50 } })),
  });
  const stays = useQuery({
    queryKey: ['avail-stays'],
    queryFn: () => unwrap<Paginated<Named>>(api.get('/api/v1/accommodations', { params: { pageSize: 50 } })),
  });
  const options = type === 'CAR' ? cars.data?.items : type === 'ACCOMMODATION' ? stays.data?.items : listings.data?.items;
  const slots = useQuery({
    queryKey: ['availability', type, resourceId],
    queryFn: () =>
      unwrap<Paginated<Slot>>(
        api.get('/api/v1/availability', { params: { resourceType: type, resourceId, pageSize: 50 } }),
      ),
    enabled: Boolean(resourceId),
  });
  const create = useMutation({
    mutationFn: (values: Form) =>
      unwrap(
        api.post('/api/v1/availability', {
          ...values,
          startAt: new Date(values.startAt).toISOString(),
          endAt: new Date(values.endAt).toISOString(),
          isBlocked: values.status !== 'AVAILABLE' || values.source === 'external',
        }),
      ),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['availability'] }),
    onError: (e: Error) => toast.error(e.message),
  });
  const remove = useMutation({
    mutationFn: (id: string) => unwrap(api.delete(`/api/v1/availability/${id}`)),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['availability'] }),
  });
  const [q, setQ] = useState('');

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">{t('nav.availability')}</h1>
      <form className="grid gap-2 rounded-md border p-4 md:grid-cols-2" onSubmit={form.handleSubmit((v) => create.mutate(v))}>
        <select className="h-10 rounded-md border px-2 text-sm" {...form.register('resourceType')}>
          <option value="LISTING">LISTING</option>
          <option value="CAR">CAR</option>
          <option value="ACCOMMODATION">ACCOMMODATION</option>
        </select>
        <select className="h-10 rounded-md border px-2 text-sm" {...form.register('resourceId')}>
          <option value="">—</option>
          {(options ?? []).map((row) => (
            <option key={row.id} value={row.id}>
              {loc(row.title ?? row.name, i18n.language)}
            </option>
          ))}
        </select>
        <Input type="datetime-local" {...form.register('startAt')} />
        <Input type="datetime-local" {...form.register('endAt')} />
        <select className="h-10 rounded-md border px-2 text-sm" {...form.register('status')}>
          <option value="AVAILABLE">AVAILABLE</option>
          <option value="UNAVAILABLE">UNAVAILABLE</option>
          <option value="RESERVED">RESERVED</option>
        </select>
        <select className="h-10 rounded-md border px-2 text-sm" {...form.register('source')}>
          <option value="internal">internal</option>
          <option value="external">blocked-external</option>
        </select>
        <Button type="submit">{t('common.create')}</Button>
      </form>
      <Input className="max-w-xs" placeholder={t('common.search')} value={q} onChange={(e) => setQ(e.target.value)} />
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Range</TableHead>
            <TableHead>{t('common.status')}</TableHead>
            <TableHead>{t('common.actions')}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {(slots.data?.items ?? [])
            .filter((s) => !q || s.status.toLowerCase().includes(q.toLowerCase()))
            .map((s) => (
              <TableRow key={s.id}>
                <TableCell>
                  {new Date(s.startAt).toLocaleString()} → {new Date(s.endAt).toLocaleString()}
                </TableCell>
                <TableCell>
                  {s.status} {s.source === 'external' ? '(blocked-external)' : ''}
                </TableCell>
                <TableCell>
                  <Button size="sm" variant="destructive" onClick={() => remove.mutate(s.id)}>
                    {t('common.delete')}
                  </Button>
                </TableCell>
              </TableRow>
            ))}
        </TableBody>
      </Table>
    </div>
  );
}
