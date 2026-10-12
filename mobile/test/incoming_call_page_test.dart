import 'package:flutter_test/flutter_test.dart';
import 'package:zaya_events/features/calls/domain/entities/call_entity.dart';
import 'package:zaya_events/features/calls/presentation/pages/incoming_call_page.dart';

import 'support/test_app.dart';

void main() {
  testWidgets('incoming call screen shell shows accept and reject', (tester) async {
    await tester.pumpWidget(
      testApp(child: const IncomingCallPage(call: CallEntity(id: 'call-1', status: 'RINGING'))),
    );

    expect(find.text('Incoming call'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
  });
}
