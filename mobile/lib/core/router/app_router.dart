import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import '../../features/cart/cart_page.dart';
import '../../features/calls/domain/entities/call_entity.dart';
import '../../features/calls/presentation/pages/active_call_page.dart';
import '../../features/calls/presentation/pages/call_history_page.dart';
import '../../features/calls/presentation/pages/incoming_call_page.dart';
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
import '../../features/intro/intro_page.dart';
import '../../features/intro/intro_prefs.dart';
import '../../features/honeymoon/presentation/pages/honeymoon_detail_page.dart';
import '../../features/honeymoon/presentation/pages/honeymoon_list_page.dart';
import '../../features/hotels/presentation/pages/hotels_detail_page.dart';
import '../../features/hotels/presentation/pages/hotels_list_page.dart';
import '../../features/listings/presentation/pages/listing_editor_page.dart';
import '../../features/listings/presentation/pages/listings_detail_page.dart';
import '../../features/listings/presentation/pages/listings_list_page.dart';
import '../../features/payments/payment_checkout_args.dart';
import '../../features/payments/presentation/pages/customer_payments_page.dart';
import '../../features/payments/presentation/pages/payment_checkout_page.dart';
import '../../features/vendor_catalog/pages/vendor_catalog_page.dart';
import '../../features/vendor_catalog/pages/vendor_product_editor_page.dart';
import '../../features/vendor_catalog/vendor_catalog_kind.dart';
import '../../features/packages/presentation/pages/vendor_packages_page.dart';
import '../../features/notifications/presentation/pages/notifications_list_page.dart';
import '../../features/profile/presentation/pages/profile_edit_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/vendor_dashboard/presentation/pages/vendor_bookings_history_page.dart';
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

  static String? _sameOrGo(String loc, String target) =>
      loc == target ? null : target;

  static final router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
    redirect: (context, state) {
      final auth = sl<AuthBloc>().state;
      final loc = state.matchedLocation;
      final onIntro = loc.startsWith('/intro');
      final onCallScreen =
          loc.startsWith('/calls/incoming') ||
          loc.startsWith('/calls/active') ||
          loc.startsWith('/calls/outgoing');
      final loggingIn =
          loc.startsWith('/login') ||
          loc.startsWith('/register') ||
          loc.startsWith('/forgot') ||
          loc.startsWith('/reset') ||
          onIntro;
      final introDone = IntroPrefs.seen(sl<SharedPreferences>());
      return auth.maybeWhen(
        unknown: () => (loggingIn || onCallScreen) ? null : _sameOrGo(loc, '/login'),
        unauthenticated: (_) {
          if (onCallScreen) {
            return null;
          }
          if (!introDone && !onIntro) {
            return _sameOrGo(loc, '/intro');
          }
          return loggingIn ? null : _sameOrGo(loc, '/login');
        },
        busy: () => null,
        adminRedirect: (_) =>
            loc == '/admin-redirect' ? null : '/admin-redirect',
        authenticated: (user) {
          final role = parseAppRole(user.role);
          if (!introDone && !onIntro) {
            return _sameOrGo(loc, '/intro');
          }
          if (onIntro) {
            return null;
          }
          if (role == AppRole.customer &&
              !loc.startsWith('/customer') &&
              !_shared(loc)) {
            return _sameOrGo(loc, '/customer/home');
          }
          if (role == AppRole.vendor &&
              !loc.startsWith('/vendor') &&
              !_shared(loc)) {
            return _sameOrGo(loc, '/vendor/dashboard');
          }
          if (role == AppRole.customer && loc.startsWith('/vendor')) {
            return _sameOrGo(loc, '/customer/home');
          }
          if (role == AppRole.vendor && loc.startsWith('/customer')) {
            return _sameOrGo(loc, '/vendor/dashboard');
          }
          if (role == AppRole.vendor && isCustomerOnlyAppRoute(loc)) {
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
        path: '/intro',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const IntroPage(),
      ),
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
        builder: (c, s) =>
            ResetPasswordPage(token: s.uri.queryParameters['token'] ?? ''),
      ),
      GoRoute(
        path: '/admin-redirect',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const AdminRedirectPage(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const SettingsPage(),
      ),
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
        path: '/calls/incoming',
        parentNavigatorKey: rootKey,
        builder: (c, s) {
          final extra = s.extra;
          return IncomingCallPage(call: extra is CallEntity ? extra : null);
        },
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
          GoRoute(
            path: '/customer/home',
            builder: (c, s) => const CustomerHomePage(),
          ),
          GoRoute(
            path: '/customer/bookings',
            builder: (c, s) => const BookingsListPage(),
          ),
          GoRoute(
            path: '/customer/chat',
            builder: (c, s) => const ChatInboxPage(),
          ),
          GoRoute(
            path: '/customer/favorites',
            builder: (c, s) => const FavoritesListPage(),
          ),
          GoRoute(
            path: '/customer/profile',
            builder: (c, s) => const ProfilePage(),
          ),
          GoRoute(
            path: '/vendor/dashboard',
            builder: (c, s) => const VendorDashboardPage(),
          ),
          GoRoute(
            path: '/vendor/listings',
            builder: (c, s) => const VendorCatalogPage(),
          ),
          GoRoute(
            path: '/vendor/requests',
            builder: (c, s) => const BookingRequestsPage(),
          ),
          GoRoute(
            path: '/vendor/chat',
            builder: (c, s) => const ChatInboxPage(),
          ),
          GoRoute(
            path: '/vendor/profile',
            builder: (c, s) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/customer/venues',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const VenuesListPage(),
      ),
      GoRoute(
        path: '/venues/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => VenuesDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/customer/vendors',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const VendorsListPage(),
      ),
      GoRoute(
        path: '/vendors_browse/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => VendorsDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/customer/cars',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const CarsListPage(),
      ),
      GoRoute(
        path: '/cars/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => CarsDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/customer/stays',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const AccommodationsListPage(),
      ),
      GoRoute(
        path: '/accommodations/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) =>
            AccommodationsDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/customer/honeymoon',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const HoneymoonListPage(),
      ),
      GoRoute(
        path: '/honeymoon/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => HoneymoonDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/customer/flights',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const FlightsListPage(),
      ),
      GoRoute(
        path: '/flights/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => FlightsDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/customer/hotels',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const HotelsListPage(),
      ),
      GoRoute(
        path: '/hotels/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => HotelsDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/customer/events',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const EventsListPage(),
      ),
      GoRoute(
        path: '/bookings/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => BookingsDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/customer/visits',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const VisitsListPage(),
      ),
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
      GoRoute(
        path: '/customer/ai',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const AiPlannerPage(),
      ),
      GoRoute(
        path: '/customer/listings',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const ListingsListPage(),
      ),
      GoRoute(
        path: '/listings/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => ListingsDetailPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/customer/payments',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const CustomerPaymentsPage(),
      ),
      GoRoute(
        path: '/payments/checkout',
        parentNavigatorKey: rootKey,
        builder: (c, s) {
          final extra = s.extra;
          if (extra is PaymentCheckoutArgs) {
            return PaymentCheckoutPage(args: extra);
          }
          return const PaymentCheckoutPage(
            args: PaymentCheckoutArgs(
              bookingId: '',
              paymentId: '',
              clientSecret: '',
              publishableKey: '',
              amount: 0,
              currency: 'AED',
              kind: 'DEPOSIT',
            ),
          );
        },
      ),
      GoRoute(
        path: '/customer/cart',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const CartPage(),
      ),
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
        path: '/vendor/venues/new',
        parentNavigatorKey: rootKey,
        builder: (c, s) =>
            const VendorProductEditorPage(kind: VendorCatalogKind.venue),
      ),
      GoRoute(
        path: '/vendor/venues/edit/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => VendorProductEditorPage(
          kind: VendorCatalogKind.venue,
          id: s.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/vendor/cars/new',
        parentNavigatorKey: rootKey,
        builder: (c, s) =>
            const VendorProductEditorPage(kind: VendorCatalogKind.car),
      ),
      GoRoute(
        path: '/vendor/cars/edit/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => VendorProductEditorPage(
          kind: VendorCatalogKind.car,
          id: s.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/vendor/stays/new',
        parentNavigatorKey: rootKey,
        builder: (c, s) =>
            const VendorProductEditorPage(kind: VendorCatalogKind.stay),
      ),
      GoRoute(
        path: '/vendor/stays/edit/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => VendorProductEditorPage(
          kind: VendorCatalogKind.stay,
          id: s.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/vendor/honeymoon/new',
        parentNavigatorKey: rootKey,
        builder: (c, s) =>
            const VendorProductEditorPage(kind: VendorCatalogKind.honeymoon),
      ),
      GoRoute(
        path: '/vendor/honeymoon/edit/:id',
        parentNavigatorKey: rootKey,
        builder: (c, s) => VendorProductEditorPage(
          kind: VendorCatalogKind.honeymoon,
          id: s.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/vendor/bookings',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const VendorBookingsHistoryPage(),
      ),
      GoRoute(
        path: '/vendor/visits',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const VisitsListPage(),
      ),
      GoRoute(
        path: '/vendor/calendar',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const AvailabilityCalendarPage(),
      ),
      GoRoute(
        path: '/vendor/packages',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const VendorPackagesPage(),
      ),
      GoRoute(
        path: '/vendor/earnings',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const VendorEarningsPage(),
      ),
      GoRoute(
        path: '/vendor/reviews',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const VendorReviewsPage(),
      ),
      GoRoute(
        path: '/vendor/business',
        parentNavigatorKey: rootKey,
        builder: (c, s) => const VendorBusinessProfilePage(),
      ),
    ],
  );

  static bool _shared(String loc) => isSharedAppRoute(loc);
}

/// Detail and tool screens that both customers and vendors may open.
bool isSharedAppRoute(String loc) {
  const prefixes = [
    '/settings',
    '/notifications',
    '/profile',
    '/calls',
    '/chat',
    '/venues',
    '/cars',
    '/hotels',
    '/flights',
    '/bookings',
    '/accommodations',
    '/honeymoon',
    '/vendors_browse',
    '/venue_visits',
    '/events',
    '/listings',
    '/payments',
  ];
  return prefixes.any(loc.startsWith);
}

/// Pay, cart, and event planning stay on the customer account only.
bool isCustomerOnlyAppRoute(String loc) {
  const prefixes = ['/payments', '/events'];
  return prefixes.any(loc.startsWith);
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
