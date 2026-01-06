import 'package:flutter/material.dart';
import '../../Resources/app_colors.dart';
import 'Widget/custom_button.dart';
import 'checkout_screen.dart'; 
import '../Model/order_model.dart'; 

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _currentAddress = "No 46, Awolowo Road, Ikoyi, Lagos Island";
  
  final List<OrderItem> _cartItems = [
    OrderItem(
      id: "1", 
      name: "iphone 13", 
      price: 10000000, 
      quantity: 1, 
      image: "assets/images/anh7.png",
      variant: "Màu đen"
    ),
    OrderItem(
      id: "2", 
      name: "iphone 17", 
      price: 27740000, 
      quantity: 1, 
      image: "assets/images/anh9.png",
      variant: "Màu tím oải hương"
    ),
  ];

  int get totalCart => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  String _formatPrice(int price) {
    return "${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ";
  }

  // Hàm xử lý xóa sản phẩm (dùng chung cho cả nút X và nút Trừ)
  void _removeItem(String id) {
    setState(() {
      _cartItems.removeWhere((item) => item.id == id);
    });
  }

  void _showEditAddressDialog() {
    TextEditingController addressController = TextEditingController(text: _currentAddress);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Cập nhật địa chỉ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 15),
            TextField(controller: addressController, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 20),
            CustomButton(
              text: "Cập nhật",
              onPressed: () {
                if (addressController.text.isNotEmpty) setState(() => _currentAddress = addressController.text);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOrange,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                padding: const EdgeInsets.all(24),
                child: _cartItems.isEmpty ? _buildEmptyState() : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Địa chỉ nhận hàng", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    _buildAddressSection(),
                    const SizedBox(height: 15),
                    const Text("Danh sách đơn hàng", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) => _buildCartItem(_cartItems[index]),
                      ),
                    ),
                    const Divider(height: 30),
                    _buildSummarySection(),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: "Tiếp tục",
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutScreen())),
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

  Widget _buildAddressSection() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(backgroundColor: Color(0xFFF0F2F5), child: Icon(Icons.location_on, color: Colors.black)),
      title: const Text("Nhà riêng", style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(_currentAddress, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: _showEditAddressDialog),
    );
  }

  Widget _buildSummarySection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Tổng thanh toán:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Text(_formatPrice(totalCart), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
      ],
    );
  }

  Widget _buildCartItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF5F6F8), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Image.asset(item.image, width: 60, height: 60, errorBuilder: (_, __, ___) => const Icon(Icons.phone_iphone)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => _removeItem(item.id),
                      child: const Icon(Icons.close, color: Colors.grey, size: 20),
                    ),
                  ],
                ),
                Text(item.variant ?? "", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatPrice(item.price), style: const TextStyle(fontWeight: FontWeight.w600)),
                    _buildQtyController(item),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyController(OrderItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          // LOGIC: Nếu bấm trừ khi quantity = 1 thì XÓA luôn
          _qtyBtn(Icons.remove, () {
            if (item.quantity > 1) {
              setState(() => item.quantity--);
            } else {
              _removeItem(item.id); // Gọi hàm xóa
            }
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          _qtyBtn(Icons.add, () => setState(() => item.quantity++)),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback action) => InkWell(onTap: action, child: Padding(padding: const EdgeInsets.all(4), child: Icon(icon, size: 18, color: Colors.orange)));

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        const Expanded(child: Center(child: Text("Giỏ hàng", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
          const Text("Giỏ hàng đang trống", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}