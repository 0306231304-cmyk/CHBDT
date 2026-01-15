import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import Model, Controller và Detail Screen
import '../../Model/product_model.dart';
import '../../Controller/cart_Controller.dart'; 
import '../Product/product_detail_screen.dart';

class AllProductsScreen extends StatelessWidget {
  final List<ProductVariant> products;

  const AllProductsScreen({
    super.key,
    required this.products,
  });

  // Helper format tiền
  String formatCurrency(double? price) {
    if (price == null) return "0₫";
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return format.format(price);
  }

  // Header cho ảnh (Fix lỗi ảnh ngrok)
  final Map<String, String> _imageHeaders = const {
    "ngrok-skip-browser-warning": "true",
  };

  @override
  Widget build(BuildContext context) {
    // --- TÍNH TOÁN CỘT (RESPONSIVE) ĐỒNG BỘ VỚI HOME ---
    final screenWidth = MediaQuery.of(context).size.width;

    // Logic số cột: Web to (5), Tablet (4), Mobile (2)
    int crossAxisCount = screenWidth >= 1200 ? 5 : screenWidth >= 800 ? 4 : 2;
    
    // Tỷ lệ khung hình: Tablet/Web (0.72), Mobile (0.70)
    double childAspectRatio = screenWidth >= 800 ? 0.72 : 0.70;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tất cả sản phẩm", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white, // Đổi sang trắng cho đồng bộ với Home
      body: products.isEmpty
          ? const Center(child: Text("Chưa có sản phẩm nào"))
          : GridView.builder(
              padding: const EdgeInsets.all(16), // Padding giống Home
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 12, // Khoảng cách ngang
                mainAxisSpacing: 12,  // Khoảng cách dọc
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final variant = products[index];
                // Gọi Widget Card có hiệu ứng Hover
                return _HoverProductCard(
                  variant: variant,
                  imageHeaders: _imageHeaders,
                  formatCurrency: formatCurrency,
                );
              },
            ),
    );
  }
}

// --- WIDGET CARD MỚI (CÓ HIỆU ỨNG HOVER + VIỀN ĐEN) ---
// Được copy logic từ Home sang để đảm bảo đồng bộ 100%
class _HoverProductCard extends StatefulWidget {
  final ProductVariant variant;
  final Map<String, String> imageHeaders;
  final Function(double?) formatCurrency;

  const _HoverProductCard({
    required this.variant,
    required this.imageHeaders,
    required this.formatCurrency,
  });

  @override
  State<_HoverProductCard> createState() => _HoverProductCardState();
}

class _HoverProductCardState extends State<_HoverProductCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Bắt sự kiện chuột
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Chuyển trang chi tiết
          if (widget.variant.productId != null) {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  productId: widget.variant.productId!,
                  productVariantId: widget.variant.id,
                ),
              ),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            // VIỀN: Hover -> Đen, Bình thường -> Xám nhạt
            border: Border.all(
              color: _isHovering ? Colors.black : Colors.grey.shade200, 
              width: _isHovering ? 1.5 : 1
            ),
            // BÓNG: Hover -> Đậm hơn
            boxShadow: [
              BoxShadow(
                color: _isHovering ? Colors.black.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                blurRadius: _isHovering ? 10 : 5,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Ảnh sản phẩm
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.white,
                    child: Image.network(
                      widget.variant.imageUrl ?? '',
                      headers: widget.imageHeaders,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  ),
                ),
              ),
              
              // 2. Thông tin Text
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.variant.name ?? "Sản phẩm", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis
                    ),
                    const SizedBox(height: 4),
                    if (widget.variant.color != null)
                      Text(widget.variant.color!, style: const TextStyle(fontSize: 11, color: Colors.orange)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.formatCurrency(widget.variant.price), 
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)
                        ),
                        
                        // Nút giỏ hàng: Hover -> Đen
                        InkWell(
                          onTap: () async {    
                             await CartController.addToCart(widget.variant.id,1);
                             if (context.mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                 content: Text("Đã thêm ${widget.variant.name} vào giỏ"), 
                                 duration: const Duration(seconds: 1),
                               ));
                             }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              // Đổi màu nền nút khi Hover Card
                              color: _isHovering ? Colors.black : Colors.white, 
                              shape: BoxShape.circle,
                              border: Border.all(color: _isHovering ? Colors.black : Colors.orange)
                            ),
                            child: Icon(
                              Icons.add_shopping_cart, 
                              size: 18, 
                              // Đổi màu icon
                              color: _isHovering ? Colors.white : Colors.orange
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}