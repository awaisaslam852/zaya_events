import type { ReactNode, SelectHTMLAttributes } from 'react';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { cn, coverOf, initials } from '@/lib/utils';
import { Label } from '@/components/ui/label';
import { StatusBadge } from '@/components/StatusBadge';

export function TableShell({ children }: { children: ReactNode }) {
  return <div className="overflow-hidden rounded-2xl border bg-white shadow-sm shadow-blue-900/5">{children}</div>;
}

export function EmptyHint({ children }: { children: ReactNode }) {
  return <p className="rounded-xl border border-dashed bg-slate-50 px-4 py-10 text-center text-sm text-muted-foreground">{children}</p>;
}

export function StatTile({ label, value, hint }: { label: string; value: string; hint?: string }) {
  return (
    <div className="rounded-2xl border bg-white p-4 shadow-sm shadow-blue-900/5">
      <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">{label}</p>
      <p className="mt-1 break-words text-xl font-extrabold text-[#003580] sm:text-2xl">{value}</p>
      {hint ? <p className="mt-1 text-xs text-muted-foreground">{hint}</p> : null}
    </div>
  );
}

export function Section({ title, action, children }: { title: string; action?: ReactNode; children: ReactNode }) {
  return (
    <section className="rounded-2xl border bg-white p-5 shadow-sm shadow-blue-900/5">
      <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
        <h2 className="text-base font-extrabold text-[#003580]">{title}</h2>
        {action}
      </div>
      {children}
    </section>
  );
}

export function GalleryStrip({ items }: { items: Array<{ coverKey?: string | null; galleryKeys?: unknown }> }) {
  const { t } = useTranslation();
  const urls = items.map((item) => coverOf(item)).filter(Boolean);
  if (urls.length === 0) {
    return <EmptyHint>{t('common.noPhotos')}</EmptyHint>;
  }
  return (
    <div className="flex gap-2 overflow-x-auto pb-1">
      {urls.map((src) => (
        <a key={src} href={src} target="_blank" rel="noreferrer" className="shrink-0">
          <img src={src} alt="" className="h-28 w-40 rounded-xl object-cover" />
        </a>
      ))}
    </div>
  );
}

export function PersonAvatar({
  first,
  last,
  src,
  className,
}: {
  first?: string | null;
  last?: string | null;
  src?: string | null;
  className?: string;
}) {
  if (src) {
    return <img src={src} alt="" className={cn('h-12 w-12 rounded-full object-cover', className)} />;
  }
  return (
    <div
      className={cn(
        'flex h-12 w-12 items-center justify-center rounded-full bg-[#003580] text-sm font-extrabold text-white',
        className,
      )}
    >
      {initials(first, last)}
    </div>
  );
}

export function BackLink({ to, label }: { to: string; label: string }) {
  return (
    <Link to={to} className="text-sm font-semibold text-[#0071c2] hover:underline">
      ← {label}
    </Link>
  );
}

export function RowLink({ to, title, meta, status }: { to: string; title: string; meta: string; status?: string }) {
  return (
    <Link to={to} className="flex items-center justify-between gap-3 rounded-xl border px-3 py-3 hover:bg-[#f5f7fa]">
      <div>
        <p className="font-semibold">{title}</p>
        <p className="text-xs text-muted-foreground">{meta}</p>
      </div>
      {status ? <StatusBadge status={status} /> : null}
    </Link>
  );
}

export function PhotoCard({
  to,
  photo,
  title,
  meta,
  price,
  status,
  children,
}: {
  to?: string;
  photo?: string;
  title: string;
  meta: string;
  price?: string;
  status?: string;
  children?: ReactNode;
}) {
  const body = (
    <article className="overflow-hidden rounded-2xl border bg-white shadow-sm shadow-blue-900/5 transition hover:-translate-y-0.5 hover:shadow-md">
      <div className="h-40 bg-[#d6e6f5]">{photo ? <img src={photo} alt="" className="h-40 w-full object-cover" /> : null}</div>
      <div className="space-y-1.5 p-3">
        {status ? <StatusBadge status={status} /> : null}
        <h2 className="line-clamp-2 font-extrabold text-[#003580]">{title}</h2>
        <p className="text-xs text-muted-foreground">{meta}</p>
        {price ? <p className="font-extrabold">{price}</p> : null}
        {children}
      </div>
    </article>
  );
  return to ? <Link to={to}>{body}</Link> : body;
}

export function FormSection({ title, hint, children }: { title: string; hint?: string; children: ReactNode }) {
  return (
    <section className="space-y-3 rounded-2xl border border-slate-200 bg-slate-50/80 p-4">
      <div>
        <h3 className="text-sm font-extrabold text-[#003580]">{title}</h3>
        {hint ? <p className="mt-1 text-xs leading-relaxed text-muted-foreground">{hint}</p> : null}
      </div>
      {children}
    </section>
  );
}

export function Field({ label, hint, children }: { label: string; hint?: string; children: ReactNode }) {
  return (
    <div className="space-y-1.5">
      <Label>{label}</Label>
      {children}
      {hint ? <p className="text-xs leading-relaxed text-muted-foreground">{hint}</p> : null}
    </div>
  );
}

export function NativeSelect({ className, ...props }: SelectHTMLAttributes<HTMLSelectElement>) {
  return (
    <select
      className={cn(
        'flex h-10 w-full rounded-md border border-input bg-white px-3 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring',
        className,
      )}
      {...props}
    />
  );
}

export function FactGrid({ items }: { items: Array<{ label: string; value: ReactNode }> }) {
  return (
    <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
      {items.map((item) => (
        <div key={item.label} className="rounded-xl bg-[#f5f7fa] px-3 py-2">
          <p className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">{item.label}</p>
          <p className="mt-0.5 font-semibold text-[#003580]">{item.value || '—'}</p>
        </div>
      ))}
    </div>
  );
}
