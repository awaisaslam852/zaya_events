// File generated from Firebase console configs for Zaya Events.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Zaya Events does not use Firebase on web.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Firebase is not configured for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDI--dpjqojtLyMCTXyhUn9b63PiaP7BzE',
    appId: '1:120051328500:android:9dd3ac8a8abb6e967cc5a1',
    messagingSenderId: '120051328500',
    projectId: 'zaya-events',
    storageBucket: 'zaya-events.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAr2NW7bD2-SQShzEM7GK-ChnbHwJktKTY',
    appId: '1:120051328500:ios:a436432c3178db6d7cc5a1',
    messagingSenderId: '120051328500',
    projectId: 'zaya-events',
    storageBucket: 'zaya-events.firebasestorage.app',
    iosBundleId: 'com.example.zayaEvents',
  );
}
