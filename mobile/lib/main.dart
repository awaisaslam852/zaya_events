import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'bootstrap.dart';
import 'core/notifications/push_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const ZayaStartupApp());
}
