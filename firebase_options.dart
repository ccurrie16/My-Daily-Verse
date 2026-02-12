import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError('Android not configured yet');
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS not configured yet');
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCq_yRJQtGj1hx7-sNpI--JVt6r4ccvXoU',
    appId: '1:36764477124:web:2d0d85a9bc316f891f0b91',
    messagingSenderId: '36764477124',
    projectId: 'my-daily-verse-a06de',
    authDomain: 'my-daily-verse-a06de.firebaseapp.com',
    storageBucket: 'my-daily-verse-a06de.firebasestorage.app',
  );
}