import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color textColor;
  final bool isLast;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.textColor = Colors.black87, // Mặc định màu đen
    this.isLast = false,             // Mặc định có mũi tên
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryOrange),
      ),
      title: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600, 
          fontSize: 16, 
          color: textColor
        ),
      ),
      // Nếu là mục cuối (như Đăng xuất) thì không hiện mũi tên
      trailing: isLast ? null : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}