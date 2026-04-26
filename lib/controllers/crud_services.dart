// crud_services.dart
// Xử lý toàn bộ logic CRUD cho Contacts trên Cloud Firestore
// Mỗi user chỉ thấy contacts của chính mình (dựa theo uid)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrudServices {
  // Instance của Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Instance của FirebaseAuth để lấy uid của user hiện tại
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Lấy uid của user đang đăng nhập
  /// Dùng để phân tách dữ liệu theo từng user
  String get _uid => _auth.currentUser!.uid;

  /// Tham chiếu đến collection contacts của user hiện tại
  /// Cấu trúc Firestore: users/{uid}/contacts/{contactId}
  CollectionReference get _contactsCollection =>
      _firestore.collection('users').doc(_uid).collection('contacts');

  /// Thêm contact mới vào Firestore
  /// [name] - Tên liên lạc
  /// [phone] - Số điện thoại
  Future<void> addContact({
    required String name,
    required String phone,
  }) async {
    try {
      await _contactsCollection.add({
        'name': name.trim(),
        'phone': phone.trim(),
        // Lưu thời gian tạo để có thể sắp xếp theo thứ tự
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Không thể thêm contact: $e');
    }
  }

  /// Lấy danh sách contacts dưới dạng Stream (real-time updates)
  /// UI sẽ tự động cập nhật khi dữ liệu thay đổi
  Stream<QuerySnapshot> getContacts() {
    return _contactsCollection
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// Cập nhật thông tin contact theo [docId]
  /// [docId] - ID của document trong Firestore
  Future<void> updateContact({
    required String docId,
    required String name,
    required String phone,
  }) async {
    try {
      await _contactsCollection.doc(docId).update({
        'name': name.trim(),
        'phone': phone.trim(),
        // Lưu thời gian cập nhật gần nhất
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Không thể cập nhật contact: $e');
    }
  }

  /// Xóa contact theo [docId]
  Future<void> deleteContact({required String docId}) async {
    try {
      await _contactsCollection.doc(docId).delete();
    } catch (e) {
      throw Exception('Không thể xóa contact: $e');
    }
  }
}
