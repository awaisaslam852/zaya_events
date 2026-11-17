import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { QueryClientProvider } from '@tanstack/react-query';
import { Toaster } from 'sonner';
import { queryClient } from '@/lib/query';
import { RequireAdmin, RequireSuperAdmin } from '@/components/RequireAdmin';
import { LoginPage } from '@/pages/LoginPage';
import { DashboardPage } from '@/pages/DashboardPage';
import { CustomersPage } from '@/pages/CustomersPage';
import { CustomerDetailPage } from '@/pages/CustomerDetailPage';
import { VendorsPage } from '@/pages/VendorsPage';
import { VendorDetailPage } from '@/pages/VendorDetailPage';
import { VenuesPage } from '@/pages/VenuesPage';
import { AccommodationsPage } from '@/pages/AccommodationsPage';
import { CarsPage } from '@/pages/CarsPage';
import { HoneymoonPage } from '@/pages/HoneymoonPage';
import { EventCategoriesPage, ServiceCategoriesPage } from '@/pages/CategoriesPage';
import { ListingsPage } from '@/pages/ListingsPage';
import {
  CarDetailPage,
  HoneymoonDetailPage,
  ListingDetailPage,
  StayDetailPage,
  VenueDetailPage,
} from '@/pages/CatalogDetailPage';
import { BookingsPage } from '@/pages/BookingsPage';
import { BookingDetailPage } from '@/pages/BookingDetailPage';
import { VenueVisitsPage } from '@/pages/VenueVisitsPage';
import { PaymentsPage } from '@/pages/PaymentsPage';
import { InvoicesPage } from '@/pages/InvoicesPage';
import { PayoutsPage } from '@/pages/PayoutsPage';
import { CommissionsPage } from '@/pages/CommissionsPage';
import { CrmPage } from '@/pages/CrmPage';
import { MessagesPage } from '@/pages/MessagesPage';
import { ReportsPage } from '@/pages/ReportsPage';
import { CallsPage } from '@/pages/CallsPage';
import { BannersPage } from '@/pages/BannersPage';
import { NotificationsPage } from '@/pages/NotificationsPage';
import { SettingsPage } from '@/pages/SettingsPage';
import { StaffPage } from '@/pages/StaffPage';
import { StaffDetailPage } from '@/pages/StaffDetailPage';

export function App(): JSX.Element {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route element={<RequireAdmin />}>
            <Route path="/" element={<DashboardPage />} />
            <Route path="/customers" element={<CustomersPage />} />
            <Route path="/customers/:id" element={<CustomerDetailPage />} />
            <Route path="/vendors" element={<VendorsPage />} />
            <Route path="/vendors/:id" element={<VendorDetailPage />} />
            <Route path="/listings" element={<ListingsPage />} />
            <Route path="/listings/:id" element={<ListingDetailPage />} />
            <Route path="/venues" element={<VenuesPage />} />
            <Route path="/venues/:id" element={<VenueDetailPage />} />
            <Route path="/accommodations" element={<AccommodationsPage />} />
            <Route path="/accommodations/:id" element={<StayDetailPage />} />
            <Route path="/cars" element={<CarsPage />} />
            <Route path="/cars/:id" element={<CarDetailPage />} />
            <Route path="/honeymoon" element={<HoneymoonPage />} />
            <Route path="/honeymoon/:id" element={<HoneymoonDetailPage />} />
            <Route path="/staff" element={<RequireSuperAdmin><StaffPage /></RequireSuperAdmin>} />
            <Route path="/staff/:id" element={<RequireSuperAdmin><StaffDetailPage /></RequireSuperAdmin>} />
            <Route path="/event-categories" element={<RequireSuperAdmin><EventCategoriesPage /></RequireSuperAdmin>} />
            <Route path="/service-categories" element={<RequireSuperAdmin><ServiceCategoriesPage /></RequireSuperAdmin>} />
            <Route path="/bookings" element={<BookingsPage />} />
            <Route path="/bookings/:id" element={<BookingDetailPage />} />
            <Route path="/venue-visits" element={<VenueVisitsPage />} />
            <Route path="/payments" element={<PaymentsPage />} />
            <Route path="/invoices" element={<InvoicesPage />} />
            <Route path="/payouts" element={<PayoutsPage />} />
            <Route path="/commissions" element={<CommissionsPage />} />
            <Route path="/crm" element={<CrmPage />} />
            <Route path="/messages" element={<MessagesPage />} />
            <Route path="/reports" element={<ReportsPage />} />
            <Route path="/calls" element={<CallsPage />} />
            <Route path="/banners" element={<RequireSuperAdmin><BannersPage /></RequireSuperAdmin>} />
            <Route path="/notifications" element={<RequireSuperAdmin><NotificationsPage /></RequireSuperAdmin>} />
            <Route path="/settings" element={<RequireSuperAdmin><SettingsPage /></RequireSuperAdmin>} />
          </Route>
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
      <Toaster richColors position="top-center" />
    </QueryClientProvider>
  );
}
