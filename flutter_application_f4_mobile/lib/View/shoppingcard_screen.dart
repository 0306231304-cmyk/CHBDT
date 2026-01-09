import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import '../Model/cartModel.dart'; 
import '../Model/update_cart_model.dart';
import '../Controller/cart_Controller.dart';
import '../Controller/update_cart_controller.dart'; // <--- IMPORT MỚI
import 'Widget/custom_button.dart';


class ShoppingCardScreen extends StatefulWidget {
  const ShoppingCardScreen({super.key});

  @override
  State<ShoppingCardScreen> createState() => _ShoppingCardScreenState();
}

class _ShoppingCardScreenState extends State<ShoppingCardScreen> {
  // Khởi tạo Controller Lấy dữ liệu
  final CartController _cartController = CartController();
  
  // Khởi tạo Controller Cập nhật (Tăng/Giảm) ---> MỚI
  final UpdateCartController _updateCartController = UpdateCartController();
  
  // Biến Future để lưu trữ trạng thái của API
  late Future<CartResponse?> _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = _cartController.getCartData();
  }

  // Hàm làm mới giỏ hàng (Dùng cho RefreshIndicator và sau khi Update)
  Future<void> _refreshCart() async {
    setState(() {
      _cartFuture = _cartController.getCartData();
    });
    await _cartFuture;
  }

  // --- HÀM XỬ LÝ TĂNG GIẢM SỐ LƯỢNG (MỚI) ---
  Future<void> _handleUpdateQuantity(int variantId, int currentQty, bool isIncrease) async {
    // 1. Tính toán số lượng mới
    int newQty = isIncrease ? currentQty + 1 : currentQty - 1;

    // 2. Chặn không cho giảm xuống dưới 1
    if (newQty < 1) return; 

    // 3. Gọi API (Hiển thị loading nhẹ hoặc chặn click liên tục nếu cần)
    // Ở đây mình làm đơn giản là gọi thẳng API
    bool success = await _updateCartController.updateCartQuantity(variantId, newQty);

    if (success) {
      // 4. Nếu thành công -> Reload lại trang để cập nhật tổng tiền và số lượng
      await _refreshCart();
    } else {
      // 5. Nếu lỗi -> Báo user
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi cập nhật số lượng! Vui lòng kiểm tra mạng."), backgroundColor: Colors.red),
        );
      }
    }
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
                child: FutureBuilder<CartResponse?>(
                  future: _cartFuture,
                  builder: (context, snapshot) {
                    // 1. Loading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    // 2. Lỗi
                    if (snapshot.hasError) {
                      return Center(child: Text("Đã xảy ra lỗi: ${snapshot.error}"));
                    }

                    // 3. Rỗng
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

                    // 4. Có dữ liệu
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
        
        // Danh sách sản phẩm
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshCart,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
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
        // Ảnh sản phẩm
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item.imageUrl,
            width: 80, height: 80, fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              width: 80, height: 80, color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Thông tin và nút tăng giảm
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên SP
              Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              
              // Thông số kỹ thuật
              Text(
                "${item.color} | ${item.ram} | ${item.storage}", 
                style: const TextStyle(color: Colors.grey, fontSize: 14)
              ),
              
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Giá tiền
                  Text(
                    item.price, // Hiển thị giá string từ API (VD: "20.000.000")
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 16)
                  ),
                  
                  // --- CỤM NÚT TĂNG GIẢM (SỬA LẠI PHẦN NÀY) ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Row(
                      children: [
                        // Nút TRỪ
                        InkWell(
                          onTap: () => _handleUpdateQuantity(item.productVariantId, item.quantity, false),
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.remove, size: 18, color: Colors.black54),
                          ),
                        ),
                        
                        // Số lượng
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "${item.quantity}", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                          ),
                        ),
                        
                        // Nút CỘNG
                        InkWell(
                          onTap: () => _handleUpdateQuantity(item.productVariantId, item.quantity, true),
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.add, size: 18, color: AppColors.primaryOrange),
                          ),
                        ),
                      ],
                    ),
                  )
                  // --------------------------------------------
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
        Text(
          _formatPrice(totalMoney), 
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)
        ),
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