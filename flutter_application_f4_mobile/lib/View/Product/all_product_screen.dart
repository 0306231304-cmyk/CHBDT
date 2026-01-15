/*import 'package:flutter/material.dart';
import '../Product/product_detail_screen.dart';
import '../../Resources/app_colors.dart';

class AllProductsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const AllProductsScreen({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 📌 Số cột theo màn hình
    int crossAxisCount = screenWidth >= 1200
        ? 4 // Web lớn
        : screenWidth >= 800
            ? 3 // Tablet / web nhỏ
            : 2; // Mobile

    // 📌 Tỷ lệ card (QUAN TRỌNG)
    double childAspectRatio = screenWidth >= 1200
        ? 0.85
        : screenWidth >= 800
            ? 0.8
            : 0.68; // Mobile → card nhỏ lại

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Featured Products",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (context, index) {
          final p = products[index];

          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            elevation: 3,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product:P),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Expanded(
                      child: Image.asset(
                        p['img'],
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p['price'],
                      style: const TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p['storage'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- IMPORTS ---
import '../../Model/product_model.dart'; // Import Model để hiểu ProductVariant
import '../../Resources/app_colors.dart'; // Import màu sắc
import 'product_detail_screen.dart';

class AllProductsScreen extends StatelessWidget {
  // Nhận vào danh sách ProductVariant thật thay vì Map giả
  final List<ProductVariant> products;

  const AllProductsScreen({
    super.key,
    required this.products,
  });

  // Hàm định dạng tiền tệ (VND)
  String formatCurrency(double? amount) {
    if (amount == null) return "0₫";
    final format = NumberFormat.currency(
        locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Tính toán số cột dựa trên kích thước màn hình
    int crossAxisCount = screenWidth >= 1200
        ? 4
        : screenWidth >= 800
            ? 3
            : 2;

    // Tỷ lệ khung hình card sản phẩm
    double childAspectRatio = screenWidth >= 1200
        ? 0.75
        : screenWidth >= 800
            ? 0.72
            : 0.68;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Featured Products",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      // Kiểm tra nếu không có sản phẩm nào
      body: products.isEmpty
          ? const Center(child: Text("Không có sản phẩm nào"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) {
                final product = products[index];

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 2, // Giảm bóng một chút cho nhẹ nhàng
                  shadowColor: Colors.grey.withOpacity(0.2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // --- SỬA LỖI ĐIỀU HƯỚNG ---
                      // Truyền productId thay vì cả object product
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(
                            productId: product.productId!,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ảnh sản phẩm
                          Expanded(
                            child: Center(
                              child: Image.network(
                                product.imageUrl ?? '',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported,
                                        size: 50, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          // Tên sản phẩm
                          Text(
                            product.name ?? 'Unknown Product',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Giá tiền
                          Text(
                            formatCurrency(product.price),
                            style: const TextStyle(
                              // Dùng màu cam từ file gốc hoặc fallback sang Colors.orange
                              color: Colors.deepOrange, 
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          
                          // Dung lượng (Nếu model có field này thì hiển thị, tạm thời ẩn để tránh lỗi)
                          /*
                          const SizedBox(height: 4),
                          Text(
                            "Storage info here", 
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          */
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}*/


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