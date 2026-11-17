import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaya_events/core/notifications/pending_incoming_call.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and consumes a pending incoming call from a closed-app push', () async {
    await savePendingIncomingCall({
      'type': 'incoming_call',
      'callId': 'call-22',
      'callerName': 'Layla',
    });
    final pending = await takePendingIncomingCall();
    expect(pending?['callId'], 'call-22');
    expect(pending?['type'], 'incoming_call');
    expect(await takePendingIncomingCall(), isNull);
  });

  test('ignores non-call pushes so a booking alert cannot open the ringing screen', () async {
    await savePendingIncomingCall({
      'type': 'booking',
      'id': 'notif-9',
      'bookingId': 'booking-9',
    });
    expect(await takePendingIncomingCall(), isNull);
  });
}
