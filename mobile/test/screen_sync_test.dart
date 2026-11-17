import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaya_events/core/sync/app_refresh.dart';
import 'package:zaya_events/core/sync/screen_sync.dart';

import 'support/test_app.dart';

void main() {
  testWidgets('ScreenSync reloads when a matching topic is pinged', (tester) async {
    var count = 0;
    await tester.pumpWidget(
      testApp(
        child: ScreenSync(
          topics: const [AppRefreshTopic.bookings],
          onRefresh: (_) async {
            count += 1;
          },
          child: const SizedBox(),
        ),
      ),
    );
    await tester.pump();

    AppRefresh.instance.ping(AppRefreshTopic.bookings);
    await tester.pump(const Duration(milliseconds: 350));
    expect(count, 1);

    AppRefresh.instance.ping(AppRefreshTopic.cart);
    await tester.pump(const Duration(milliseconds: 350));
    expect(count, 1);
  });
}
