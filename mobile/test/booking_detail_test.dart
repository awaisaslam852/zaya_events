import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaya_events/features/bookings/presentation/pages/bookings_detail_page.dart';

import 'support/test_app.dart';

void main() {
  testWidgets('confirmed booking shows chat and hides empty money', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: BookingDetailView(
            raw: {
              'id': 'b1',
              'bookingNumber': 'ZY-2026-391791',
              'status': 'CONFIRMED',
              'type': 'VENUE',
              'totalAmount': 0,
              'balanceAmount': 0,
              'guestCount': 50,
              'startAt': '2026-12-06T00:00:00.000Z',
              'endAt': '2026-12-07T00:00:00.000Z',
              'venueId': 'v1',
              'venue': {
                'id': 'v1',
                'name': {'en': 'Taj mahel'},
              },
              'vendor': {'userId': 'vendor-1'},
              'customer': {'id': 'cust-1', 'firstName': 'Aroosha'},
            },
            onPay: (_) async {},
            onModify: () {},
            onCancel: () {},
            onChat: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('CONFIRMED'), findsNothing);
    expect(find.text('Taj mahel'), findsOneWidget);
    expect(find.text('Message vendor'), findsWidgets);
    expect(find.text('Price to be confirmed'), findsOneWidget);
    expect(find.text('PKR 0'), findsNothing);
    expect(find.text('Pay remaining balance'), findsNothing);
  });

  testWidgets('vendor booking hides pay and shows event brief', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: BookingDetailView(
            raw: {
              'id': 'b2',
              'bookingNumber': 'ZY-2026-816490',
              'status': 'CONFIRMED',
              'type': 'VENUE',
              'totalAmount': 125000,
              'balanceAmount': 87500,
              'depositAmount': 37500,
              'currency': 'PKR',
              'guestCount': 50,
              'startAt': '2026-12-06T00:00:00.000Z',
              'endAt': '2026-12-07T00:00:00.000Z',
              'venueId': 'v1',
              'venue': {
                'id': 'v1',
                'name': {'en': 'Taj mhal'},
              },
              'payments': [
                {'kind': 'DEPOSIT', 'status': 'SUCCEEDED', 'amount': 37500},
              ],
              'vendor': {'userId': 'vendor-1'},
              'customer': {'id': 'cust-1', 'firstName': 'Aroosha', 'lastName': 'Awais'},
            },
            isVendor: true,
            onPay: (_) async {},
            onModify: () {},
            onCancel: () {},
            onVendorAct: (_) async {},
            onChat: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Pay remaining balance · PKR 87,500'), findsNothing);
    expect(find.text('Pay remaining balance'), findsNothing);
    expect(find.text('Event brief'), findsOneWidget);
    expect(find.text('Aroosha Awais'), findsOneWidget);
    expect(find.text('Mark complete'), findsOneWidget);
    expect(find.text('Message guest'), findsWidgets);
    expect(find.text('Guest paid'), findsOneWidget);
    expect(find.text('Outstanding'), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);
    expect(find.text('Change dates'), findsNothing);
  });

  testWidgets('completed booking shows review CTA only when allowed', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: BookingDetailView(
            raw: {
              'id': 'b3',
              'bookingNumber': 'ZY-2026-100',
              'status': 'COMPLETED',
              'type': 'VENUE',
              'reviewState': {'canWrite': true, 'mine': null, 'theirs': null},
              'venue': {
                'id': 'v1',
                'name': {'en': 'Taj mahel'},
              },
            },
            onPay: (_) async {},
            onModify: () {},
            onCancel: () {},
            onReview: () {},
            onChat: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Rate this vendor'), findsOneWidget);
    expect(find.text('Pay remaining balance'), findsNothing);
  });
}
