import 'package:flutter/material.dart';
import 'package:flutter_application_f4_mobile/Controller/cart_Controller.dart';
import 'package:flutter_application_f4_mobile/Controller/product_controller.dart';
import 'package:flutter_application_f4_mobile/Model/product_model.dart';
import 'package:intl/intl.dart';
import '../Product/product_detail_screen.dart';

class ProductByCategoryScreen extends StatefulWidget {
  final int category_id;
  final String nameBrands;
  const ProductByCategoryScreen({super.key, required this.category_id, required this.nameBrands}); 

  @override
  State<ProductByCategoryScreen> createState() =>
      _ProductByCategoryScreenState();
}

class _ProductByCategoryScreenState extends State<ProductByCategoryScreen> {

  List<ProductVariant> productVariantByBrandId = [];

  bool _isPageLoading = false;
  Set<int> _loadingCartIds = {};

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  String formatCurrency(double? amount) {
    // locale: 'vi_VN' để dùng dấu chấm phân cách hàng nghìn
    // symbol: '₫' hoặc 'đ' tùy bạn thích
    // decimalDigits: 0 để bỏ số thập phân (vì VND thường không dùng hào/xu)
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return format.format(amount);
  }

  Future<void> getProducts() async {
  setState(() => _isPageLoading = true);

  final products = await ProductController.getAllProductVariants();

  if (!mounted) return;

  productVariantByBrandId.clear();

  for (var product in products) {
    if (product.brandId == widget.category_id) {
      productVariantByBrandId.add(product);
    }
  }

  setState(() => _isPageLoading = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.nameBrands,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return _isPageLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: productVariantByBrandId.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth > 1200 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    constraints.maxWidth > 1200 ? 0.9 : 0.75,
              ),
              itemBuilder: (context, index) {
                final product = productVariantByBrandId[index];
                return _buildProductCard(product);
              },
            ),
          );
        },
      ),
    );
  }
 /* ======================= CARD GIỐNG HOME ======================= */
  Widget _buildProductCard(ProductVariant variant) {
    return GestureDetector(
      onTap: () {
        // Xử lý chuyển trang chi tiết (cần sửa lại tham số truyền đi nếu trang chi tiết chưa hỗ trợ variant)
        // Navigator.push(...);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hình ảnh sản phẩm
                Expanded(
                  child: Center(
                    child: Image.network(
                      headers: const {"ngrok-skip-browser-warning": "true",},
                      variant.imageUrl ?? "", // Dùng ảnh của variant
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // Hiển thị Tên + Màu + RAM/ROM (Tùy bạn format)
                            "${variant.name}", 
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            // Hiển thị Tên + Màu + RAM/ROM (Tùy bạn format)
                            "${variant.color}", 
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.amberAccent
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${formatCurrency(variant.price)}", // Dùng giá của variant
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                            ),
                          ),
                          Material(
                            color: Colors.orange.withOpacity(0.1), // 1. Đưa màu nền ra Material
                            borderRadius: BorderRadius.circular(8), // 2. Bo góc cho khối Material
                            child: InkWell(
                                onTap: _loadingCartIds.contains(variant.id)
                                    ? null
                                    : () async {
                                        setState(() => _loadingCartIds.add(variant.id));

                                        await CartController.addToCart(null, variant.id);

                                        if (!mounted) return;

                                        setState(() => _loadingCartIds.remove(variant.id));

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Đã thêm ${variant.name} ${variant.color} vào giỏ hàng",
                                            ),
                                            duration: const Duration(seconds: 1),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  child: _loadingCartIds.contains(variant.id)
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(
                                          Icons.add_shopping_cart,
                                          size: 16,
                                          color: Colors.orange,
                                        ),
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
             const SizedBox(), 
          ],
        ),
      ),
    );
  }
}