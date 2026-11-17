import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaya_events/core/auth/app_role.dart';
import 'package:zaya_events/core/auth/session_role.dart';
import 'package:zaya_events/core/router/app_router.dart';
import 'package:zaya_events/core/shells/nav_destinations.dart';
import 'package:zaya_events/features/cart/cart_totals.dart';
import 'package:zaya_events/core/i18n/app_languages.dart';
import 'package:zaya_events/core/utils/localized.dart';
import 'package:zaya_events/core/widgets/property_card.dart';
import 'package:zaya_events/core/widgets/zaya_avatar.dart';
import 'package:zaya_events/features/auth/domain/entities/user_entity.dart';
import 'package:zaya_events/features/vendor_catalog/vendor_catalog_kind.dart';
import 'package:zaya_events/core/utils/customer_hub.dart';
import 'package:zaya_events/features/home/data/banners_repository.dart';
import 'package:zaya_events/features/intro/intro_prefs.dart';
import 'package:zaya_events/features/notifications/presentation/cubit/unread_notifications_cubit.dart';
import 'package:zaya_events/features/intro/intro_slides.dart';
import 'package:zaya_events/features/payments/payment_checkout_args.dart';
import 'package:zaya_events/l10n/app_localizations_en.dart';
import 'package:zaya_events/features/vendor_dashboard/presentation/vendor_dashboard_metrics.dart';

