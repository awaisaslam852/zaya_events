import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { ListToolbar } from '@/components/ListToolbar';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';

type CallRow = {
  id: string;
  channelName: string;
  status: string;
  createdAt: string;
  caller: { firstName: string; lastName: string };
  callee: { firstName: string; lastName: string };
};

export function CallsPage() {
  const { t } = useTranslation();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const list = useQuery({
    queryKey: ['vendor-calls', page, q],
    queryFn: () => unwrap<Paginated<CallRow>>(api.get('/api/v1/calls/history', { params: { page, pageSize: 20, q } })),
  });

  return (
    <div>
      <ListToolbar title={t('nav.calls')} search={q} onSearch={(v) => { setQ(v); setPage(1); }} page={page} pageCount={list.data?.pageCount ?? 1} onPage={setPage} />
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>channel</TableHead>
            <TableHead>{t('common.status')}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {(list.data?.items ?? []).map((row) => (
            <TableRow key={row.id}>
              <TableCell>
                {row.channelName} · {row.caller.firstName} / {row.callee.firstName}
              </TableCell>
              <TableCell>{row.status}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
