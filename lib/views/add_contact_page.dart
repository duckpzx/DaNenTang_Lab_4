// add_contact_page.dart
// Màn hình thêm contact mới
// Form gồm: Tên và Số điện thoại

import 'package:flutter/material.dart';
import '../controllers/crud_services.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  // Key để validate form
  final _formKey = GlobalKey<FormState>();

  // Controllers để lấy giá trị từ TextField
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Instance của CrudServices
  final CrudServices _crudServices = CrudServices();

  // Trạng thái loading khi đang lưu
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Xử lý thêm contact mới vào Firestore
  Future<void> _addContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _crudServices.addContact(
        name: _nameController.text,
        phone: _phoneController.text,
      );

      if (mounted) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm contact thành công!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Quay lại màn hình Home
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Contact'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                const Text(
                  'Thông tin liên lạc',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Điền thông tin contact mới',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Avatar placeholder
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Input Tên
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên',
                    prefixIcon: Icon(Icons.person_outlined),
                    hintText: 'Nhập tên liên lạc',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên';
                    }
                    if (value.trim().length < 2) {
                      return 'Tên phải có ít nhất 2 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Số điện thoại
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: 'Nhập số điện thoại',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    // Kiểm tra định dạng số điện thoại Việt Nam
                    if (!RegExp(r'^[0-9]{9,11}$')
                        .hasMatch(value.trim().replaceAll(' ', ''))) {
                      return 'Số điện thoại không hợp lệ (9-11 chữ số)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Nút Lưu
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _addContact,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'Lưu Contact',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                const SizedBox(height: 12),

                // Nút Hủy
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text(
                    'Hủy',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
