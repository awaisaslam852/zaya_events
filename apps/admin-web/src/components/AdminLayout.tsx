import { useEffect } from 'react';
import { NavLink, Outlet, useNavigate } from 'react-router-dom';
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
} from 'lucide-react';
import { clearSession, getUser } from '@/lib/auth';
import { loadAppCurrency } from '@/lib/currency';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

const groups = [
  {
    label: 'Overview',
    items: [{ to: '/', key: 'nav.dashboard', icon: LayoutDashboard }],
  },
  {
    label: 'People',
    items: [
      { to: '/customers', key: 'nav.customers', icon: Users },
      { to: '/vendors', key: 'nav.vendors', icon: Store },
    ],
  },
  {
    label: 'Supply',
    items: [
      { to: '/listings', key: 'nav.listings', icon: ClipboardList },
      { to: '/venues', key: 'nav.venues', icon: Building2 },
      { to: '/accommodations', key: 'nav.accommodations', icon: Hotel },
      { to: '/cars', key: 'nav.cars', icon: Car },
      { to: '/honeymoon', key: 'nav.honeymoon', icon: TreePalm },
      { to: '/event-categories', key: 'nav.eventCategories', icon: Tags },
      { to: '/service-categories', key: 'nav.serviceCategories', icon: Tags },
    ],
  },
  {
    label: 'Operations',
    items: [
      { to: '/bookings', key: 'nav.bookings', icon: CalendarCheck },
      { to: '/venue-visits', key: 'nav.visits', icon: MapPin },
      { to: '/crm', key: 'nav.crm', icon: Contact },
      { to: '/messages', key: 'nav.messages', icon: MessageSquare },
      { to: '/calls', key: 'nav.calls', icon: Phone },
    ],
  },
  {
    label: 'Finance',
    items: [
      { to: '/payments', key: 'nav.payments', icon: CreditCard },
      { to: '/invoices', key: 'nav.invoices', icon: FileText },
      { to: '/payouts', key: 'nav.payouts', icon: Wallet },
      { to: '/commissions', key: 'nav.commissions', icon: Percent },
      { to: '/reports', key: 'nav.reports', icon: BarChart3 },
    ],
  },
  {
    label: 'Platform',
    items: [
      { to: '/banners', key: 'nav.banners', icon: Image },
      { to: '/notifications', key: 'nav.notifications', icon: Bell },
      { to: '/settings', key: 'nav.settings', icon: Settings },
    ],
  },
];

export function AdminLayout() {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const user = getUser();
  const rtl = i18n.language.startsWith('ar');

  useEffect(() => {
    void loadAppCurrency();
  }, []);

  return (
    <div className="min-h-screen bg-[#f5f7fa]" dir={rtl ? 'rtl' : 'ltr'}>
      <aside className="fixed inset-y-0 start-0 z-40 flex w-64 flex-col bg-[#003580] text-white">
        <div className="border-b border-white/10 px-5 py-5">
          <p className="text-xs font-semibold uppercase tracking-[0.2em] text-[#FEBB02]">Zaya</p>
          <p className="text-lg font-extrabold">{t('app.name')}</p>
          <p className="mt-1 text-xs text-white/70">Operations console</p>
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
      <div className="ps-64">
        <header className="sticky top-0 z-30 flex items-center justify-between border-b bg-white/90 px-6 py-3 backdrop-blur">
          <div>
            <p className="text-sm font-semibold">
              {user?.firstName} {user?.lastName}
            </p>
            <p className="text-xs text-muted-foreground">Platform administrator</p>
          </div>
          <div className="flex gap-2">
            <Button variant="outline" size="sm" onClick={() => void i18n.changeLanguage(rtl ? 'en' : 'ar')}>
              {rtl ? 'English' : 'العربية'}
            </Button>
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
        </header>
        <main className="p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
