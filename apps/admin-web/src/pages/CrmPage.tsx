import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { ListToolbar } from '@/components/ListToolbar';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { toast } from 'sonner';

const subjectSchema = z.object({
  subjectType: z.enum(['USER', 'VENDOR', 'BOOKING', 'EVENT', 'VENUE']),
  subjectId: z.string().uuid(),
});
const noteSchema = subjectSchema.extend({ body: z.string().min(1) });
const followSchema = subjectSchema.extend({ dueAt: z.string().min(1), summary: z.string().min(1) });

type Timeline = {
  activity: Array<{ kind: string; at: string; item: { id: string; body?: string; summary?: string; status?: string; type?: string } }>;
  followUps: Array<{ id: string; summary: string; status: string; dueAt: string }>;
};

export function CrmPage() {
  const { t } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const subject = useForm<z.infer<typeof subjectSchema>>({
    resolver: zodResolver(subjectSchema),
    defaultValues: { subjectType: 'USER', subjectId: '' },
  });
  const note = useForm<z.infer<typeof noteSchema>>({ resolver: zodResolver(noteSchema), defaultValues: { subjectType: 'USER', subjectId: '', body: '' } });
  const follow = useForm<z.infer<typeof followSchema>>({
    resolver: zodResolver(followSchema),
    defaultValues: { subjectType: 'USER', subjectId: '', dueAt: '', summary: '' },
  });
  const values = subject.watch();
  const enabled = z.string().uuid().safeParse(values.subjectId).success;
  const timeline = useQuery({
    queryKey: ['crm', values.subjectType, values.subjectId, page],
    queryFn: () =>
      unwrap<Timeline>(
        api.get('/api/v1/crm/timeline', { params: { subjectType: values.subjectType, subjectId: values.subjectId, page, pageSize: 50 } }),
      ),
    enabled,
  });
  const customers = useQuery({
    queryKey: ['crm-customers', q],
    queryFn: () =>
      unwrap<Paginated<{ id: string; email: string; firstName: string; lastName: string }>>(
        api.get('/api/v1/customers', { params: { q, pageSize: 10 } }),
      ),
  });
  const addNote = useMutation({
    mutationFn: (v: z.infer<typeof noteSchema>) => unwrap(api.post('/api/v1/crm/notes', v)),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['crm'] }),
    onError: (e: Error) => toast.error(e.message),
  });
  const addFollow = useMutation({
    mutationFn: (v: z.infer<typeof followSchema>) =>
      unwrap(api.post('/api/v1/crm/follow-ups', { ...v, dueAt: new Date(v.dueAt).toISOString() })),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['crm'] }),
    onError: (e: Error) => toast.error(e.message),
  });
  const patchFollow = useMutation({
    mutationFn: (p: { id: string; status: string }) => unwrap(api.patch(`/api/v1/crm/follow-ups/${p.id}`, { status: p.status })),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['crm'] }),
    onError: (e: Error) => toast.error(e.message),
  });

  return (
    <div className="space-y-4">
      <ListToolbar title={t('nav.crm')} subtitle="Notes and follow-ups against customers, vendors, and bookings." search={q} onSearch={setQ} page={page} pageCount={1} onPage={setPage} />
      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Record</CardTitle>
          </CardHeader>
          <CardContent className="space-y-2">
            <form className="grid gap-2" onSubmit={subject.handleSubmit(() => undefined)}>
              <select className="h-10 rounded-md border px-2 text-sm" {...subject.register('subjectType')}>
                {['USER', 'VENDOR', 'BOOKING', 'EVENT', 'VENUE'].map((s) => (
                  <option key={s} value={s}>{s}</option>
                ))}
              </select>
              <Input placeholder="subject UUID" {...subject.register('subjectId')} />
            </form>
            <div className="text-sm space-y-1">
              {(customers.data?.items ?? []).map((c) => (
                <button
                  key={c.id}
                  type="button"
                  className="block w-full rounded-lg border px-3 py-2 text-start hover:bg-[#f5f7fa]"
                  onClick={() => {
                    subject.setValue('subjectType', 'USER');
                    subject.setValue('subjectId', c.id);
                    note.setValue('subjectType', 'USER');
                    note.setValue('subjectId', c.id);
                    follow.setValue('subjectType', 'USER');
                    follow.setValue('subjectId', c.id);
                  }}
                >
                  {c.firstName} {c.lastName} — {c.email}
                </button>
              ))}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>{t('common.notes')} / follow-ups</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <form className="space-y-2" onSubmit={note.handleSubmit((v) => addNote.mutate({ ...v, ...values, subjectId: values.subjectId, subjectType: values.subjectType }))}>
              <Textarea {...note.register('body')} />
              <Button type="submit" size="sm">{t('common.save')}</Button>
            </form>
            <form className="space-y-2" onSubmit={follow.handleSubmit((v) => addFollow.mutate({ ...v, ...values }))}>
              <Input type="datetime-local" {...follow.register('dueAt')} />
              <Input {...follow.register('summary')} />
              <Button type="submit" size="sm">{t('common.create')}</Button>
            </form>
          </CardContent>
        </Card>
      </div>
      <Card>
        <CardHeader>
          <CardTitle>Timeline</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2 text-sm">
          {(timeline.data?.activity ?? []).map((row) => (
            <div key={row.item.id} className="border-b py-2">
              <span className="font-medium">{row.kind}</span> · {new Date(row.at).toLocaleString()}
              <p>{row.item.body ?? row.item.summary ?? row.item.type}</p>
            </div>
          ))}
          {(timeline.data?.followUps ?? []).map((f) => (
            <div key={f.id} className="flex items-center gap-2">
              <span>
                {f.summary} — {f.status} — {new Date(f.dueAt).toLocaleString()}
              </span>
              <Button size="sm" variant="outline" onClick={() => patchFollow.mutate({ id: f.id, status: 'DONE' })}>
                DONE
              </Button>
            </div>
          ))}
        </CardContent>
      </Card>
    </div>
  );
}
