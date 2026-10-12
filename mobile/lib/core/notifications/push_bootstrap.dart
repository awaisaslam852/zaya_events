import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/calls/presentation/bloc/call_bloc.dart';
import '../../features/calls/presentation/bloc/call_event.dart';
import '../../features/notifications/domain/usecases/register_device.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background FCM is handled by the OS + local notification plugin.
}

class PushBootstrap {
  PushBootstrap({
    required this.messaging,
    required this.local,
    required this.callBloc,
    required this.registerDevice,
  });

  final FirebaseMessaging messaging;
  final FlutterLocalNotificationsPlugin local;
  final CallBloc callBloc;
  final RegisterDevice registerDevice;

  static const acceptId = 'accept_call';
  static const rejectId = 'reject_call';

  Future<void> init() async {
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await local.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload == null) {
            return;
          }
          if (response.actionId == acceptId) {
            callBloc.add(CallEvent.accept(payload));
          } else if (response.actionId == rejectId) {
            callBloc.add(CallEvent.reject(payload));
          } else {
            callBloc.add(CallEvent.incomingFromPush({'callId': payload}));
          }
        },
      );
      const channel = AndroidNotificationChannel(
        'calls',
        'Calls',
        description: 'Incoming Zaya calls',
        importance: Importance.max,
      );
      await local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (_) {}

    if (Firebase.apps.isEmpty) {
      return;
    }

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);
      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _onOpened(initial);
      }
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token != null) {
        await registerDevice(token);
      }
      messaging.onTokenRefresh.listen(registerDevice.call);
    } catch (_) {}
  }

  void _onForeground(RemoteMessage message) {
    final data = message.data;
    if (data['type'] == 'incoming_call') {
      callBloc.add(CallEvent.incomingFromPush(data));
      return;
    }
  }

  void _onOpened(RemoteMessage message) {
    if (message.data['type'] == 'incoming_call') {
      callBloc.add(CallEvent.incomingFromPush(message.data));
    }
  }

  Future<void> showIncomingCallNotification({
    required String callId,
    required String title,
    required String body,
  }) {
    const android = AndroidNotificationDetails(
      'calls',
      'Calls',
      channelDescription: 'Incoming Zaya calls',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      actions: [
        AndroidNotificationAction(PushBootstrap.acceptId, 'Accept'),
        AndroidNotificationAction(PushBootstrap.rejectId, 'Reject'),
      ],
    );
    return local.show(
      callId.hashCode,
      title,
      body,
      const NotificationDetails(android: android, iOS: DarwinNotificationDetails()),
      payload: callId,
    );
  }
}
