import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { coverOf, loc, money } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { Button } from '@/components/ui/button';
import { StatusBadge } from '@/components/StatusBadge';
import { EmptyHint } from '@/components/AdminChrome';
import { toast } from 'sonner';

type Listing = {
  id: string;
  title: unknown;
  city: string | null;
  startingPrice: string;
  currency: string;
  isPublished: boolean;
  coverKey: string | null;
  galleryKeys?: unknown;
  vendor?: { id: string; businessName: unknown };
  category?: { name: unknown };
  packages?: Array<{ id: string }>;
};

export function ListingsPage() {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const list = useQuery({
    queryKey: ['admin-listings', page],
    queryFn: () => unwrap<Paginated<Listing>>(api.get('/api/v1/listings', { params: { page, pageSize: 24 } })),
  });
  const publish = useMutation({
    mutationFn: (row: Listing) => unwrap(api.patch(`/api/v1/listings/${row.id}`, { isPublished: !row.isPublished })),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['admin-listings'] }),
    onError: (e: Error) => toast.error(e.message),
  });
  const items = (list.data?.items ?? []).filter((row) => !q || loc(row.title, i18n.language).toLowerCase().includes(q.toLowerCase()));

  return (
    <div>
      <ListToolbar
        title={t('nav.listings')}
        subtitle="All vendor service listings — photos, prices, and publish control."
        search={q}
        onSearch={setQ}
        page={page}
        pageCount={list.data?.pageCount ?? 1}
        onPage={setPage}
      />
      {items.length === 0 ? (
        <EmptyHint>{t('common.empty')}</EmptyHint>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          {items.map((row) => {
            const photo = coverOf(row);
            return (
              <article key={row.id} className="overflow-hidden rounded-2xl border bg-white shadow-sm">
                <Link to={`/listings/${row.id}`}>
                  <div className="h-40 bg-[#d6e6f5]">{photo ? <img src={photo} alt="" className="h-40 w-full object-cover" /> : null}</div>
                </Link>
                <div className="space-y-2 p-3">
                  <StatusBadge status={row.isPublished ? 'ACTIVE' : 'INACTIVE'} />
                  <Link to={`/listings/${row.id}`}>
                    <h2 className="line-clamp-2 font-extrabold text-[#003580]">{loc(row.title, i18n.language)}</h2>
                  </Link>
                  <p className="text-xs text-muted-foreground">
                    {loc(row.category?.name, i18n.language)} · {row.city || '—'}
                  </p>
                  {row.vendor ? (
                    <Link className="block text-xs text-[#0071c2] hover:underline" to={`/vendors/${row.vendor.id}`}>
                      {loc(row.vendor.businessName, i18n.language)}
                    </Link>
                  ) : null}
                  <p className="font-extrabold">{money(row.startingPrice, row.currency)}</p>
                  <div className="flex gap-2">
                    <Button size="sm" variant="outline" className="flex-1" onClick={() => publish.mutate(row)}>
                      {row.isPublished ? 'Unpublish' : 'Publish'}
                    </Button>
                    <Button size="sm" asChild className="flex-1">
                      <Link to={`/listings/${row.id}`}>Detail</Link>
                    </Button>
                  </div>
                </div>
              </article>
            );
          })}
        </div>
      )}
    </div>
  );
}
