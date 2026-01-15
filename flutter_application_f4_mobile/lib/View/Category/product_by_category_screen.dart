import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import Controller & Model
import '../../Controller/cart_Controller.dart';
import '../../Controller/product_controller.dart';
import '../../Model/product_model.dart';

// Import Detail Screen
import '../Product/product_detail_screen.dart';

class ProductByCategoryScreen extends StatefulWidget {
  final int category_id;
  final String nameBrands;
  const ProductByCategoryScreen({
    super.key, 
    required this.category_id, 
    required this.nameBrands
  });

  @override
  State<ProductByCategoryScreen> createState() => _ProductByCategoryScreenState();
}

class _ProductByCategoryScreenState extends State<ProductByCategoryScreen> {
  List<ProductVariant> productVariantByBrandId = [];
  bool _isPageLoading = false;
  
  // Header cho ảnh (Fix lỗi ngrok)
  final Map<String, String> _imageHeaders = const {
    "ngrok-skip-browser-warning": "true",
  };

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  String formatCurrency(double? amount) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return format.format(amount);
  }

  Future<void> getProducts() async {
    setState(() => _isPageLoading = true);
    // Lấy tất cả variant
    final products = await ProductController.getAllProductVariants();

    if (!mounted) return;

    productVariantByBrandId.clear();
    // Lọc theo Brand ID
    for (var product in products) {
      if (product.brandId == widget.category_id) {
        productVariantByBrandId.add(product);
      }
    }
    setState(() => _isPageLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // --- TÍNH TOÁN CỘT (RESPONSIVE GIỐNG HOME) ---
    final screenWidth = MediaQuery.of(context).size.width;

    // Logic số cột: Web to (5), Tablet (4), Mobile (2)
    int crossAxisCount = screenWidth >= 1200 ? 5 : screenWidth >= 800 ? 4 : 2;
    
    // Tỷ lệ khung hình: Tablet/Web (0.72), Mobile (0.70)
    double childAspectRatio = screenWidth >= 800 ? 0.72 : 0.70;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.nameBrands,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isPageLoading
          ? const Center(child: CircularProgressIndicator())
          : productVariantByBrandId.isEmpty
              ? const Center(child: Text("Không có sản phẩm nào thuộc danh mục này"))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: productVariantByBrandId.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // Số cột linh hoạt
                    childAspectRatio: childAspectRatio, // Tỷ lệ chuẩn
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final variant = productVariantByBrandId[index];
                    // Sử dụng Widget Card chuẩn giống Home
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

// --- WIDGET CARD ĐỒNG BỘ VỚI HOME & ALL PRODUCTS ---
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