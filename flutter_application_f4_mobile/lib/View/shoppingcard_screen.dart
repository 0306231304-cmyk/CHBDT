import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../resources/app_colors.dart';
import '../Model/cartModel.dart'; 
import '../Controller/cart_Controller.dart';
import '../Controller/update_cart_controller.dart'; 
import 'Widget/custom_button.dart';

class ShoppingCardScreen extends StatefulWidget {
  const ShoppingCardScreen({super.key});

  @override
  State<ShoppingCardScreen> createState() => _ShoppingCardScreenState();
}

class _ShoppingCardScreenState extends State<ShoppingCardScreen> {
  final CartController _cartController = CartController();
  final UpdateCartController _updateCartController = UpdateCartController();
  
  // THAY ĐỔI 1: Không dùng Future, dùng biến chứa dữ liệu trực tiếp
  CartResponse? _cartData;
  bool _isLoadingInitial = true; // Chỉ loading lần đầu tiên vào màn hình

  String formatCurrency(double? amount) {
    // locale: 'vi_VN' để dùng dấu chấm phân cách hàng nghìn
    // symbol: '₫' hoặc 'đ' tùy bạn thích
    // decimalDigits: 0 để bỏ số thập phân (vì VND thường không dùng hào/xu)
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return format.format(amount);
  }

  @override
  void initState() {
    super.initState();
    _firstLoad();
  }

  // Hàm load dữ liệu lần đầu (Có hiện Loading)
  Future<void> _firstLoad() async {
    try {
      final data = await _cartController.getCartData();
      if (mounted) {
        setState(() {
          _cartData = data;
          _isLoadingInitial = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingInitial = false;
        });
      }
    }
  }

  // Hàm load lại dữ liệu ngầm (KHÔNG hiện loading, dùng để cập nhật tổng tiền sau khi tăng giảm)
  Future<void> _refreshCartSilent() async {
    final data = await _cartController.getCartData();
    if (mounted && data != null) {
      setState(() {
        _cartData = data;
      });
    }
  }

  // --- HÀM XỬ LÝ TĂNG GIẢM SỐ LƯỢNG (SỬA LẠI: OPTIMISTIC UPDATE) ---
  Future<void> _handleUpdateQuantity(int index, int variantId, int currentQty, bool isIncrease) async {
    // 1. Tính toán số lượng mới
    int newQty = isIncrease ? currentQty + 1 : currentQty - 1;
    if (newQty < 1) return;

    // 2. CẬP NHẬT UI NGAY LẬP TỨC (Không chờ API - Để tránh giật lag)
    setState(() {
      _cartData!.data[index] = _cartData!.data[index].copyWith(quantity: newQty);
      // Lưu ý: Nếu Model CartItem của bạn không có copyWith, hãy gán trực tiếp:
      // _cartData!.data[index].quantity = newQty;
    });

    // 3. Gọi API cập nhật bên dưới (Background)
    bool success = await _updateCartController.updateCartQuantity(variantId, newQty);

    if (success) {
      // 4. Nếu thành công -> Gọi API lấy dữ liệu mới (để cập nhật Tổng tiền) NHƯNG KHÔNG HIỆN LOADING
      await _refreshCartSilent(); 
    } else {
      // 5. Nếu lỗi -> Hoàn tác lại số lượng cũ trên UI
      if (mounted) {
        setState(() {
           // Revert lại số cũ
           int oldQty = isIncrease ? newQty - 1 : newQty + 1;
           // _cartData!.data[index].quantity = oldQty; // Dùng dòng này nếu model ko có copyWith
           _cartData!.data[index] = _cartData!.data[index].copyWith(quantity: oldQty);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi cập nhật! Kiểm tra kết nối."), backgroundColor: Colors.red),
        );
      }
    }
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
                // THAY ĐỔI 2: Không dùng FutureBuilder nữa, dùng if/else check biến state
                child: _buildBodyContent(), 
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    // 1. Đang loading lần đầu
    if (_isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Dữ liệu null hoặc rỗng
    if (_cartData == null || _cartData!.data.isEmpty) {
      return RefreshIndicator(
        onRefresh: _firstLoad, // Kéo xuống để reload lại từ đầu
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

    // 3. Có dữ liệu -> Hiển thị list
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Shipping address", style: TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 12),
        _buildAddressSection(),
        const SizedBox(height: 24),
        Text("Order list (${_cartData!.data.length})", style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 12),
        
        Expanded(
          child: RefreshIndicator(
            onRefresh: _firstLoad,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _cartData!.data.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
              // Truyền thêm index để biết đang sửa item nào
              itemBuilder: (context, index) => _buildCartItem(_cartData!.data[index], index),
            ),
          ),
        ),

        const SizedBox(height: 16),
        _buildFooterTotal(_cartData!.totalMoney),
        const SizedBox(height: 16),
        CustomButton(text: "Tiếp tục thanh toán", onPressed: () {}),
      ],
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            headers: const {"ngrok-skip-browser-warning": "true",},
            item.imageUrl ?? '',
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
              Text(item.productName ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                "${item.color} | ${item.ram} | ${item.storage}", 
                style: const TextStyle(color: Colors.grey, fontSize: 14)
              ),
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                  formatCurrency(item.price), 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 16)
                  ),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          // Truyền index vào để cập nhật đúng item trong List
                          onTap: () => _handleUpdateQuantity(index, item.productVariantId ?? 0, item.quantity ?? 0, false),
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.remove, size: 18, color: Colors.black54),
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "${item.quantity}", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                          ),
                        ),
                        
                        InkWell(
                          onTap: () => _handleUpdateQuantity(index, item.productVariantId ?? 0, item.quantity ?? 0, true),
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.add, size: 18, color: AppColors.primaryOrange),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterTotal(double totalMoney) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Tổng thanh toán:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
          formatCurrency(totalMoney), 
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)
        ),
      ],
    );
  }

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