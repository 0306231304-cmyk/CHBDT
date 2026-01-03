import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_textfield.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleChangePassword() {
    // 1. Kiểm tra rỗng
    if (_oldPassController.text.isEmpty || 
        _newPassController.text.isEmpty || 
        _confirmPassController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng nhập đủ các trường"), backgroundColor: Colors.red),
       );
       return;
    }

    // 2. Kiểm tra mật khẩu khớp nhau
    if (_newPassController.text != _confirmPassController.text) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mật khẩu xác nhận không khớp"), backgroundColor: Colors.red),
       );
       return;
    }

    // 3. Giả lập thành công
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đổi mật khẩu thành công!")),
    );
    Navigator.pop(context); // Quay về Profile
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

                    // Inputs cho mật khẩu
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
                      label: "Nhập lại mật khẩu mới", 
                      hint: "*******", 
                      controller: _confirmPassController, 
                      isPassword: true
                    ),

                    const SizedBox(height: 20),
                    CustomButton(
                      text: "Lưu mật khẩu",
                      onPressed: _handleChangePassword,
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