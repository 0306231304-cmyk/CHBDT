import 'package:flutter/material.dart';
import '../Resources/app_colors.dart'; // Đảm bảo đường dẫn đúng
import '../Model/cartModel.dart';
import '../Controller/cart_Controller.dart';
import '../Controller/update_cart_controller.dart';
import '../Controller/delete_cart_controller.dart'; 
import '../View/Widget/custom_button.dart'; // Đảm bảo đường dẫn đúng

class ShoppingCardScreen extends StatefulWidget {
  const ShoppingCardScreen({super.key});

  @override
  State<ShoppingCardScreen> createState() => _ShoppingCardScreenState();
}

class _ShoppingCardScreenState extends State<ShoppingCardScreen> {
  final CartController _cartController = CartController();
  final UpdateCartController _updateCartController = UpdateCartController();
  final DeleteCartController _deleteCartController = DeleteCartController();

  CartResponse? _cartData;
  bool _isLoadingInitial = true;

  @override
  void initState() {
    super.initState();
    _firstLoad();
  }

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
      if (mounted) setState(() => _isLoadingInitial = false);
    }
  }

  Future<void> _refreshCartSilent() async {
    final data = await _cartController.getCartData();
    if (mounted && data != null) {
      setState(() => _cartData = data);
    }
  }

  // --- HÀM XỬ LÝ XÓA SẢN PHẨM ---
  Future<void> _handleDeleteItem(int index, int variantId) async {
    // 1. Hỏi người dùng
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 2. Gọi API Xóa
    bool success = await _deleteCartController.deleteCartItem(variantId);

    if (success) {
      // 3. Update UI
      setState(() {
        _cartData!.data.removeAt(index);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa sản phẩm"), duration: Duration(seconds: 1)),
      );

      // Tính lại tổng tiền từ server
      _refreshCartSilent();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi xóa sản phẩm!"), backgroundColor: Colors.red),
      );
    }
  }

  // --- HÀM TĂNG GIẢM SỐ LƯỢNG (ĐÃ SỬA LỖI COPYWITH) ---
  Future<void> _handleUpdateQuantity(int index, int variantId, int currentQty, bool isIncrease) async {
    int newQty = isIncrease ? currentQty + 1 : currentQty - 1;

    // Nếu giảm về 0 thì gọi hàm xóa
    if (newQty < 1) {
      _handleDeleteItem(index, variantId);
      return;
    }

    // --- SỬA LỖI Ở ĐÂY: Dùng copyWith thay vì gán trực tiếp ---
    setState(() {
      // Tạo ra object mới với quantity mới và gán đè vào vị trí index
      _cartData!.data[index] = _cartData!.data[index].copyWith(quantity: newQty);
    });
    // ---------------------------------------------------------

    // Gọi API update
    bool success = await _updateCartController.updateCartQuantity(variantId, newQty);
    
    if (success) {
      // Update thành công -> Load lại để lấy tổng tiền mới chuẩn xác
      await _refreshCartSilent();
    } else {
      // Nếu thất bại -> Revert (quay lại số cũ)
      if (mounted) {
        setState(() {
           int oldQty = isIncrease ? newQty - 1 : newQty + 1;
           // Cũng dùng copyWith để revert
           _cartData!.data[index] = _cartData!.data[index].copyWith(quantity: oldQty);
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lỗi cập nhật số lượng!"))
        );
      }
    }
  }

  // Hàm format tiền (Chấp nhận cả int và double)
  String _formatPrice(num? price) {
    if (price == null) return "0đ";
    // toStringAsFixed(0) để bỏ phần thập phân .00 nếu có
    return "${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ";
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
                child: _buildBodyContent(), 
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoadingInitial) return const Center(child: CircularProgressIndicator());
    
    if (_cartData == null || _cartData!.data.isEmpty) {
      return RefreshIndicator(
        onRefresh: _firstLoad,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: const Center(child: Text("Giỏ hàng của bạn đang trống")),
            )
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _firstLoad,
            child: ListView.separated(
              itemCount: _cartData!.data.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
              itemBuilder: (context, index) => _buildCartItem(_cartData!.data[index], index),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Model trả về double, hàm này giờ nhận double
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
        // Ảnh sản phẩm
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item.imageUrl ?? '', // Xử lý null
            width: 80, height: 80, fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(width: 80, height: 80, color: Colors.grey[200]),
          ),
        ),
        const SizedBox(width: 16),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hàng 1: Tên + Thùng rác
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.productName ?? 'Sản phẩm', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () => _handleDeleteItem(index, item.productVariantId ?? 0),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
                      child: Icon(Icons.delete_outline, color: Colors.grey, size: 22),
                    ),
                  )
                ],
              ),
              
              Text(
                "${item.color ?? ''} | ${item.ram ?? ''} | ${item.storage ?? ''}", 
                style: const TextStyle(color: Colors.grey, fontSize: 14)
              ),
              const SizedBox(height: 8),
              
              // Hàng 2: Giá + Tăng giảm
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatPrice(item.price), 
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
                          onTap: () => _handleUpdateQuantity(index, item.productVariantId ?? 0, item.quantity ?? 1, false),
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.remove, size: 18, color: Colors.black54),
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            "${item.quantity ?? 1}", 
                            style: const TextStyle(fontWeight: FontWeight.bold)
                          ),
                        ),
                        
                        InkWell(
                          onTap: () => _handleUpdateQuantity(index, item.productVariantId ?? 0, item.quantity ?? 1, true),
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

  // Model của bạn totalMoney là double -> Sửa tham số thành double
  Widget _buildFooterTotal(double totalMoney) {
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
}