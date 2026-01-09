import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import 'Widget/custom_button.dart';
import 'Widget/custom_textfield.dart';
import '../Controller/auth_controller.dart'; 
import '../Model/User.dart'; 

class EditProfileScreen extends StatefulWidget {
  final User? currentUser; 
  const EditProfileScreen({super.key, this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Khởi tạo các controller
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  final AuthController _authController = AuthController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser?.fullname ?? "");
    _emailController = TextEditingController(text: widget.currentUser?.email ?? "");
    _phoneController = TextEditingController(text: widget.currentUser?.phone_number ?? "");
    _addressController = TextEditingController(text: widget.currentUser?.address ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_nameController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tên không được để trống"), backgroundColor: Colors.red));
       return;
    }

    setState(() => _isLoading = true); 

    bool isSuccess = await _authController.updateProfile(
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    setState(() => _isLoading = false); 

    if (isSuccess) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thành công!"), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thất bại"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;

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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        "Chỉnh sửa thông tin",
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    CustomTextField(
                       label: "Email (Không thể sửa)", 
                       hint: user?.email ?? "Email",
                       controller: _emailController,
                       readOnly: true,
                    ),

                    CustomTextField(
                      label: "Họ và Tên", 
                      hint: user?.fullname ?? "Nhập tên...",
                      controller: _nameController
                    ),

                    CustomTextField(
                      label: "Số điện thoại", 
                      hint: user?.phone_number ?? "Nhập sđt...",
                      controller: _phoneController, 
                      keyboardType: TextInputType.phone
                    ),

                    CustomTextField(
                      label: "Địa chỉ", 
                      hint: user?.address ?? "Nhập địa chỉ...",
                      controller: _addressController
                    ),

                    const SizedBox(height: 30),
                    
                    CustomButton(
                      text: _isLoading ? "Đang xử lý..." : "Xác nhận", 
                      onPressed: _isLoading ? () {} : _handleSave,
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