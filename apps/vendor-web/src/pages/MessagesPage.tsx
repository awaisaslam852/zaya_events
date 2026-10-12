import { useEffect, useMemo, useState } from 'react';
import { io } from 'socket.io-client';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { getAccessToken, getUser } from '@/lib/auth';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { toast } from 'sonner';

type Convo = {
  id: string;
  participantAId: string;
  participantBId: string;
  participantA: { firstName: string; lastName: string };
  participantB: { firstName: string; lastName: string };
  messages: Array<{ body: string }>;
};
type Msg = { id: string; body: string; senderId: string; createdAt: string };

export function MessagesPage() {
  const { t } = useTranslation();
  const qc = useQueryClient();
  const me = getUser();
  const [active, setActive] = useState<string | null>(null);
  const [text, setText] = useState('');
  const list = useQuery({
    queryKey: ['convos'],
    queryFn: () => unwrap<Paginated<Convo>>(api.get('/api/v1/chat/conversations', { params: { pageSize: 50 } })),
  });
  const messages = useQuery({
    queryKey: ['msgs', active],
    queryFn: () => unwrap<Paginated<Msg>>(api.get(`/api/v1/chat/conversations/${active}/messages`, { params: { pageSize: 50 } })),
    enabled: Boolean(active),
  });
  const support = useMutation({
    mutationFn: () => unwrap<{ id: string }>(api.post('/api/v1/chat/conversations/support', {})),
    onSuccess: (row) => {
      setActive(row.id);
      void qc.invalidateQueries({ queryKey: ['convos'] });
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const send = useMutation({
    mutationFn: (body: string) => unwrap(api.post(`/api/v1/chat/conversations/${active}/messages`, { type: 'TEXT', body })),
    onSuccess: () => {
      setText('');
      void qc.invalidateQueries({ queryKey: ['msgs', active] });
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const call = useMutation({
    mutationFn: (calleeId: string) => unwrap(api.post('/api/v1/calls/initiate', { calleeId })),
    onSuccess: () => toast.success(t('calls.incoming')),
    onError: (e: Error) => toast.error(e.message),
  });
  const activeConvo = (list.data?.items ?? []).find((c) => c.id === active);
  const peerId =
    activeConvo && me
      ? activeConvo.participantAId === me.id
        ? activeConvo.participantBId
        : activeConvo.participantAId
      : null;
  const apiUrl = import.meta.env.VITE_API_URL ?? 'http://localhost:4000';
  const socket = useMemo(
    () => io(`${apiUrl}/chat`, { auth: { token: getAccessToken() }, autoConnect: false }),
    [apiUrl],
  );
  useEffect(() => {
    socket.connect();
    socket.on('message:new', () => {
      void qc.invalidateQueries({ queryKey: ['msgs'] });
      void qc.invalidateQueries({ queryKey: ['convos'] });
    });
    return () => {
      socket.off('message:new');
      socket.disconnect();
    };
  }, [qc, socket]);

  return (
    <div className="grid min-h-[70vh] gap-4 md:grid-cols-[16rem_1fr]">
      <aside className="space-y-1 rounded-md border p-2">
        <Button type="button" variant="outline" size="sm" className="mb-2 w-full" onClick={() => support.mutate()}>
          Contact support
        </Button>
        {(list.data?.items ?? []).map((c) => {
          const other = c.participantAId === me?.id ? c.participantB : c.participantA;
          return (
            <button key={c.id} type="button" className="block w-full rounded p-2 text-start text-sm hover:bg-accent" onClick={() => setActive(c.id)}>
              {other.firstName} {other.lastName}
            </button>
          );
        })}
      </aside>
      <section className="flex flex-col rounded-md border p-3">
        {active && peerId ? (
          <div className="mb-2 flex justify-end">
            <Button type="button" variant="outline" size="sm" onClick={() => call.mutate(peerId)}>
              {t('nav.calls')}
            </Button>
          </div>
        ) : null}
        <div className="flex-1 space-y-2 overflow-y-auto">
          {[...(messages.data?.items ?? [])].reverse().map((m) => (
            <div key={m.id} className={m.senderId === me?.id ? 'text-end' : 'text-start'}>
              <span className="inline-block rounded bg-muted px-3 py-1 text-sm">{m.body}</span>
            </div>
          ))}
        </div>
        {active ? (
          <form
            className="mt-3 flex gap-2"
            onSubmit={(e) => {
              e.preventDefault();
              if (text.trim()) {
                send.mutate(text.trim());
              }
            }}
          >
            <Input value={text} onChange={(e) => setText(e.target.value)} />
            <Button type="submit">{t('common.save')}</Button>
          </form>
        ) : (
          <p className="text-sm text-muted-foreground">{t('common.empty')}</p>
        )}
      </section>
    </div>
  );
}
