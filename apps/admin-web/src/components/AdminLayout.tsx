import { useEffect, useState } from 'react';
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import { useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import {
  LayoutDashboard,
  Users,
  Store,
  ClipboardList,
  Building2,
  Hotel,
  Car,
  TreePalm,
  Tags,
  CalendarCheck,
  MapPin,
  CreditCard,
  FileText,
  Wallet,
  Percent,
  Contact,
  BarChart3,
  Phone,
  MessageSquare,
  Image,
  Bell,
  Settings,
  Shield,
  Menu,
  X,
} from 'lucide-react';
import { clearSession, getDeskCountry, getUser, isSuperAdmin, setDeskCountry } from '@/lib/auth';
import { COUNTRIES, countryName } from '@/lib/countries';
import { loadAppCurrency } from '@/lib/currency';
import { Button } from '@/components/ui/button';
import { LanguageSwitch } from '@/components/LanguageSwitch';
import { cn } from '@/lib/utils';

const groups = [
  {
    label: 'navGroup.overview',
    items: [{ to: '/', key: 'nav.dashboard', icon: LayoutDashboard }],
  },
  {
    label: 'navGroup.people',
    items: [
      { to: '/customers', key: 'nav.customers', icon: Users },
      { to: '/vendors', key: 'nav.vendors', icon: Store },
      { to: '/staff', key: 'nav.staff', icon: Shield, superOnly: true },
    ],
  },
  {
    label: 'navGroup.supply',
    items: [
      { to: '/listings', key: 'nav.listings', icon: ClipboardList },
      { to: '/venues', key: 'nav.venues', icon: Building2 },
      { to: '/accommodations', key: 'nav.accommodations', icon: Hotel },
      { to: '/cars', key: 'nav.cars', icon: Car },
      { to: '/honeymoon', key: 'nav.honeymoon', icon: TreePalm },
      { to: '/event-categories', key: 'nav.eventCategories', icon: Tags, superOnly: true },
      { to: '/service-categories', key: 'nav.serviceCategories', icon: Tags, superOnly: true },
    ],
  },
  {
    label: 'navGroup.operations',
    items: [
      { to: '/bookings', key: 'nav.bookings', icon: CalendarCheck },
      { to: '/venue-visits', key: 'nav.visits', icon: MapPin },
      { to: '/crm', key: 'nav.crm', icon: Contact },
      { to: '/messages', key: 'nav.messages', icon: MessageSquare },
      { to: '/calls', key: 'nav.calls', icon: Phone },
    ],
  },
  {
    label: 'navGroup.finance',
    items: [
      { to: '/payments', key: 'nav.payments', icon: CreditCard },
      { to: '/invoices', key: 'nav.invoices', icon: FileText },
      { to: '/payouts', key: 'nav.payouts', icon: Wallet },
      { to: '/commissions', key: 'nav.commissions', icon: Percent },
      { to: '/reports', key: 'nav.reports', icon: BarChart3 },
    ],
  },
  {
    label: 'navGroup.platform',
    items: [
      { to: '/banners', key: 'nav.banners', icon: Image, superOnly: true },
      { to: '/notifications', key: 'nav.notifications', icon: Bell, superOnly: true },
      { to: '/settings', key: 'nav.settings', icon: Settings, superOnly: true },
    ],
  },
];

export function AdminLayout() {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  const qc = useQueryClient();
  const user = getUser();
  const superAdmin = isSuperAdmin();
  const rtl = i18n.language.startsWith('ar');
  const countryLabel = (user?.allowedCountries ?? []).map((code) => countryName(code)).join(', ');
  const [desk, setDesk] = useState<string | null>(() => (superAdmin ? getDeskCountry() : user?.allowedCountries[0] ?? null));
  const [menuOpen, setMenuOpen] = useState(false);
  const visibleGroups = groups
    .map((group) => ({
      ...group,
      items: group.items.filter((item) => !('superOnly' in item && item.superOnly) || superAdmin),
    }))
    .filter((group) => group.items.length > 0);

  useEffect(() => {
    void loadAppCurrency(desk);
  }, [desk]);

  useEffect(() => {
    setMenuOpen(false);
  }, [location.pathname]);

  useEffect(() => {
    if (!menuOpen) return;
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') setMenuOpen(false);
    };
    document.body.style.overflow = 'hidden';
    window.addEventListener('keydown', onKey);
    return () => {
      document.body.style.overflow = '';
      window.removeEventListener('keydown', onKey);
    };
  }, [menuOpen]);

  function changeDesk(code: string) {
    const next = code || null;
    setDeskCountry(next);
    setDesk(next);
    void loadAppCurrency(next);
    void qc.invalidateQueries();
  }

  return (
    <div className="min-h-screen overflow-x-hidden bg-[#f5f7fa]" dir={rtl ? 'rtl' : 'ltr'}>
      {menuOpen ? (
        <button
          type="button"
          aria-label={t('layout.closeMenu')}
          className="fixed inset-0 z-40 bg-black/50 lg:hidden"
          onClick={() => setMenuOpen(false)}
        />
      ) : null}
      <aside
        className={cn(
          'fixed inset-y-0 start-0 z-50 flex w-72 max-w-[85vw] flex-col bg-[#003580] text-white shadow-2xl transition-transform duration-200 lg:w-64 lg:max-w-none lg:translate-x-0 lg:rtl:translate-x-0',
          menuOpen ? 'translate-x-0' : '-translate-x-full rtl:translate-x-full',
        )}
      >
        <div className="flex items-start justify-between gap-3 border-b border-white/10 px-5 py-5">
          <div>
            <img src="/mark.png" alt="Zaya Events" className="mb-3 h-11 w-11 rounded-xl object-cover" />
            <p className="text-lg font-extrabold">{t('app.name')}</p>
            <p className="mt-1 text-xs text-white/70">{t('layout.console')}</p>
          </div>
          <Button
            type="button"
            variant="ghost"
            size="sm"
            className="text-white hover:bg-white/10 lg:hidden"
            onClick={() => setMenuOpen(false)}
            aria-label={t('layout.closeMenu')}
          >
            <X className="h-5 w-5" />
          </Button>
        </div>
        <nav className="flex-1 overflow-y-auto px-3 py-4">
          {visibleGroups.map((group) => (
            <div key={group.label} className="mb-5">
              <p className="px-3 pb-2 text-[11px] font-semibold uppercase tracking-wider text-white/50">{t(group.label)}</p>
              <div className="grid gap-0.5">
                {group.items.map((link) => {
                  const Icon = link.icon;
                  return (
                    <NavLink
                      key={link.to}
                      to={link.to}
                      end={link.to === '/'}
                      onClick={() => setMenuOpen(false)}
                      className={({ isActive }) =>
                        cn(
                          'flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-white/85 hover:bg-white/10',
                          isActive && 'bg-[#0071c2] font-semibold text-white',
                        )
                      }
                    >
                      <Icon className="h-4 w-4 shrink-0 opacity-90" />
                      {t(link.key)}
                    </NavLink>
                  );
                })}
              </div>
            </div>
          ))}
        </nav>
      </aside>
      <div className="min-w-0 lg:ps-64">
        <header className="sticky top-0 z-30 border-b bg-white/90 backdrop-blur">
          <div className="flex flex-col gap-3 px-4 py-3 sm:flex-row sm:items-center sm:justify-between lg:px-6">
            <div className="flex min-w-0 items-center gap-3">
              <Button
                type="button"
                variant="outline"
                size="sm"
                className="shrink-0 lg:hidden"
                onClick={() => setMenuOpen(true)}
                aria-label={t('layout.menu')}
              >
                <Menu className="h-4 w-4" />
              </Button>
              <div className="min-w-0">
                <p className="truncate text-sm font-semibold">
                  {user?.firstName} {user?.lastName}
                </p>
                <p className="truncate text-xs text-muted-foreground">
                  {superAdmin ? t('staff.super') : countryLabel ? `${t('staff.country')} · ${countryLabel}` : t('staff.country')}
                </p>
              </div>
            </div>
            <div className="flex min-w-0 flex-wrap items-center gap-2 sm:justify-end">
              {superAdmin ? (
                <select
                  className="h-9 max-w-full min-w-0 flex-1 rounded-md border px-2 text-sm sm:max-w-[12rem] sm:flex-none"
                  value={desk ?? ''}
                  onChange={(event) => changeDesk(event.target.value)}
                >
                  <option value="">{t('staff.allCountries')}</option>
                  {COUNTRIES.map((row) => (
                    <option key={row.code} value={row.code}>
                      {countryName(row.code)}
                    </option>
                  ))}
                </select>
              ) : null}
              <LanguageSwitch />
              <Button
                variant="ghost"
                size="sm"
                onClick={() => {
                  clearSession();
                  navigate('/login');
                }}
              >
                {t('auth.logout')}
              </Button>
            </div>
          </div>
          {(superAdmin ? desk : countryLabel) ? (
            <div className="bg-[#003580] px-4 py-2 text-sm font-semibold text-white lg:px-6">
              {t('staff.viewingDesk', { country: superAdmin && desk ? countryName(desk) : countryLabel })}
            </div>
          ) : null}
        </header>
        <main className="min-w-0 p-4 lg:p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
