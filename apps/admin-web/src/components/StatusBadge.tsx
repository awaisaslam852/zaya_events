import { cn } from '@/lib/utils';

const tones: Record<string, string> = {
  ACTIVE: 'bg-emerald-50 text-emerald-800 border-emerald-200',
  APPROVED: 'bg-emerald-50 text-emerald-800 border-emerald-200',
  CONFIRMED: 'bg-emerald-50 text-emerald-800 border-emerald-200',
  COMPLETED: 'bg-emerald-50 text-emerald-800 border-emerald-200',
  PAID: 'bg-emerald-50 text-emerald-800 border-emerald-200',
  PENDING: 'bg-amber-50 text-amber-800 border-amber-200',
  CONFIGURATION_NEEDED: 'bg-amber-50 text-amber-800 border-amber-200',
  PENDING_VERIFICATION: 'bg-amber-50 text-amber-800 border-amber-200',
  INQUIRY: 'bg-amber-50 text-amber-800 border-amber-200',
  UNDER_REVIEW: 'bg-sky-50 text-sky-800 border-sky-200',
  IN_PROGRESS: 'bg-sky-50 text-sky-800 border-sky-200',
  REQUESTED: 'bg-sky-50 text-sky-800 border-sky-200',
  INACTIVE: 'bg-slate-100 text-slate-600 border-slate-200',
  SUSPENDED: 'bg-slate-100 text-slate-600 border-slate-200',
  CANCELLED: 'bg-rose-50 text-rose-800 border-rose-200',
  REJECTED: 'bg-rose-50 text-rose-800 border-rose-200',
  FAILED: 'bg-rose-50 text-rose-800 border-rose-200',
};

export function StatusBadge({ status }: { status?: string | null }) {
  const value = status || '—';
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-full border px-2.5 py-0.5 text-[11px] font-bold uppercase tracking-wide',
        tones[value] ?? 'bg-slate-50 text-slate-700 border-slate-200',
      )}
    >
      {value.replaceAll('_', ' ')}
    </span>
  );
}
