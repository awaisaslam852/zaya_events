import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/app_role.dart';
import '../di/injection.dart';
import '../shells/customer_shell.dart';
import '../shells/vendor_shell.dart';
import '../../features/accommodations/presentation/pages/accommodations_detail_page.dart';
import '../../features/accommodations/presentation/pages/accommodations_list_page.dart';
import '../../features/ai_planner/presentation/pages/ai_planner_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/admin_redirect_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/password_pages.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/availability_calendar/presentation/pages/availability_calendar_page.dart';
import '../../features/booking_requests/presentation/pages/booking_requests_page.dart';
import '../../features/bookings/presentation/pages/bookings_detail_page.dart';
import '../../features/bookings/presentation/pages/bookings_list_page.dart';
import '../../features/calls/presentation/pages/active_call_page.dart';
import '../../features/calls/presentation/pages/call_history_page.dart';
import '../../features/calls/presentation/pages/outgoing_call_page.dart';
import '../../features/cars/presentation/pages/cars_detail_page.dart';
import '../../features/cars/presentation/pages/cars_list_page.dart';
import '../../features/chat/presentation/pages/chat_inbox_page.dart';
import '../../features/chat/presentation/pages/chat_thread_page.dart';
import '../../features/events/presentation/pages/event_editor_page.dart';
import '../../features/events/presentation/pages/events_detail_page.dart';
import '../../features/events/presentation/pages/events_list_page.dart';
import '../../features/favorites/presentation/pages/favorites_list_page.dart';
import '../../features/flights/presentation/pages/flights_detail_page.dart';
import '../../features/flights/presentation/pages/flights_list_page.dart';
import '../../features/home/presentation/pages/customer_home_page.dart';
import '../../features/honeymoon/presentation/pages/honeymoon_detail_page.dart';
import '../../features/honeymoon/presentation/pages/honeymoon_list_page.dart';
import '../../features/hotels/presentation/pages/hotels_detail_page.dart';
import '../../features/hotels/presentation/pages/hotels_list_page.dart';
import '../../features/listings/presentation/pages/listing_editor_page.dart';
import '../../features/listings/presentation/pages/vendor_listings_page.dart';
import '../../features/packages/presentation/pages/vendor_packages_page.dart';
import '../../features/notifications/presentation/pages/notifications_list_page.dart';
import '../../features/profile/presentation/pages/profile_edit_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/vendor_dashboard/presentation/pages/vendor_dashboard_page.dart';
import '../../features/vendor_dashboard/presentation/pages/vendor_extra_pages.dart';
import '../../features/vendors_browse/presentation/pages/vendors_detail_page.dart';
import '../../features/vendors_browse/presentation/pages/vendors_list_page.dart';
import '../../features/venue_visits/presentation/pages/visits_detail_page.dart';
import '../../features/venue_visits/presentation/pages/visits_list_page.dart';
import '../../features/venues/presentation/pages/venues_detail_page.dart';
import '../../features/venues/presentation/pages/venues_list_page.dart';

class AppRouter {
  static final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final _tabsKey = GlobalKey<NavigatorState>(debugLabel: 'tabs');

  static AppRole? roleOf(AuthState state) {
    return state.maybeWhen(
      authenticated: (user) => parseAppRole(user.role),
      adminRedirect: (user) => parseAppRole(user.role),
      orElse: () => null,
    );
  }

  static String? _sameOrGo(String loc, String target) => loc == target ? null : target;

