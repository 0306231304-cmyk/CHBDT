import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'my_orders_screen.dart'; 
import 'widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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
          // --- HEADER ---
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
                const Text(
                  "Lois Becket",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Loisbecket@gmail.com",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // --- MENU ---
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
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
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
                      icon: Icons.location_on_outlined, 
                      text: "Địa chỉ của tôi", 
                      onTap: () {}
                    ),
                    
                    ProfileMenuItem(
                      icon: Icons.card_giftcard, 
                      text: "Đơn hàng của tôi", 
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
                    ),

                    ProfileMenuItem(
                      icon: Icons.logout,
                      text: "Đăng xuất",
                      textColor: Colors.red,
                      isLast: true, // Ẩn mũi tên
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
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