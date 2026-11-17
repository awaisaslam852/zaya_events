import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaya_events/core/auth/app_role.dart';
import 'package:zaya_events/core/shells/nav_destinations.dart';

import 'support/test_app.dart';

void main() {
  test('homePathForRole splits customer, vendor, and admin', () {
    expect(homePathForRole(AppRole.customer), '/customer/home');
    expect(homePathForRole(AppRole.vendor), '/vendor/dashboard');
    expect(homePathForRole(AppRole.admin), '/admin-redirect');
  });

  testWidgets('customer nav shows home and bookings, not catalog', (tester) async {
    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          bottomNavigationBar: RoleNavBar(
            role: AppRole.customer,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('My bookings'), findsOneWidget);
    expect(find.text('My catalog'), findsNothing);
    expect(find.text('Requests'), findsNothing);
  });

  testWidgets('vendor nav shows dashboard and listings', (tester) async {
    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          bottomNavigationBar: RoleNavBar(
            role: AppRole.vendor,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('My catalog'), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('My events'), findsNothing);
  });
}
