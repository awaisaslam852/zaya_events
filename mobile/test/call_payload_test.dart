import 'package:flutter_test/flutter_test.dart';
import 'package:zaya_events/features/calls/call_payload.dart';
import 'package:zaya_events/features/calls/domain/entities/call_entity.dart';

void main() {
  test('callPayloadMap accepts map, json string, and list envelope', () {
    expect(callPayloadMap({'callId': 'abc'})?['callId'], 'abc');
    expect(callPayloadMap('{"callId":"abc"}')?['callId'], 'abc');
    expect(callPayloadMap([{'callId': 'abc'}])?['callId'], 'abc');
    expect(callPayloadMap(null), isNull);
  });

  test('fromIncoming maps callId onto the ringing call entity', () {
    final call = CallEntity.fromIncoming({
      'callId': 'call-9',
      'callerName': 'Amina',
      'channelName': 'call_a_b',
    });
    expect(call.id, 'call-9');
    expect(call.status, 'RINGING');
    expect(call.peerLabel(incoming: true), 'Amina');
  });
}
