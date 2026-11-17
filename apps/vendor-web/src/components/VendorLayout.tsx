import { useEffect, useState } from 'react';
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
  LayoutDashboard,
  UserRound,
  Store,
  Car,
  CalendarRange,
  Inbox,
  Wallet,
  MessageCircle,
  Phone,
  Bell,
  Settings,
  Menu,
  X,
} from 'lucide-react';
import { clearSession, getUser } from '@/lib/auth';
import { loadAppCurrency } from '@/lib/currency';
import { Button } from '@/components/ui/button';
import { LanguageSwitch } from '@/components/LanguageSwitch';
import { cn } from '@/lib/utils';
import { IncomingCallHost } from '@/components/IncomingCallHost';

const groups = [
  {
    label: 'Overview',
    items: [{ to: '/', key: 'nav.dashboard', icon: LayoutDashboard }],
  },
  {
    label: 'Supply',
    items: [
      { to: '/profile', key: 'nav.profile', icon: UserRound },
      { to: '/listings', key: 'nav.listings', icon: Store },
      { to: '/cars', key: 'nav.cars', icon: Car },
      { to: '/availability', key: 'nav.availability', icon: CalendarRange },
    ],
  },
  {
    label: 'Operations',
    items: [
      { to: '/bookings', key: 'nav.bookings', icon: Inbox },
      { to: '/messages', key: 'nav.messages', icon: MessageCircle },
      { to: '/calls', key: 'nav.calls', icon: Phone },
    ],
  },
  {
    label: 'Account',
    items: [
      { to: '/earnings', key: 'nav.earnings', icon: Wallet },
      { to: '/notifications', key: 'nav.notifications', icon: Bell },
      { to: '/settings', key: 'nav.settings', icon: Settings },
    ],
  },
];

export function VendorLayout() {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  const user = getUser();
  const rtl = i18n.language.startsWith('ar');
  const [menuOpen, setMenuOpen] = useState(false);

  useEffect(() => {
    void loadAppCurrency(user?.country);
  }, []);

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

  return (
    <div className="min-h-screen overflow-x-hidden bg-[#f5f7fa]" dir={rtl ? 'rtl' : 'ltr'}>
      <IncomingCallHost />
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
          {groups.map((group) => (
            <div key={group.label} className="mb-5">
              <p className="px-3 pb-2 text-[11px] font-semibold uppercase tracking-wider text-white/50">{group.label}</p>
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
                <p className="truncate text-xs text-muted-foreground">{t('layout.partner')}</p>
              </div>
            </div>
            <div className="flex flex-wrap items-center gap-2 sm:justify-end">
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
        </header>
        <main className="min-w-0 p-4 lg:p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
