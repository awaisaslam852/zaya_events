import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

const pendingIncomingCallKey = 'zaya_pending_incoming_call';

bool isIncomingCallData(Map<String, dynamic> data) {
  return data['type']?.toString() == 'incoming_call';
}

Map<String, dynamic> incomingCallData(Map<String, dynamic> data) {
  return {
    ...data,
    'type': 'incoming_call',
    'callId': data['callId']?.toString() ?? data['id']?.toString() ?? '',
  };
}

Future<void> savePendingIncomingCall(Map<String, dynamic> data) async {
  if (!isIncomingCallData(data)) {
    return;
  }
  final payload = incomingCallData(data);
  if ((payload['callId'] as String?)?.isEmpty ?? true) {
    return;
  }
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(pendingIncomingCallKey, jsonEncode(payload));
}

Future<Map<String, dynamic>?> takePendingIncomingCall() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(pendingIncomingCallKey);
  if (raw == null || raw.isEmpty) {
    return null;
  }
  await prefs.remove(pendingIncomingCallKey);
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      return incomingCallData(Map<String, dynamic>.from(decoded));
    }
  } catch (_) {}
  return null;
}

Future<void> dismissIncomingCallNotification(String? callId) async {
  final id = callId?.trim() ?? '';
  if (id.isEmpty) {
    return;
  }
  try {
    await FlutterLocalNotificationsPlugin().cancel(id.hashCode);
  } catch (_) {}
}
