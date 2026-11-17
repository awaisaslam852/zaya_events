import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaya_events/features/venue_visits/presentation/pages/visits_detail_page.dart';
import 'package:zaya_events/features/venue_visits/visit_copy.dart';
import 'package:zaya_events/l10n/app_localizations_en.dart';

import 'support/test_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('visit status copy is human', () {
    expect(visitStatusLabel(l10n, 'REQUESTED'), 'Requested');
    expect(visitStatusHint(l10n, 'REQUESTED'), contains('confirm'));
    expect(visitStatusHint(l10n, 'REQUESTED', vendor: true), contains('Accept'));
    expect(visitIsTerminal('REQUESTED'), isFalse);
    expect(visitCanApprove('REQUESTED'), isTrue);
    expect(visitCanComplete('REQUESTED'), isFalse);
    expect(visitCanComplete('APPROVED'), isTrue);
    expect(visitCanDecide('REQUESTED'), isFalse);
    expect(visitCanDecide('APPROVED'), isFalse);
    expect(visitCanDecide('COMPLETED'), isTrue);
    expect(visitGuestName({'customer': {'firstName': 'Aroosha', 'lastName': 'Awais'}}), 'Aroosha Awais');
    expect(
      visitChatPeerId({
        'venue': {
          'vendor': {'userId': 'vendor-user'},
        },
        'customer': {'id': 'customer-user'},
      }, 'customer-user'),
      'vendor-user',
    );
  });

  testWidgets('visit detail fills the page with schedule notes and actions', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: VisitDetailView(
            raw: {
              'status': 'REQUESTED',
              'scheduledAt': '2026-12-06T20:48:00.000Z',
              'notes': {'en': 'i want to visit it'},
              'venueId': 'v1',
              'venue': {
                'id': 'v1',
                'name': {'en': 'Taj mahel'},
                'city': 'lahore',
                'capacityMin': 50,
                'capacityMax': 300,
                'latitude': 25.2048,
                'longitude': 55.2708,
                'packages': [
                  {'priceAmount': 12000, 'currency': 'AED'},
                ],
              },
            },
            onCancel: () async {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('REQUESTED'), findsNothing);
    expect(find.text('Requested'), findsOneWidget);
    expect(find.text('Taj mahel'), findsOneWidget);
    expect(find.text('What’s next'), findsOneWidget);
    expect(find.textContaining('confirm this time'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('i want to visit it'), findsOneWidget);
    expect(find.text('Visit time'), findsOneWidget);
    expect(find.text('View venue'), findsWidgets);
    expect(find.text('50–300'), findsOneWidget);
    expect(find.text('From AED 12,000'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Cancel visit'), 400);
    expect(find.text('Cancel visit'), findsOneWidget);
    expect(find.text('Accept visit'), findsNothing);
  });

  testWidgets('vendor visit detail shows accept then complete', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: VisitDetailView(
            isVendor: true,
            raw: {
              'status': 'REQUESTED',
              'scheduledAt': '2026-12-06T20:48:00.000Z',
              'customer': {'firstName': 'Aroosha', 'lastName': 'Awais', 'email': 'a@b.com'},
              'venue': {
                'id': 'v1',
                'name': {'en': 'Taj mahel'},
                'city': 'lahore',
              },
            },
            onApprove: () async {},
            onComplete: () async {},
            onCancel: () async {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Accept visit'), findsOneWidget);
    expect(find.text('Aroosha Awais'), findsOneWidget);
    expect(find.textContaining('Accept this time'), findsOneWidget);
    expect(find.text('Mark visit complete'), findsNothing);

    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: VisitDetailView(
            isVendor: true,
            raw: {
              'status': 'APPROVED',
              'scheduledAt': '2026-12-06T20:48:00.000Z',
              'customer': {'firstName': 'Aroosha', 'lastName': 'Awais'},
              'venue': {
                'id': 'v1',
                'name': {'en': 'Taj mahel'},
              },
            },
            onApprove: () async {},
            onComplete: () async {},
            onCancel: () async {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Mark visit complete'), findsOneWidget);
    expect(find.text('Accept visit'), findsNothing);
  });
}
