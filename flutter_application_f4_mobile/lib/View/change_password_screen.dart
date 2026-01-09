import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import 'Widget/custom_button.dart';
import 'Widget/custom_textfield.dart';
import '../Controller/auth_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final AuthController _authController = AuthController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    // Kiểm tra rỗng
    if (_oldPassController.text.isEmpty || 
        _newPassController.text.isEmpty || 
        _confirmPassController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Vui lòng nhập đủ các trường"), backgroundColor: Colors.red),
       );
       return;
    }

    // Kiểm tra mật khẩu xác nhận
    if (_newPassController.text != _confirmPassController.text) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Mật khẩu xác nhận không khớp"), backgroundColor: Colors.red),
       );
       return;
    }

    // Kiểm tra mật khẩu mới trùng mật khẩu cũ
    if (_oldPassController.text == _newPassController.text) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Mật khẩu mới không được trùng với mật khẩu cũ"), backgroundColor: Colors.red),
       );
       return;
    }

    setState(() => _isLoading = true);

    await _authController.changePassword(
      context, 
      currentPassword: _oldPassController.text, 
      newPassword: _newPassController.text
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOrange,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text("Đổi mật khẩu", 
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                      ),
                    ),
                    const SizedBox(height: 30),

                    CustomTextField(
                      label: "Mật khẩu cũ", 
                      hint: "*******", 
                      controller: _oldPassController, 
                      isPassword: true
                    ),
                    CustomTextField(
                      label: "Mật khẩu mới", 
                      hint: "*******", 
                      controller: _newPassController, 
                      isPassword: true
                    ),
                    CustomTextField(
                      label: "Xác nhận mật khẩu mới", 
                      hint: "*******", 
                      controller: _confirmPassController, 
                      isPassword: true
                    ),

                    const SizedBox(height: 20),
                    
                     CustomButton(
                      text: _isLoading ? "Đang xử lý..." : "Đăng ký", 
                      onPressed: _isLoading ? () {} : _handleChangePassword,
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