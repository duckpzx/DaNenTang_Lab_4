// update_contact.dart
// Màn hình chỉnh sửa thông tin contact
// Nhận vào docId, tên và số điện thoại hiện tại để pre-fill form

import 'package:flutter/material.dart';
import '../controllers/crud_services.dart';

class UpdateContactPage extends StatefulWidget {
  // Thông tin contact cần chỉnh sửa được truyền vào qua constructor
  final String docId;
  final String currentName;
  final String currentPhone;

  const UpdateContactPage({
    super.key,
    required this.docId,
    required this.currentName,
    required this.currentPhone,
  });

  @override
  State<UpdateContactPage> createState() => _UpdateContactPageState();
}

class _UpdateContactPageState extends State<UpdateContactPage> {
  // Key để validate form
  final _formKey = GlobalKey<FormState>();

  // Controllers - sẽ được khởi tạo với giá trị hiện tại trong initState
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  // Instance của CrudServices
  final CrudServices _crudServices = CrudServices();

  // Trạng thái loading
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill form với dữ liệu hiện tại của contact
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Xử lý cập nhật contact trong Firestore
  Future<void> _updateContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _crudServices.updateContact(
        docId: widget.docId,
        name: _nameController.text,
        phone: _phoneController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật contact thành công!'),
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
        title: const Text('Chỉnh sửa Contact'),
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
                  'Chỉnh sửa thông tin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cập nhật thông tin liên lạc',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Avatar với chữ cái đầu của tên hiện tại
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Text(
                      widget.currentName.isNotEmpty
                          ? widget.currentName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Input Tên (đã được pre-fill)
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên',
                    prefixIcon: Icon(Icons.person_outlined),
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

                // Input Số điện thoại (đã được pre-fill)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (!RegExp(r'^[0-9]{9,11}$')
                        .hasMatch(value.trim().replaceAll(' ', ''))) {
                      return 'Số điện thoại không hợp lệ (9-11 chữ số)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Nút Cập nhật
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _updateContact,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.update),
                        label: const Text(
                          'Cập nhật',
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
