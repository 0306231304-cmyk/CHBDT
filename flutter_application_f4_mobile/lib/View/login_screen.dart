import 'package:flutter/material.dart';
import '../../Resources/app_colors.dart';
import 'Widget/custom_button.dart';
import 'Widget/custom_textfield.dart';
import 'signup_screen.dart';
import '../Controller/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final AuthController _authController = AuthController();
  
  bool _isLoading = false;

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String pass = _passController.text.trim();

    // 1. Kiểm tra rỗng
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập Email và Mật khẩu"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true); // Bật loading

    // 2. Gọi API Đăng nhập
    await _authController.login(context, email, pass);

    if (mounted) {
      setState(() => _isLoading = false); // Tắt loading khi xong
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundOrange,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Logo
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/Logo.png', height: 240, width: 240),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            Container(
              constraints: BoxConstraints(minHeight: screenHeight - 250),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text("Đăng Nhập", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  // Chuyển sang trang Đăng Ký
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản? ", style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () {
                           Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
                        },
                        child: const Text("Đăng ký", style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),

                  CustomTextField(
                    label: "Email", 
                    hint: "Loisbecket@gmail.com", 
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  CustomTextField(
                    label: "Mật khẩu", 
                    hint: "*******", 
                    controller: _passController, 
                    isPassword: true
                  ),
                  const SizedBox(height: 10),

                  // Nút Đăng nhập có hiệu ứng loading
                  CustomButton(
                    text: _isLoading ? "Đang xử lý..." : "Đăng Nhập",
                    onPressed: _isLoading ? () {} : _handleLogin,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}