  static final router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
    redirect: (context, state) {
      final auth = sl<AuthBloc>().state;
      final loc = state.matchedLocation;
      final loggingIn = loc.startsWith('/login') ||
          loc.startsWith('/register') ||
          loc.startsWith('/forgot') ||
          loc.startsWith('/reset');
      return auth.maybeWhen(
        unknown: () => loggingIn ? null : _sameOrGo(loc, '/login'),
        unauthenticated: (_) => loggingIn ? null : _sameOrGo(loc, '/login'),
        busy: () => null,
        adminRedirect: (_) => loc == '/admin-redirect' ? null : '/admin-redirect',
        authenticated: (user) {
          final role = parseAppRole(user.role);
          if (role == AppRole.customer && !loc.startsWith('/customer') && !_shared(loc)) {
            return _sameOrGo(loc, '/customer/home');
          }
          if (role == AppRole.vendor && !loc.startsWith('/vendor') && !_shared(loc)) {
            return _sameOrGo(loc, '/vendor/dashboard');
          }
          if (role == AppRole.customer && loc.startsWith('/vendor')) {
            return _sameOrGo(loc, '/customer/home');
          }
          if (role == AppRole.vendor && loc.startsWith('/customer')) {
            return _sameOrGo(loc, '/vendor/dashboard');
          }
          if (loggingIn) {
            return _sameOrGo(
              loc,
              role == AppRole.vendor ? '/vendor/dashboard' : '/customer/home',
            );
          }
          return null;
        },
        orElse: () => _sameOrGo(loc, '/login'),
      );
    },
    routes: [
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        parentNavigatorKey: rootKey,
        builder: (c, s) => ResetPasswordPage(token: s.uri.queryParameters['token'] ?? ''),
      ),
      GoRoute(
        path: '/admin-redirect',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const AdminRedirectPage(),
      ),
      GoRoute(path: '/settings', parentNavigatorKey: rootKey, builder: (c, s) => const SettingsPage()),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const NotificationsListPage(),
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const ProfileEditPage(),
      ),
      GoRoute(
        path: '/calls/history',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const CallHistoryPage(),
      ),
      GoRoute(
        path: '/calls/outgoing',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const OutgoingCallPage(),
      ),
      GoRoute(
        path: '/calls/active/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => ActiveCallPage(callId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chat/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => ChatThreadPage(id: s.pathParameters['id']!),
      ),
      ShellRoute(
        navigatorKey: _tabsKey,
        parentNavigatorKey: rootKey,
        builder: (context, state, child) {
          final loc = state.uri.path;
          if (loc.startsWith('/vendor')) {
            return VendorShell(child: child);
          }
          return CustomerShell(child: child);
        },
        routes: [
          GoRoute(path: '/customer/home', builder: (c, s) => const CustomerHomePage()),
          GoRoute(path: '/customer/events', builder: (c, s) => const EventsListPage()),
          GoRoute(path: '/customer/chat', builder: (c, s) => const ChatInboxPage()),
          GoRoute(path: '/customer/favorites', builder: (c, s) => const FavoritesListPage()),
          GoRoute(path: '/customer/profile', builder: (c, s) => const ProfilePage()),
          GoRoute(path: '/vendor/dashboard', builder: (c, s) => const VendorDashboardPage()),
          GoRoute(path: '/vendor/listings', builder: (c, s) => const VendorListingsPage()),
          GoRoute(path: '/vendor/requests', builder: (c, s) => const BookingRequestsPage()),
          GoRoute(path: '/vendor/chat', builder: (c, s) => const ChatInboxPage()),
          GoRoute(path: '/vendor/profile', builder: (c, s) => const ProfilePage()),
        ],
      ),
      GoRoute(path: '/customer/venues', parentNavigatorKey: rootKey, builder: (c, s) => const VenuesListPage()),
      GoRoute(
        path: '/venues/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => VenuesDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(path: '/customer/vendors', parentNavigatorKey: rootKey, builder: (c, s) => const VendorsListPage()),
      GoRoute(
        path: '/vendors_browse/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => VendorsDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(path: '/customer/cars', parentNavigatorKey: rootKey, builder: (c, s) => const CarsListPage()),
      GoRoute(
        path: '/cars/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => CarsDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(path: '/customer/stays', parentNavigatorKey: rootKey, builder: (c, s) => const AccommodationsListPage()),
      GoRoute(
        path: '/accommodations/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => AccommodationsDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(path: '/customer/honeymoon', parentNavigatorKey: rootKey, builder: (c, s) => const HoneymoonListPage()),
      GoRoute(
        path: '/honeymoon/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => HoneymoonDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(path: '/customer/flights', parentNavigatorKey: rootKey, builder: (c, s) => const FlightsListPage()),
      GoRoute(
        path: '/flights/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => FlightsDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(path: '/customer/hotels', parentNavigatorKey: rootKey, builder: (c, s) => const HotelsListPage()),
      GoRoute(
        path: '/hotels/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => HotelsDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(path: '/customer/bookings', parentNavigatorKey: rootKey, builder: (c, s) => const BookingsListPage()),
      GoRoute(
        path: '/bookings/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => BookingsDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(path: '/customer/visits', parentNavigatorKey: rootKey, builder: (c, s) => const VisitsListPage()),
      GoRoute(
        path: '/venue_visits/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => VisitsDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/events/:id/edit',
        parentNavigatorKey: rootKey,
        builder: (c, s) => EventEditorPage(id: s.pathParameters['id']),
      ),
      GoRoute(
        path: '/events/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => EventsDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/customer/event/new',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const EventEditorPage(),
      ),
      GoRoute(path: '/customer/ai', parentNavigatorKey: rootKey, builder: (c, s) => const AiPlannerPage()),
      GoRoute(
        path: '/vendor/listing/new',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const ListingEditorPage(),
      ),
      GoRoute(
        path: '/vendor/listing/edit/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => ListingEditorPage(id: s.pathParameters['id']),
      ),
      GoRoute(
        path: '/vendor/calendar',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const AvailabilityCalendarPage(),
      ),
      GoRoute(path: '/vendor/packages', parentNavigatorKey: rootKey, builder: (c, s) => const VendorPackagesPage()),
      GoRoute(path: '/vendor/reviews', parentNavigatorKey: rootKey, builder: (c, s) => const VendorReviewsPage()),
      GoRoute(
        path: '/vendor/business',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const VendorBusinessProfilePage(),
      ),
    ],
  );

  static bool _shared(String loc) {
    return loc.startsWith('/settings') ||
        loc.startsWith('/notifications') ||
        loc.startsWith('/profile') ||
        loc.startsWith('/calls') ||
        loc.startsWith('/chat') ||
        loc.startsWith('/venues') ||
        loc.startsWith('/cars') ||
        loc.startsWith('/hotels') ||
        loc.startsWith('/flights');
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

    late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
