import 'package:flutter/material.dart';
//import '../../Resources/app_colors.dart'; // Đảm bảo folder Resources viết hoa chữ R đúng như bạn đặt
import 'Widgets/custom_button.dart';
import 'Widgets/custom_textfield.dart';
import 'signup_screen.dart';
import 'home/home_screen.dart'; // Thêm dòng này để chuyển trang sau khi login

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  void _handleLogin() {
    String email = _emailController.text.trim();
    String pass = _passController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập Email và Mật khẩu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // THÔNG BÁO THÀNH CÔNG
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đăng nhập thành công!")),
    );

    // CHUYỂN THẲNG VÀO TRANG CHỦ (HomeScreen) GIỐNG FIGMA
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Nếu AppColors.backgroundOrange của bạn bị lỗi, hãy thay tạm bằng Colors.orange
      backgroundColor: Colors.orange, 
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Đảm bảo bạn đã khai báo ảnh này trong pubspec.yaml
                  const Icon(Icons.phone_android, size: 100, color: Colors.white),
                  const Text("CHBDT", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
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
                  const Text(
                    "Đăng Nhập",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản? ", style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          "Đăng ký",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                    isPassword: true,
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    text: "Đăng Nhập",
                    onPressed: _handleLogin,
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