void main() {
  test('parseAppRole maps backend roles', () {
    expect(parseAppRole('CUSTOMER'), AppRole.customer);
    expect(parseAppRole('vendor'), AppRole.vendor);
    expect(parseAppRole('ADMIN'), AppRole.admin);
  });

  test('localized prefers locale then English', () {
    expect(localized({'en': 'Hello', 'ar': 'مرحبا'}, 'ar'), 'مرحبا');
    expect(localized({'en': 'Hello'}, 'ar'), 'Hello');
    expect(localized({'en': 'Hello', 'ar': 'مرحبا'}, 'fr'), 'Hello');
  });

  test('profile image url uses avatar key then vendor logo', () {
    const withAvatar = UserEntity(
      id: '1',
      email: 'a@b.com',
      role: 'VENDOR',
      firstName: 'Insha',
      lastName: 'Awais',
      avatarKey: 'avatars/me.jpg',
    );
    expect(profileImageUrl(withAvatar), contains('avatars/me.jpg'));
    const withLogo = UserEntity(
      id: '1',
      email: 'a@b.com',
      role: 'VENDOR',
      firstName: 'Insha',
      lastName: 'Awais',
      vendor: {'logoKey': 'uploads/logo.png'},
    );
    expect(profileImageUrl(withLogo), contains('logo.png'));
    expect(profileInitials(withAvatar), 'IA');
  });

  test('catalog gallery payload clears cover when empty', () {
    expect(catalogGalleryPayload(const []), {'coverKey': '', 'galleryKeys': <String>[]});
    expect(catalogGalleryPayload(const ['a.jpg', 'b.jpg'])['coverKey'], 'a.jpg');
  });

  test('vendor catalog kinds map to editor routes', () {
    expect(VendorCatalogKind.listing.newPath, '/vendor/listing/new');
    expect(VendorCatalogKind.venue.editPath('abc'), '/vendor/venues/edit/abc');
    expect(vendorEditPathForResource('VENUE', 'abc'), '/vendor/venues/edit/abc');
    expect(vendorEditPathForResource('HOTEL', 'abc'), isNull);
    expect(VendorCatalogKind.stay.path, 'accommodations');
    expect(VendorCatalogKind.honeymoon.path, 'honeymoon');
    expect(VendorCatalogKind.all.isAggregate, isTrue);
    expect(VendorCatalogKind.sellable, isNot(contains(VendorCatalogKind.all)));
    expect(
      catalogKindOf({'_catalogKind': 'venue'}),
      VendorCatalogKind.venue,
    );
  });

  test('vendor dashboard metrics summarise bookings', () {
    const metrics = VendorDashboardMetrics(
      {
        'totals': {'total': 24800, 'deposits': 8000, 'balances': 16800},
        'bookings': [
          {'status': 'CONFIRMED', 'totalAmount': 12000, 'currency': 'AED'},
          {'status': 'INQUIRY', 'totalAmount': 4800, 'currency': 'AED'},
          {'status': 'PAID', 'totalAmount': 8000, 'currency': 'AED'},
        ],
      },
      {'ratingAvg': 4.8, 'ratingCount': 12, 'status': 'APPROVED'},
      null,
    );
    expect(metrics.bookingCount, 3);
    expect(metrics.pendingCount, 1);
    expect(metrics.confirmedCount, 2);
    expect(metrics.occupancy, '67%');
    expect(metrics.totalAmount, 24800);
    expect(metrics.isApproved, isTrue);
    expect(metrics.rating, '4.8 · 12');
  });

  test('cart totals sum unit amounts and deposit', () {
    const totals = CartTotals(
      items: [
        {'unitAmount': 1000, 'currency': 'AED'},
        {'unitAmount': 500, 'currency': 'AED'},
      ],
    );
    expect(totals.count, 2);
    expect(totals.subtotal, 1500);
    expect(totals.deposit, 450);
    expect(totals.currency, 'AED');
  });

  test('customer tabs use my bookings instead of events', () {
    expect(customerTabPaths, ['/customer/home', '/customer/bookings', '/customer/chat', '/customer/favorites', '/customer/profile']);
    expect(tabIndexForPath('/customer/bookings', customerTabPaths), 1);
    expect(tabIndexForPath('/customer/events', customerTabPaths), 0);
  });

  test('booking helpers expose title pay rules and money', () {
    expect(
      bookingTitleRaw({
        'venue': {
          'name': {'en': 'Garden hall'},
        },
        'bookingNumber': 'ZE-1',
      }),
      {'en': 'Garden hall'},
    );
    expect(
      bookingCanPay({'status': 'CONFIRMED', 'depositAmount': 300, 'balanceAmount': 700, 'payments': []}, 'DEPOSIT'),
      isTrue,
    );
    expect(
      bookingCanPay({
        'status': 'CONFIRMED',
        'depositAmount': 300,
        'balanceAmount': 700,
        'payments': [
          {'kind': 'DEPOSIT', 'status': 'SUCCEEDED', 'amount': 300},
        ],
      }, 'BALANCE'),
      isTrue,
    );
    expect(bookingCanPay({'status': 'CANCELLED', 'depositAmount': 300, 'payments': []}, 'DEPOSIT'), isFalse);
    expect(formatMoney(12000, 'AED'), 'AED 12,000');
    expect(bookingNeedsVendorDecision('CONFIRMED'), isFalse);
    expect(bookingNeedsVendorDecision('INQUIRY'), isTrue);
    expect(bookingNeedsVendorDecision('PENDING'), isTrue);
    expect(bookingNeedsVendorDecision('UNDER_REVIEW'), isTrue);
    expect(prettyEnumLabel('CONFIRMED'), 'Confirmed');
    expect(
      bookingChatPeerId({
        'vendor': {'userId': 'vendor-user'},
        'customer': {'id': 'customer-user'},
      }, 'customer-user'),
      'vendor-user',
    );
    expect(
      bookingChatPeerId({
        'vendor': {'userId': 'vendor-user'},
        'customerId': 'customer-user',
      }, 'vendor-user'),
      'customer-user',
    );
    expect(bookingHasAmount({'totalAmount': 0, 'balanceAmount': 0, 'payments': []}), isFalse);
    expect(bookingCanReview({'reviewState': {'canWrite': true}}), isTrue);
    expect(bookingCanReview({'reviewState': {'canWrite': false}}), isFalse);
    expect(bookingCanReview({'status': 'COMPLETED'}), isFalse);
  });

  test('payment checkout args require client secret and publishable key', () {
    final ready = PaymentCheckoutArgs.fromIntent(
      bookingId: 'b1',
      data: {
        'clientSecret': 'pi_test_secret',
        'publishableKey': 'pk_test_123',
        'payment': {'id': 'pay1', 'amount': 300, 'currency': 'AED', 'kind': 'DEPOSIT'},
      },
    );
    expect(ready.isReady, isTrue);
    expect(ready.paymentId, 'pay1');
    expect(
      PaymentCheckoutArgs.fromIntent(bookingId: 'b1', data: {'mock': true}).isReady,
      isFalse,
    );
    expect(isSharedAppRoute('/payments/checkout'), isTrue);
    expect(isCustomerOnlyAppRoute('/payments/checkout'), isTrue);
    expect(isCustomerOnlyAppRoute('/events/abc'), isTrue);
    expect(isCustomerOnlyAppRoute('/bookings/abc'), isFalse);
  });

  test('unread badge label hides zero and caps at 99+', () {
    expect(unreadBadgeLabel(0), '');
    expect(unreadBadgeLabel(3), '3');
    expect(unreadBadgeLabel(99), '99');
    expect(unreadBadgeLabel(120), '99+');
  });

  test('vendor dashboard banners reuse home placements', () {
    expect(BannersRepository.vendorPlacements, contains('VENDOR_DASHBOARD'));
    expect(BannersRepository.vendorPlacements, containsAll(BannersRepository.customerPlacements));
  });

  test('intro has four branded welcome slides', () {
    final slides = introSlides(AppLocalizationsEn());
    expect(slides, hasLength(4));
    expect(slides.first.title, 'Your event, one place');
    expect(IntroPrefs.key, 'intro_completed');
  });

  test('customer shared routes include bookings visits events and listings', () {
    expect(isSharedAppRoute('/bookings/abc'), isTrue);
    expect(isSharedAppRoute('/venue_visits/abc'), isTrue);
    expect(isSharedAppRoute('/events/abc'), isTrue);
    expect(isSharedAppRoute('/listings/abc'), isTrue);
    expect(isSharedAppRoute('/accommodations/abc'), isTrue);
    expect(isSharedAppRoute('/honeymoon/abc'), isTrue);
    expect(isSharedAppRoute('/vendors_browse/abc'), isTrue);
    expect(isSharedAppRoute('/vendor/dashboard'), isFalse);
    expect(isCustomerOnlyAppRoute('/payments/checkout'), isTrue);
    expect(isCustomerOnlyAppRoute('/bookings/abc'), isFalse);
  });

  test('catalog ownership matches vendor id or nested user', () {
    expect(
      catalogOwnedByViewer({'vendorId': 'v1'}, vendorId: 'v1'),
      isTrue,
    );
    expect(
      catalogOwnedByViewer({
        'vendor': {'id': 'v1'},
      }, vendorId: 'v1'),
      isTrue,
    );
    expect(
      catalogOwnedByViewer({
        'vendor': {'userId': 'u1'},
      }, userId: 'u1'),
      isTrue,
    );
    expect(
      catalogOwnedByViewer({'vendorId': 'v1'}, vendorId: 'other'),
      isFalse,
    );
  });

  test('favorite and notification destinations map resource types', () {
    expect(favoriteDestination({'resourceType': 'VENUE', 'resourceId': 'v1'}), '/venues/v1');
    expect(favoriteDestination({'resourceType': 'LISTING', 'resourceId': 'l1'}), '/listings/l1');
    expect(favoriteDestination({'resourceType': 'HONEYMOON', 'providerRef': 'h1'}), '/honeymoon/h1');
    expect(
      notificationDestination({
        'data': {'bookingId': 'b1'},
      }),
      '/bookings/b1',
    );
    expect(
      notificationDestination({
        'data': {'conversationId': 'c1'},
      }),
      '/chat/c1',
    );
    expect(notificationUnread({'readAt': null}), isTrue);
    expect(notificationUnread({'readAt': '2026-11-11T10:00:00Z'}), isFalse);
    final now = DateTime.now();
    expect(eventDaysFromNow(DateTime(now.year, now.month, now.day, 12).toIso8601String()), 0);
  });

  test('app languages resolve tags and device locales', () {
    expect(AppLanguages.byTag('ar').nativeName, 'العربية');
    expect(AppLanguages.byTag('zh-Hans').locale.scriptCode, 'Hans');
    expect(AppLanguages.byLocale(const Locale('pt', 'BR')).tag, 'pt-BR');
    expect(AppLanguages.byTag('fr').catalogLocale, 'en');
    expect(AppLanguages.byTag('ar').catalogLocale, 'ar');
    expect(AppLanguages.isSupported(const Locale('ja')), isTrue);
    expect(AppLanguages.all.length, greaterThan(50));
  });
}
