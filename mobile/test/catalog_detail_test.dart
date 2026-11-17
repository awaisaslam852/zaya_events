import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaya_events/core/widgets/catalog_detail.dart';
import 'package:zaya_events/core/widgets/property_card.dart';

import 'support/test_app.dart';

void main() {
  test('empty ratings stay hidden', () {
    expect(catalogHasPublicRating({'ratingAvg': 0, 'ratingCount': 0}), isFalse);
    expect(catalogHasPublicRating({'ratingAvg': '0', 'ratingCount': '0'}), isFalse);
    expect(catalogHasPublicRating({'ratingAvg': 4.8, 'ratingCount': 12}), isTrue);
  });

  test('duplicate descriptions stay hidden', () {
    expect(catalogShouldShowDescription('taj mahel', 'Taj mahel'), isFalse);
    expect(catalogShouldShowDescription('', 'Taj mahel'), isFalse);
    expect(catalogShouldShowDescription('Garden hall with parking', 'Taj mahel'), isTrue);
  });

  test('amenity labels are readable', () {
    expect(catalogAmenityLabel('bridal-suite', 'en'), 'Bridal Suite');
    expect(catalogAmenityLabel({'en': 'wifi'}, 'en'), 'Wifi');
  });

  test('catalog price uses the cheapest package', () {
    expect(
      catalogPrice({
        'packages': [
          {'priceAmount': '18000', 'currency': 'AED'},
          {'priceAmount': 12000, 'currency': 'AED'},
        ],
      }),
      'AED 12,000',
    );
    expect(catalogPrice({'startingPrice': 0, 'packages': const []}), isNull);
    expect(catalogPriceIsPerGuest({'pricingModel': 'PER_GUEST'}), isTrue);
    expect(catalogPriceIsPerGuest({'pricingModel': 'HIRE'}), isFalse);
    expect(catalogGuestRange({'capacityMin': 50, 'capacityMax': 300}), '50–300');
    expect(catalogRatingLabel({'ratingAvg': 0, 'ratingCount': 0}), isNull);
    expect(catalogRatingLabel({'ratingAvg': 8.8, 'ratingCount': 12}), '8.8');
  });

  testWidgets('detail page hides empty rating and duplicate copy', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: CatalogDetailView(
            raw: {
              'id': 'v1',
              'name': {'en': 'Taj mahel'},
              'description': {'en': 'taj mahel'},
              'city': 'lahore',
              'ratingAvg': 0,
              'ratingCount': 0,
              'capacityMin': 50,
              'capacityMax': 300,
              'amenities': ['parking', 'bridal-suite'],
            },
            resourceType: 'VENUE',
            resourceId: 'v1',
            enableFavorite: false,
            primaryLabel: 'Book now',
            onPrimary: () {},
            secondaryLabel: 'Add to cart',
            onSecondary: () {},
            onChat: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('0 · 0'), findsNothing);
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Taj mahel'), findsOneWidget);
    expect(find.text('taj mahel'), findsNothing);
    expect(find.text('Capacity 50–300 guests'), findsOneWidget);
    expect(find.text('Bridal Suite'), findsOneWidget);
    expect(find.text('Book now'), findsOneWidget);
    expect(find.text('Add to cart'), findsOneWidget);
    expect(find.text('Message vendor'), findsOneWidget);
  });

  testWidgets('vendor catalog hides guest book, cart, and chat actions', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: CatalogDetailView(
            raw: {
              'id': 'v1',
              'name': {'en': 'Taj mahel'},
              'city': 'lahore',
              'vendorId': 'vendor-1',
            },
            resourceType: 'VENUE',
            resourceId: 'v1',
            isVendor: true,
            ownedByViewer: false,
            primaryLabel: 'Book now',
            onPrimary: () {},
            secondaryLabel: 'Add to cart',
            onSecondary: () {},
            onChat: () {},
            quickActions: [
              CatalogQuickAction(icon: Icons.mail_outline, label: 'Inquire', onTap: () {}),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Book now'), findsNothing);
    expect(find.text('Add to cart'), findsNothing);
    expect(find.text('Message vendor'), findsNothing);
    expect(find.text('Inquire'), findsNothing);
    expect(find.text('Edit product'), findsNothing);
  });

  testWidgets('vendor own listing shows edit instead of book', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: CatalogDetailView(
            raw: {
              'id': 'v1',
              'name': {'en': 'Taj mahel'},
              'city': 'lahore',
              'vendorId': 'vendor-1',
            },
            resourceType: 'VENUE',
            resourceId: 'v1',
            isVendor: true,
            ownedByViewer: true,
            primaryLabel: 'Book now',
            onPrimary: () {},
            secondaryLabel: 'Add to cart',
            onSecondary: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Book now'), findsNothing);
    expect(find.text('Add to cart'), findsNothing);
    expect(find.text('Edit product'), findsOneWidget);
  });

  testWidgets('property card fills with guests and price instead of empty space', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        child: Center(
          child: SizedBox(
            width: 220,
            child: PropertyCard(
              horizontal: true,
              onTap: () {},
              raw: {
                'name': {'en': 'Taj mahel'},
                'city': 'lahore',
                'ratingAvg': 0,
                'ratingCount': 0,
                'capacityMin': 50,
                'capacityMax': 300,
                'packages': [
                  {'priceAmount': 12000, 'currency': 'AED'},
                ],
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Taj mahel'), findsOneWidget);
    expect(find.text('lahore'), findsOneWidget);
    expect(find.text('50–300 Guests'), findsOneWidget);
    expect(find.text('From AED 12,000'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);
    expect(find.text('0'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
