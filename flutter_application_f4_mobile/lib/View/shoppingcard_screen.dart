import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import 'Widget/custom_button.dart';

class ShoppingCardScreen extends StatefulWidget {
  const ShoppingCardScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingCardScreen> createState() => _ShoppingCardScreenState();
}

class _ShoppingCardScreenState extends State<ShoppingCardScreen> {
  // Dữ liệu giả mô phỏng theo hình Figma
  final List<Map<String, dynamic>> _cartItems = [
    {"name": "iphone 13", "price": 10000000, "qty": 1, "image": "assets/iphone13.png"},
    {"name": "iphone 17", "price": 27740000, "qty": 3, "image": "assets/iphone17.png"},
    {"name": "iphone Air", "price": 27740000, "qty": 2, "image": "assets/iphone_air.png"},
  ];

  String _formatPrice(int price) {
    return "${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOrange,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Nút back và Tiêu đề
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    "Giỏ hàng",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),

            // Nội dung chính
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. Shipping Address ---
                    const Text("Shipping address", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFE8F0FE),
                          child: Icon(Icons.location_on, color: Color(0xFF4285F4)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Home", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("No 46, Awolowo Road....", style: TextStyle(color: Colors.grey, fontSize: 14)),
                            ],
                          ),
                        ),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.edit, size: 20)),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text("Order list", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 12),

                    // --- 2. Danh sách sản phẩm ---
                    Expanded(
                      child: ListView.separated(
                        itemCount: _cartItems.length,
                        separatorBuilder: (context, index) => const Divider(height: 32),
                        itemBuilder: (context, index) => _buildCartItem(_cartItems[index], index),
                      ),
                    ),

                    // --- 3. Nút Tiếp tục ---
                    const SizedBox(height: 16),
                    CustomButton(
                      text: "Tiếp tục",
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hình ảnh sản phẩm (Container xám nhạt như Figma)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: item['image'].contains("assets") 
            ? Image.asset(item['image'], errorBuilder: (c, e, s) => const Icon(Icons.image)) 
            : const Icon(Icons.phone_iphone),
        ),
        const SizedBox(width: 16),
        
        // Thông tin & bộ tăng giảm
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['name'], style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  GestureDetector(
                    onTap: () => setState(() => _cartItems.removeAt(index)),
                    child: const Icon(Icons.delete, color: Colors.grey, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Giá ${_formatPrice(item['price'])}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  // Bộ tăng giảm số lượng kiểu Figma
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black87),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _qtyAction(Icons.remove, () {
                          if (item['qty'] > 1) setState(() => item['qty']--);
                        }),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          color: Colors.grey.shade300,
                          child: Text("${item['qty']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        _qtyAction(Icons.add, () => setState(() => item['qty']++)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qtyAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Icon(icon, size: 16),
      ),
    );
  }
}