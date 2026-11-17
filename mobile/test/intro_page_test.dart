import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaya_events/features/intro/intro_page.dart';

import 'support/test_app.dart';

void main() {
  testWidgets('intro shows skip, next and first welcome title', (tester) async {
    var finished = false;
    await tester.pumpWidget(
      testApp(
        child: IntroPage(onFinished: () => finished = true),
      ),
    );

    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Your event, one place'), findsOneWidget);
    expect(find.text('Get started'), findsNothing);

    await tester.tap(find.text('Skip'));
    await tester.pump();
    expect(finished, isTrue);
  });
}
