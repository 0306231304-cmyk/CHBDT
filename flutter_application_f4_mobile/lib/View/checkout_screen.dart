import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import 'Widget/custom_button.dart';
import 'thanhtoanok_screen.dart';
import '../Model/order_model.dart'; 

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Dữ liệu mẫu khởi tạo từ Model
  final OrderModel myOrder = OrderModel(
    receiverName: "Liêm",
    phoneNumber: "0366146741",
    address: "No 46, Awolowo Road....",
    items: [
      OrderItem(
        id: "ip17",
        name: "Điện thoại IPhone 17 256GB",
        variant: "Màu tím oải hương",
        price: 27740000,
        quantity: 1,
        image: "assets/iphone17.png",
      ),
    ],
    totalAmount: 27740000,
    note: "Giao hàng giờ hành chính",
  );

  bool _isEWallet = false;
  bool _isCOD = false;

  String _formatPrice(int price) {
    return "${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOrange,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- Header ---
            _buildHeader(context),

            // --- Body: Container bo góc trắng ---
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Thông tin người nhận
                      _buildSectionTitle("Thông tin người nhận"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Người nhận: ${myOrder.receiverName}", 
                                  style: const TextStyle(color: Colors.grey, fontSize: 16)),
                              Text("SĐT: ${myOrder.phoneNumber}", 
                                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
                            ],
                          ),
                          const Icon(Icons.edit, size: 20, color: Colors.black),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 2. Địa chỉ
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFFF0F2F5),
                            child: Icon(Icons.location_on, color: Colors.black, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Địa chỉ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(myOrder.address, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit, size: 20, color: Colors.black),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 3. Danh sách sản phẩm
                      _buildProductItem(myOrder.items[0]),
                      
                      const SizedBox(height: 16),
                      // Ghi chú
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Ghi chú: ${myOrder.note ?? ""}", style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 4),
                          const Icon(Icons.assignment_outlined, size: 20, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 4. Phương thức thanh toán
                      const Text("Phương thức thanh toán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      _buildCheckboxTile("Ví điện tử", _isEWallet, (val) => setState(() => _isEWallet = val!)),
                      _buildCheckboxTile("Thanh toán khi nhận hàng", _isCOD, (val) => setState(() => _isCOD = val!)),

                      const SizedBox(height: 30),

                      // 5. Tổng tiền
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tổng tiền", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(
                            _formatPrice(myOrder.totalAmount).replaceAll('đ', ''), 
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 6. Nút Thanh toán
                      CustomButton(
                        text: "Thanh toán",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ThanhToanOkScreen()),
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
      ),
    );
  }

  Widget _buildProductItem(OrderItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.image,
              width: 70, height: 70, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const Icon(Icons.phone_iphone, size: 40),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                if (item.variant != null)
                  Row(
                    children: [
                      Text(item.variant!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                    ],
                  ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatPrice(item.price),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
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
            "Thông tin đơn hàng",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildCheckboxTile(String title, bool value, Function(bool?) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}