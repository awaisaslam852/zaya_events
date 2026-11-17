import 'dart:convert';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../firebase_options.dart';
import '../../features/calls/presentation/bloc/call_bloc.dart';
import '../../features/calls/presentation/bloc/call_event.dart';
import 'package:get_it/get_it.dart';
import '../../features/notifications/domain/usecases/register_device.dart';
import '../../features/notifications/presentation/cubit/unread_notifications_cubit.dart';
import 'pending_incoming_call.dart';

const _callsChannel = AndroidNotificationChannel(
  'calls',
  'Calls',
  description: 'Incoming Zaya calls',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
);

const _defaultChannel = AndroidNotificationChannel(
  'default',
  'Notifications',
  description: 'Booking, chat, and payment alerts',
  importance: Importance.high,
  playSound: true,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  final data = Map<String, dynamic>.from(message.data);
  if (!isIncomingCallData(data)) {
    return;
  }
  await savePendingIncomingCall(data);
  await showIncomingCallLocalNotification(data);
}

Future<void> showIncomingCallLocalNotification(Map<String, dynamic> data) async {
  final payload = incomingCallData(data);
  final local = FlutterLocalNotificationsPlugin();
  await local.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_stat_zaya'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  final android = local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await android?.createNotificationChannel(_callsChannel);
  final name = payload['callerName']?.toString().trim();
  await local.show(
    (payload['callId'] ?? 'call').hashCode,
    name == null || name.isEmpty ? 'Incoming call' : name,
    payload['body']?.toString() ?? 'Incoming call on Zaya Events',
    NotificationDetails(
      android: AndroidNotificationDetails(
        _callsChannel.id,
        _callsChannel.name,
        channelDescription: _callsChannel.description,
        icon: 'ic_stat_zaya',
        color: const Color(0xFF003580),
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.call,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
        playSound: true,
        enableVibration: true,
        ongoing: true,
        autoCancel: false,
        timeoutAfter: 60000,
        ticker: 'Incoming call',
      ),
      iOS: const DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBanner: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    ),
    payload: jsonEncode(payload),
  );
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

  void Function(String path)? onOpenRoute;

  Future<void> init() async {
    try {
      const android = AndroidInitializationSettings('@drawable/ic_stat_zaya');
      const ios = DarwinInitializationSettings();
      await local.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload == null) {
            return;
          }
          if (response.actionId == acceptId) {
            callBloc.add(CallEvent.accept(_callIdFromPayload(payload)));
          } else if (response.actionId == rejectId) {
            callBloc.add(CallEvent.reject(_callIdFromPayload(payload)));
          } else {
            openFromData(_dataFromPayload(payload));
          }
        },
      );
      final androidLocal = local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidLocal?.createNotificationChannel(_callsChannel);
      await androidLocal?.createNotificationChannel(_defaultChannel);
      await androidLocal?.requestNotificationsPermission();
      try {
        await androidLocal?.requestFullScreenIntentPermission();
      } catch (_) {}
    } catch (_) {}

    if (Firebase.apps.isEmpty) {
      return;
    }

    try {
      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      await messaging.requestPermission(alert: true, badge: true, sound: true, criticalAlert: true);
      final launch = await local.getNotificationAppLaunchDetails();
      final launchPayload = launch?.notificationResponse?.payload;
      if (launch?.didNotificationLaunchApp == true && launchPayload != null) {
        final launched = _dataFromPayload(launchPayload);
        if (isIncomingCallData(launched)) {
          await savePendingIncomingCall(launched);
        }
      }
      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        final opened = Map<String, dynamic>.from(initial.data);
        if (isIncomingCallData(opened)) {
          await savePendingIncomingCall(opened);
        }
      }
      await registerCurrentToken();
      messaging.onTokenRefresh.listen((token) {
        registerDevice(token);
      });
    } catch (_) {}
  }

  Future<void> replayPendingIncoming() async {
    final pending = await takePendingIncomingCall();
    if (pending == null) {
      return;
    }
    openFromData(pending);
  }

  Future<void> registerCurrentToken() async {
    if (Firebase.apps.isEmpty) {
      return;
    }
    try {
      final token = await messaging.getToken();
      if (token != null) {
        await registerDevice(token);
      }
    } catch (_) {}
  }

  void openFromData(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    if (isIncomingCallData(data) || type == 'incoming_call') {
      callBloc.add(CallEvent.incomingFromPush(incomingCallData(data)));
      return;
    }
    final bookingId = data['bookingId']?.toString();
    final conversationId = data['conversationId']?.toString();
    final visitId = data['visitId']?.toString();
    if (conversationId != null && conversationId.isNotEmpty) {
      onOpenRoute?.call('/chat/$conversationId');
      return;
    }
    if (bookingId != null && bookingId.isNotEmpty) {
      onOpenRoute?.call('/bookings/$bookingId');
      return;
    }
    if (visitId != null && visitId.isNotEmpty) {
      onOpenRoute?.call('/venue_visits/$visitId');
      return;
    }
    onOpenRoute?.call('/notifications');
  }

  void _onForeground(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    if (isIncomingCallData(data)) {
      callBloc.add(CallEvent.incomingFromPush(incomingCallData(data)));
      return;
    }
    final title = message.notification?.title ?? data['title']?.toString() ?? 'Zaya Events';
    final body = message.notification?.body ?? data['body']?.toString() ?? '';
    if (title.isEmpty && body.isEmpty) {
      return;
    }
    const android = AndroidNotificationDetails(
      'default',
      'Notifications',
      channelDescription: 'Booking, chat, and payment alerts',
      icon: 'ic_stat_zaya',
      color: Color(0xFF003580),
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    local.show(
      (data['bookingId'] ?? data['conversationId'] ?? data['visitId'] ?? title).hashCode,
      title,
      body,
      const NotificationDetails(
        android: android,
        iOS: DarwinNotificationDetails(presentSound: true, presentAlert: true),
      ),
      payload: jsonEncode(data),
    );
    if (GetIt.I.isRegistered<UnreadNotificationsCubit>()) {
      GetIt.I<UnreadNotificationsCubit>().refresh();
    }
  }

  void _onOpened(RemoteMessage message) {
    openFromData(Map<String, dynamic>.from(message.data));
  }

  Map<String, dynamic> _dataFromPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}
    return {'type': 'incoming_call', 'callId': payload};
  }

  String _callIdFromPayload(String payload) {
    return _dataFromPayload(payload)['callId']?.toString() ?? payload;
  }
}
