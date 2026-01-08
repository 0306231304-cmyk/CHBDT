import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import '../Model/User.dart';
import '../Controller/auth_controller.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'order_history_screen.dart';
import 'Widget/profile_menu_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController _authController = AuthController();
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _authController.getProfile();
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
      body: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Không tải được thông tin", style: TextStyle(color: Colors.white)),
                  TextButton(
                    onPressed: () {
                       Navigator.pushAndRemoveUntil(
                        context, 
                        MaterialPageRoute(builder: (_) => const LoginScreen()), 
                        (route) => false
                      );
                    },
                    child: const Text("Đăng nhập lại", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          }

          final User user = snapshot.data!;

          return Column(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, size: 75, color: Colors.grey),
                        ),
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.backgroundOrange, width: 2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.fullname ?? "Chưa đặt tên",
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user.email ?? "No Email",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

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
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.person_outline,
                          text: "Thông tin cá nhân",
                          onTap: () async {
                            final result = await Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (_) => EditProfileScreen(currentUser: user),
                              )
                            );
                            if (result == true) {
                              setState(() {
                                _userFuture = _authController.getProfile();
                              });
                            }
                          },
                        ),
                        
                        ProfileMenuItem(
                          icon: Icons.lock_outline,
                          text: "Đổi mật khẩu",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                        ),

                        ProfileMenuItem(
                          icon: Icons.payment, 
                          text: "Phương thức thanh toán", 
                          onTap: () {}
                        ),
                        
                        ProfileMenuItem(
                          icon: Icons.card_giftcard, 
                          text: "Lịch sử đơn hàng", 
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen())),
                        ),

                        ProfileMenuItem(
                          icon: Icons.logout,
                          text: "Đăng xuất",
                          textColor: Colors.red,
                          isLast: true,
                          onTap: () async {
                            await _authController.logout();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}