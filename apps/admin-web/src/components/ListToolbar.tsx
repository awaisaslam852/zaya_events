import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

type Props = {
  title: string;
  subtitle?: string;
  search: string;
  onSearch: (value: string) => void;
  page: number;
  pageCount: number;
  onPage: (page: number) => void;
  extra?: ReactNode;
};

export function ListToolbar({ title, subtitle, search, onSearch, page, pageCount, onPage, extra }: Props) {
  const { t } = useTranslation();
  return (
    <div className="mb-6 flex flex-col gap-3 md:flex-row md:items-end md:justify-between">
      <div>
        <h1 className="text-3xl font-extrabold tracking-tight text-[#003580]">{title}</h1>
        <p className="text-sm text-muted-foreground">
          {subtitle ?? 'Search, filter, and keep this inventory live for the customer app.'}
        </p>
      </div>
      <div className="flex flex-wrap items-center gap-2">
        {extra}
        <Input
          value={search}
          placeholder={t('common.search')}
          onChange={(e) => onSearch(e.target.value)}
          className="w-56"
        />
        <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => onPage(page - 1)}>
          {t('common.prev')}
        </Button>
        <span className="text-sm text-muted-foreground">
          {page}/{Math.max(pageCount, 1)}
        </span>
        <Button variant="outline" size="sm" disabled={page >= pageCount} onClick={() => onPage(page + 1)}>
          {t('common.next')}
        </Button>
      </div>
    </div>
  );
}
