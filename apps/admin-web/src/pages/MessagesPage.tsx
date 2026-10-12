import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api, unwrap, type Paginated } from '@/lib/api';
import { ListToolbar } from '@/components/ListToolbar';
import { EmptyHint, Section } from '@/components/AdminChrome';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { toast } from 'sonner';

type Conversation = {
  id: string;
  type: string;
  lastMessageAt: string | null;
  participantA: { id: string; firstName: string; lastName: string; role: string };
  participantB: { id: string; firstName: string; lastName: string; role: string };
  messages?: Array<{ body: string }>;
};

type Message = { id: string; body: string; senderId: string; createdAt: string };

export function MessagesPage() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [activeId, setActiveId] = useState<string | null>(null);
  const [draft, setDraft] = useState('');
  const list = useQuery({
    queryKey: ['admin-chat', page],
    queryFn: () => unwrap<Paginated<Conversation>>(api.get('/api/v1/chat/conversations', { params: { page, pageSize: 40 } })),
  });
  const thread = useQuery({
    queryKey: ['admin-chat-thread', activeId],
    queryFn: () => unwrap<Paginated<Message>>(api.get(`/api/v1/chat/conversations/${activeId}/messages`, { params: { pageSize: 50 } })),
    enabled: Boolean(activeId),
  });
  const send = useMutation({
    mutationFn: (body: string) => unwrap(api.post(`/api/v1/chat/conversations/${activeId}/messages`, { type: 'TEXT', body })),
    onSuccess: () => {
      setDraft('');
      void qc.invalidateQueries({ queryKey: ['admin-chat-thread', activeId] });
      void qc.invalidateQueries({ queryKey: ['admin-chat'] });
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const items = (list.data?.items ?? []).filter((row) => {
    if (!q) {
      return true;
    }
    const hay = `${row.participantA.firstName} ${row.participantA.lastName} ${row.participantB.firstName} ${row.participantB.lastName} ${row.type}`.toLowerCase();
    return hay.includes(q.toLowerCase());
  });

  return (
    <div className="grid gap-4 lg:grid-cols-[320px_1fr]">
      <div>
        <ListToolbar
          title="Support inbox"
          subtitle="Customer and vendor conversations with admin."
          search={q}
          onSearch={setQ}
          page={page}
          pageCount={list.data?.pageCount ?? 1}
          onPage={setPage}
        />
        {items.length === 0 ? (
          <EmptyHint>No conversations yet</EmptyHint>
        ) : (
          <div className="space-y-2">
            {items.map((row) => {
              const name = `${row.participantA.firstName} ${row.participantA.lastName} · ${row.participantB.firstName} ${row.participantB.lastName}`;
              return (
                <button
                  key={row.id}
                  type="button"
                  onClick={() => setActiveId(row.id)}
                  className={`w-full rounded-2xl border bg-white px-3 py-3 text-start ${activeId === row.id ? 'border-[#003580]' : ''}`}
                >
                  <p className="text-xs font-semibold uppercase text-muted-foreground">{row.type.replaceAll('_', ' ')}</p>
                  <p className="font-semibold text-[#003580]">{name}</p>
                  <p className="truncate text-xs text-muted-foreground">{row.messages?.[0]?.body ?? row.lastMessageAt ?? '—'}</p>
                </button>
              );
            })}
          </div>
        )}
      </div>
      <Section title="Thread">
        {!activeId ? (
          <EmptyHint>Select a conversation</EmptyHint>
        ) : (
          <div className="flex h-[70vh] flex-col">
            <div className="flex-1 space-y-2 overflow-y-auto">
              {(thread.data?.items ?? []).slice().reverse().map((msg) => (
                <div key={msg.id} className="rounded-xl bg-[#f5f7fa] px-3 py-2 text-sm">
                  <p>{msg.body}</p>
                  <p className="mt-1 text-[11px] text-muted-foreground">{new Date(msg.createdAt).toLocaleString()}</p>
                </div>
              ))}
            </div>
            <form
              className="mt-3 flex gap-2"
              onSubmit={(e) => {
                e.preventDefault();
                if (draft.trim()) {
                  send.mutate(draft.trim());
                }
              }}
            >
              <Input value={draft} onChange={(e) => setDraft(e.target.value)} placeholder="Reply as admin" />
              <Button type="submit">Send</Button>
            </form>
          </div>
        )}
      </Section>
    </div>
  );
}
