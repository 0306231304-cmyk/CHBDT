import 'package:flutter/material.dart';
import '../../Resources/app_colors.dart';
import 'Widgets/custom_button.dart';
import 'Widgets/custom_textfield.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Khai báo controller
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController(); 
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    // 1. Kiểm tra rỗng
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin!"), backgroundColor: Colors.red),
        );
        return;
    }

    // 2. Kiểm tra mật khẩu khớp nhau
    if (_passController.text != _confirmPassController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mật khẩu xác nhận không khớp!"), backgroundColor: Colors.red),
        );
        return;
    }

    // 3. Thành công -> Quay về Login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đăng ký thành công! Hãy đăng nhập.")),
    );
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOrange,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // Quay về trang Login
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Đăng Ký", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    
                    // Chuyển sang trang Đăng Nhập
                    Row(
                      children: [
                        const Text("Đã có tài khoản? ", style: TextStyle(color: Colors.grey)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text("Đăng nhập", style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Inputs
                    CustomTextField(label: "Họ và tên", hint: "Lois Becket", controller: _nameController),
                    CustomTextField(label: "Email", hint: "Loisbecket@gmail.com", controller: _emailController, keyboardType: TextInputType.emailAddress),
                    CustomTextField(label: "Ngày sinh", hint: "18/03/2024", controller: _dobController),
                    CustomTextField(label: "Số điện thoại", hint: "(454) 726-0592", controller: _phoneController, keyboardType: TextInputType.phone),
                    CustomTextField(label: "Địa chỉ", hint: "123 Đường ABC", controller: _addressController),
                    CustomTextField(label: "Mật khẩu", hint: "*******", controller: _passController, isPassword: true),
                    CustomTextField(label: "Xác nhận mật khẩu", hint: "*******", controller: _confirmPassController, isPassword: true),

                    const SizedBox(height: 20),
                    CustomButton(
                      text: "Đăng Ký",
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(height: 30),
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