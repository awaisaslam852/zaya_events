import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaya_events/features/auth/presentation/pages/login_page.dart';

import 'support/test_app.dart';

void main() {
  testWidgets('login form submits email and password', (tester) async {
    String? email;
    String? password;
    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: LoginForm(
            busy: false,
            onSubmit: (e, p) {
              email = e;
              password = p;
            },
          ),
        ),
      ),
    );

    expect(find.text('Sign in'), findsWidgets);
    await tester.enterText(find.byType(TextField).at(1), 'guest@zaya.local');
    await tester.enterText(find.byType(TextField).at(2), 'secret123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(email, 'guest@zaya.local');
    expect(password, 'secret123');
  });
}
