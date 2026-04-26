// auth_services.dart
// Xử lý toàn bộ logic Authentication:
// - Đăng nhập bằng Email/Password
// - Đăng ký tài khoản mới
// - Đăng nhập bằng Google (dùng Firebase signInWithPopup trên Web)
// - Đăng xuất

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Chỉ dùng GoogleSignIn trên mobile (Android/iOS)
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Đăng nhập bằng Email và Password
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Đăng ký tài khoản mới bằng Email và Password
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Đăng nhập bằng Google
  /// - Trên Web: dùng signInWithPopup (không cần clientId, không cần People API)
  /// - Trên Mobile: dùng google_sign_in package
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // ---- WEB: dùng Firebase popup trực tiếp ----
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        // Thêm scope email để lấy thông tin cơ bản
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        final UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);
        return userCredential;
      } else {
        // ---- MOBILE: dùng google_sign_in package ----
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Đăng nhập Google thất bại: $e');
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      throw Exception('Đăng xuất thất bại: $e');
    }
  }

  /// Chuyển đổi FirebaseAuthException thành thông báo lỗi tiếng Việt
  Exception _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'Không tìm thấy tài khoản với email này.';
        break;
      case 'wrong-password':
        message = 'Mật khẩu không đúng.';
        break;
      case 'email-already-in-use':
        message = 'Email này đã được sử dụng.';
        break;
      case 'weak-password':
        message = 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
        break;
      case 'invalid-email':
        message = 'Địa chỉ email không hợp lệ.';
        break;
      case 'user-disabled':
        message = 'Tài khoản này đã bị vô hiệu hóa.';
        break;
      case 'too-many-requests':
        message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
        break;
      case 'operation-not-allowed':
        message = 'Phương thức đăng nhập này chưa được bật.';
        break;
      case 'popup-closed-by-user':
        message = 'Bạn đã đóng cửa sổ đăng nhập.';
        break;
      case 'popup-blocked':
        message = 'Trình duyệt đã chặn popup. Vui lòng cho phép popup.';
        break;
      default:
        message = e.message ?? 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
    return Exception(message);
  }
}
