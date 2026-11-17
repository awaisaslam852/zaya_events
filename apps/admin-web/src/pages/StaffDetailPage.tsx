import { useNavigate, useParams } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap } from '@/lib/api';
import { setDeskCountry } from '@/lib/auth';
import { countryName } from '@/lib/countries';
import { Button } from '@/components/ui/button';
import { StatusBadge } from '@/components/StatusBadge';
import { BackLink, EmptyHint, PersonAvatar, StatTile } from '@/components/AdminChrome';
import { toast } from 'sonner';

type Activity = {
  kind: string;
  at: string;
  action: string;
  entityType: string;
  entityId: string | null;
  country: string | null;
  meta?: unknown;
};

type StaffDetail = {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  phone: string | null;
  status: string;
  isSuperAdmin: boolean;
  allowedCountries: string[];
  lastLoginAt: string | null;
  createdAt: string;
  activity: Activity[];
};

export function StaffDetailPage() {
  const { t } = useTranslation();
  const { id } = useParams();
  const navigate = useNavigate();
  const qc = useQueryClient();
  const detail = useQuery({
    queryKey: ['admin', id],
    enabled: Boolean(id),
    queryFn: () => unwrap<StaffDetail>(api.get(`/api/v1/admins/${id}`)),
  });
  const patch = useMutation({
    mutationFn: (status: string) => unwrap(api.patch(`/api/v1/admins/${id}`, { status })),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['admin', id] });
      void qc.invalidateQueries({ queryKey: ['admins'] });
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const row = detail.data;

  function openDesk() {
    const country = row?.allowedCountries[0];
    if (!country) {
      toast.error(t('staff.noCountries'));
      return;
    }
    setDeskCountry(country);
    navigate('/');
    window.location.reload();
  }

  if (!row) {
    return <EmptyHint>{detail.isLoading ? t('common.loading') : t('common.empty')}</EmptyHint>;
  }

  return (
    <div className="space-y-4">
      <BackLink to="/staff" label={t('nav.staff')} />
      <div className="overflow-hidden rounded-2xl border bg-white shadow-sm sm:rounded-3xl">
        <div className="brand-hero px-4 py-6 text-white sm:px-6 sm:py-8">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div className="flex min-w-0 items-center gap-3">
              <PersonAvatar first={row.firstName} last={row.lastName} className="h-14 w-14 text-base" />
              <div className="min-w-0">
                <p className="text-xs font-semibold uppercase tracking-[0.2em] text-[#FEBB02]">
                  {row.isSuperAdmin ? t('staff.hqAccess') : t('staff.deskAccess')}
                </p>
                <h1 className="truncate text-2xl font-extrabold sm:text-3xl">
                  {row.firstName} {row.lastName}
                </h1>
                <p className="truncate text-sm text-white/80">{row.email}</p>
              </div>
            </div>
            <StatusBadge status={row.isSuperAdmin ? 'SUPER' : row.status} />
          </div>
          {!row.isSuperAdmin ? (
            <div className="mt-4 grid grid-cols-2 gap-2 sm:flex sm:flex-wrap">
              <Button variant="secondary" className="w-full sm:w-auto" onClick={openDesk}>
                {t('staff.openDesk')}
              </Button>
              {row.status === 'SUSPENDED' || row.status === 'INACTIVE' ? (
                <Button className="w-full sm:w-auto" onClick={() => patch.mutate('ACTIVE')}>
                  {t('staff.activate')}
                </Button>
              ) : (
                <>
                  <Button variant="secondary" className="w-full sm:w-auto" onClick={() => patch.mutate('SUSPENDED')}>
                    {t('staff.suspend')}
                  </Button>
                  <Button variant="ghost" className="w-full bg-white/10 text-white sm:w-auto" onClick={() => patch.mutate('INACTIVE')}>
                    {t('staff.block')}
                  </Button>
                </>
              )}
            </div>
          ) : null}
        </div>
        <div className="grid grid-cols-2 gap-3 p-4 lg:grid-cols-4">
          <StatTile label={t('common.status')} value={row.isSuperAdmin ? t('staff.super') : row.status} />
          <StatTile
            label={t('staff.countries')}
            value={row.isSuperAdmin ? t('staff.allCountries') : row.allowedCountries.map((code) => countryName(code)).join(', ') || t('staff.noCountries')}
          />
          <StatTile
            label={t('staff.lastLogin')}
            value={row.lastLoginAt ? new Date(row.lastLoginAt).toLocaleString() : t('common.neverLoggedIn')}
          />
          <StatTile label={t('common.phone')} value={row.phone || '—'} hint={new Date(row.createdAt).toLocaleDateString()} />
        </div>
      </div>
      <section className="rounded-2xl border bg-white p-4 shadow-sm">
        <h2 className="mb-3 text-lg font-extrabold text-[#003580]">{t('staff.activity')}</h2>
        {row.activity.length === 0 ? (
          <EmptyHint>{t('common.empty')}</EmptyHint>
        ) : (
          <ul className="grid gap-2">
            {row.activity.map((item, index) => (
              <li key={`${item.action}-${item.at}-${index}`} className="rounded-lg border px-3 py-2 text-sm">
                <p className="font-semibold text-[#003580]">{item.action}</p>
                <p className="text-xs text-muted-foreground">
                  {new Date(item.at).toLocaleString()}
                  {item.country ? ` · ${countryName(item.country)}` : ''}
                  {item.entityType ? ` · ${item.entityType}` : ''}
                </p>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}
