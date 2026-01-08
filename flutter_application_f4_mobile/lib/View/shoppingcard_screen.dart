import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import '../Model/cartModel.dart'; // Đảm bảo đúng tên file model của bạn
import '../Controller/cart_Controller.dart';
import 'Widget/custom_button.dart';

class ShoppingCardScreen extends StatefulWidget {
  const ShoppingCardScreen({super.key});

  @override
  State<ShoppingCardScreen> createState() => _ShoppingCardScreenState();
}

class _ShoppingCardScreenState extends State<ShoppingCardScreen> {
  // Khởi tạo Controller
  final CartController _cartController = CartController();
  
  // Biến Future để lưu trữ trạng thái của API
  late Future<CartResponse?> _cartFuture;

  @override
  void initState() {
    super.initState();
    // Gán hàm lấy dữ liệu vào biến Future ngay khi màn hình khởi tạo
    _cartFuture = _cartController.getCartData();
    debugPrint("CART_DATA: ${_cartFuture.toString()}");
  }

  // Hàm làm mới giỏ hàng (Dùng cho RefreshIndicator)
  Future<void> _refreshCart() async {
    setState(() {
      // Gọi lại API để lấy dữ liệu mới nhất (từ Local hoặc Server)
      _cartFuture = _cartController.getCartData();
    });
    // Đợi Future hoàn thành để tắt vòng xoay loading
    await _cartFuture;
  }

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
            _buildHeader(context),
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
                // Sử dụng FutureBuilder thay vì check _isLoading thủ công
                child: FutureBuilder<CartResponse?>(
                  future: _cartFuture,
                  builder: (context, snapshot) {
                    // 1. Trạng thái đang tải
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    // 2. Trạng thái lỗi
                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Đã xảy ra lỗi: ${snapshot.error}"),
                      );
                    }

                    // 3. Trạng thái có dữ liệu nhưng null hoặc rỗng
                    if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _refreshCart,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            alignment: Alignment.center,
                            child: const Text("Giỏ hàng của bạn đang trống"),
                          ),
                        ),
                      );
                    }

                    // 4. Trạng thái thành công -> Hiển thị nội dung
                    return _buildMainContent(snapshot.data!);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị nội dung chính khi có dữ liệu
  Widget _buildMainContent(CartResponse cartData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Shipping address", style: TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 12),
        _buildAddressSection(),
        const SizedBox(height: 24),
        Text("Order list (${cartData.data.length})", style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 12),
        
        // Danh sách sản phẩm (Có thể kéo để refresh)
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshCart,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(), // Luôn cho phép cuộn để refresh hoạt động
              itemCount: cartData.data.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
              itemBuilder: (context, index) => _buildCartItem(cartData.data[index]),
            ),
          ),
        ),

        const SizedBox(height: 16),
        _buildFooterTotal(cartData.totalMoney),
        const SizedBox(height: 16),
        CustomButton(text: "Tiếp tục thanh toán", onPressed: () {}),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item.imageUrl, // Đã đổi tên biến trong Model
            width: 80, height: 80, fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              width: 80, height: 80, color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tên sản phẩm
              Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              
              // 2. Hiển thị thông số: Màu | Ram | Bộ nhớ
              // Sử dụng data từ Model mới (color, ram, storage)
              Text(
                "${item.color} | ${item.ram} | ${item.storage}", 
                style: const TextStyle(color: Colors.grey, fontSize: 14)
              ),
              
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    //_formatPrice(int.parse(item.price)),
                    item.price,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  Text("x${item.quantity}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterTotal(int totalMoney) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Tổng thanh toán:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(_formatPrice(totalMoney), 
             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
      ],
    );
  }

  // --- Các Widget tĩnh giữ nguyên ---
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          const Text("Giỏ hàng", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Row(
      children: [
        const CircleAvatar(backgroundColor: Color(0xFFE8F0FE), child: Icon(Icons.location_on, color: Color(0xFF4285F4))),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Địa chỉ người nhận...", style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.edit, size: 20)),
      ],
    );
  }
}