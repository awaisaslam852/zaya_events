import { useEffect, useMemo, useState } from 'react';
import AgoraRTC, { AgoraRTCProvider, RemoteUser, useJoin, useRemoteUsers } from 'agora-rtc-react';
import { useQuery } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { ListToolbar } from '@/components/ListToolbar';
import { Button } from '@/components/ui/button';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { StatusBadge } from '@/components/StatusBadge';
import { TableShell } from '@/components/AdminChrome';
import { toast } from 'sonner';

type CallRow = {
  id: string;
  channelName: string;
  status: string;
  createdAt: string;
  caller: { firstName: string; lastName: string };
  callee: { firstName: string; lastName: string };
};

type Rtc = { token: string; appId: string; channelName: string; uid: number; role: string };

export function CallsPage() {
  const { t } = useTranslation();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [session, setSession] = useState<Rtc | null>(null);
  const list = useQuery({
    queryKey: ['calls', page, q],
    queryFn: () => unwrap<Paginated<CallRow>>(api.get('/api/v1/calls/history', { params: { page, pageSize: 20, q } })),
  });

  async function observe(id: string): Promise<void> {
    try {
      const token = await unwrap<Rtc>(api.get(`/api/v1/calls/${id}/token`));
      setSession(token);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : t('common.error'));
    }
  }

  return (
    <div className="space-y-4">
      <ListToolbar title={t('nav.calls')} subtitle="Voice sessions between guests and partners — observe when needed." search={q} onSearch={(v) => { setQ(v); setPage(1); }} page={page} pageCount={list.data?.pageCount ?? 1} onPage={setPage} />
      <TableShell>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>channel</TableHead>
            <TableHead>{t('common.status')}</TableHead>
            <TableHead>{t('common.actions')}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {(list.data?.items ?? []).map((row) => (
            <TableRow key={row.id}>
              <TableCell>
                <p className="font-semibold">{row.channelName}</p>
                <p className="text-xs text-muted-foreground">{row.caller.firstName} → {row.callee.firstName}</p>
              </TableCell>
              <TableCell><StatusBadge status={row.status} /></TableCell>
              <TableCell>
                <Button size="sm" onClick={() => void observe(row.id)}>
                  {t('calls.observe')}
                </Button>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
      </TableShell>
      {session ? <ObservePanel rtc={session} onClose={() => setSession(null)} /> : null}
    </div>
  );
}

function ObservePanel({ rtc, onClose }: { rtc: Rtc; onClose: () => void }) {
  const { t } = useTranslation();
  const client = useMemo(() => AgoraRTC.createClient({ mode: 'live', codec: 'vp8' }), []);
  useEffect(() => {
    void client.setClientRole('audience');
  }, [client]);

  return (
    <div className="rounded-md border p-4">
      <div className="mb-2 flex items-center justify-between">
        <p className="font-medium">{t('calls.observing')}</p>
        <Button size="sm" variant="outline" onClick={onClose}>
          {t('common.delete')}
        </Button>
      </div>
      <AgoraRTCProvider client={client}>
        <ObserverJoin rtc={rtc} />
      </AgoraRTCProvider>
    </div>
  );
}

function ObserverJoin({ rtc }: { rtc: Rtc }) {
  useJoin({ appid: rtc.appId, channel: rtc.channelName, token: rtc.token, uid: rtc.uid }, true);
  const remotes = useRemoteUsers();
  return (
    <div className="grid gap-2 md:grid-cols-2">
      {remotes.map((user) => (
        <div key={String(user.uid)} className="overflow-hidden rounded bg-black">
          <RemoteUser user={user} playVideo playAudio />
        </div>
      ))}
    </div>
  );
}
