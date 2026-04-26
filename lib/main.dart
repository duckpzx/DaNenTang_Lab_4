// main.dart
// Điểm khởi đầu của ứng dụng Contacts App
// Khởi tạo Firebase trước khi chạy app

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/login_page.dart';

// File này được tự động tạo bởi: flutterfire configure
// Chạy lệnh: dart pub global activate flutterfire_cli
//            flutterfire configure
import 'firebase_options.dart';

void main() async {
  // Đảm bảo Flutter binding được khởi tạo trước khi gọi Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase với DefaultFirebaseOptions (hỗ trợ cả Android, iOS, Web)
  // FirebaseOptions bắt buộc khi chạy trên Web
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      // Màn hình đầu tiên là trang đăng nhập
      home: const LoginPage(),
    );
  }
}
