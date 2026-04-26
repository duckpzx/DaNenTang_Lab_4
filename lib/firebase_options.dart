// firebase_options.dart
// File này chứa cấu hình Firebase cho từng platform
//
// CÁCH 1 (khuyến nghị): Tự động generate bằng FlutterFire CLI:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
// Lệnh trên sẽ ghi đè file này với đúng giá trị từ Firebase Console.
//
// CÁCH 2: Điền thủ công các giá trị bên dưới từ Firebase Console:
//   Firebase Console -> Project Settings -> Your apps -> Web app -> SDK setup

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions không hỗ trợ platform này.',
        );
    }
  }

  // ============================================================
  // WEB CONFIG
  // Lấy từ: Firebase Console -> Project Settings -> Web app
  // ============================================================
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCqH0A-cXLi7yhX9776lgjfXqZKL-F9FJo',
    appId: '1:563570377636:web:e5778a70b9403ec7943731',
    messagingSenderId: 'G-NLEDW5FWGH',
    projectId: 'cutephomaique-f996f',
    authDomain: 'cutephomaique-f996f.firebaseapp.com',
    storageBucket: 'cutephomaique-f996f.firebasestorage.app',
  );

  // ============================================================
  // ANDROID CONFIG
  // Lấy từ: google-services.json
  // ============================================================
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  // ============================================================
  // IOS CONFIG (nếu cần)
  // Lấy từ: GoogleService-Info.plist
  // ============================================================
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',
  );
}
