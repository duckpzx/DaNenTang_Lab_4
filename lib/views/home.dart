// home.dart
// Màn hình chính - hiển thị danh sách contacts
// Sử dụng StreamBuilder để lắng nghe real-time updates từ Firestore

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/auth_services.dart';
import '../controllers/crud_services.dart';
import 'add_contact_page.dart';
import 'update_contact.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthServices _authServices = AuthServices();
  final CrudServices _crudServices = CrudServices();

  /// Xử lý đăng xuất
  Future<void> _logout() async {
    // Hiển thị dialog xác nhận trước khi đăng xuất
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _authServices.logout();
        if (mounted) {
          // Xóa toàn bộ stack và về trang Login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Xử lý xóa contact với xác nhận
  Future<void> _deleteContact(String docId, String name) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa contact'),
        content: Text('Bạn có chắc muốn xóa "$name" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _crudServices.deleteContact(docId: docId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa contact thành công'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy email của user hiện tại để hiển thị
    final String userEmail =
        _authServices.currentUser?.email ?? 'Người dùng';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh bạ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Hiển thị email user
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                userEmail,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Nút Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: _logout,
          ),
        ],
      ),
      // StreamBuilder lắng nghe real-time từ Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: _crudServices.getContacts(),
        builder: (context, snapshot) {
          // Đang tải dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Có lỗi xảy ra
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          // Không có dữ liệu hoặc danh sách rỗng
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.contacts, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có contact nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Nhấn nút + để thêm contact mới',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Hiển thị danh sách contacts
          final List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>;
              final String name = data['name'] ?? 'Không có tên';
              final String phone = data['phone'] ?? 'Không có số';

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  // Avatar với chữ cái đầu của tên
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    phone,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  // Các nút hành động
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nút chỉnh sửa
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Chỉnh sửa',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UpdateContactPage(
                                docId: doc.id,
                                currentName: name,
                                currentPhone: phone,
                              ),
                            ),
                          );
                        },
                      ),
                      // Nút xóa
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Xóa',
                        onPressed: () => _deleteContact(doc.id, name),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Nút thêm contact mới
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddContactPage()),
          );
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        tooltip: 'Thêm contact',
        child: const Icon(Icons.add),
      ),
    );
  }
}
