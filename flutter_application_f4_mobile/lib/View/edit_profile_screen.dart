import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Tạo controller có sẵn dữ liệu giả để giống như đang sửa thông tin
  final _nameController = TextEditingController(text: "Lois Becket");
  final _emailController = TextEditingController(text: "Loisbecket@gmail.com");
  final _dobController = TextEditingController(text: "18/03/2024");
  final _phoneController = TextEditingController(text: "(454) 726-0592");
  final _addressController = TextEditingController(text: "123 ABC Street");

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // 1. Kiểm tra nhập đủ
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty ||
        _addressController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin"), backgroundColor: Colors.red),
       );
       return;
    }

    // 2. Giả lập lưu thành công
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thông tin thành công!")),
    );
    Navigator.pop(context); // Quay về màn hình Profile
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOrange,
      // Nút Back trên Appbar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Phần nội dung trắng bo góc
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text("Cập nhật thông tin", 
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                      ),
                    ),
                    const SizedBox(height: 30),

                    CustomTextField(label: "Họ và Tên", hint: "Nhập tên...", controller: _nameController),
                    CustomTextField(label: "Email", hint: "Nhập email...", controller: _emailController, keyboardType: TextInputType.emailAddress),
                    CustomTextField(label: "Ngày sinh", hint: "dd/mm/yyyy", controller: _dobController, suffixIcon: Icons.calendar_today_outlined),
                    CustomTextField(label: "Số điện thoại", hint: "Nhập sđt...", controller: _phoneController, keyboardType: TextInputType.phone),
                    CustomTextField(label: "Địa chỉ", hint: "Nhập địa chỉ...", controller: _addressController),

                    const SizedBox(height: 20),
                    CustomButton(
                      text: "Lưu thay đổi",
                      onPressed: _handleSave,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}