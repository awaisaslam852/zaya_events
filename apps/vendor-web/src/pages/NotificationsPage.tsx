import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { loc } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { Button } from '@/components/ui/button';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';

type Row = { id: string; title: unknown; body: unknown; status: string; createdAt: string };

export function NotificationsPage() {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const list = useQuery({
    queryKey: ['vendor-notifs', page],
    queryFn: () => unwrap<Paginated<Row>>(api.get('/api/v1/notifications', { params: { page, pageSize: 20 } })),
  });
  const readAll = useMutation({
    mutationFn: () => unwrap(api.post('/api/v1/notifications/read-all')),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['vendor-notifs'] }),
  });

  return (
    <div>
      <ListToolbar
        title={t('nav.notifications')}
        search={q}
        onSearch={setQ}
        page={page}
        pageCount={list.data?.pageCount ?? 1}
        onPage={setPage}
        extra={
          <Button size="sm" variant="outline" onClick={() => readAll.mutate()}>
            read-all
          </Button>
        }
      />
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>title</TableHead>
            <TableHead>{t('common.status')}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {(list.data?.items ?? [])
            .filter((row) => !q || loc(row.title, i18n.language).toLowerCase().includes(q.toLowerCase()))
            .map((row) => (
              <TableRow key={row.id}>
                <TableCell>
                  {loc(row.title, i18n.language)}
                  <p className="text-xs text-muted-foreground">{loc(row.body, i18n.language)}</p>
                </TableCell>
                <TableCell>{row.status}</TableCell>
              </TableRow>
            ))}
        </TableBody>
      </Table>
    </div>
  );
}
