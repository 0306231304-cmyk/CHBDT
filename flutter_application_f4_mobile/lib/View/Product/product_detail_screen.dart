import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// --- IMPORT CONTROLLER & MODEL ---
import '../../Controller/product_controller.dart';
import '../../Controller/favorite_controller.dart';
import '../../Controller/cart_Controller.dart';
import '../../Model/product_model.dart';
import '../../Model/review_model.dart';
import '../../Config/baseUrl.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final int? productVariantId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.productVariantId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product?> _productFuture;
  
  // SỬA 1: Đổi kiểu dữ liệu thành ReviewData? để khớp với Controller
  late Future<ReviewData?> _reviewsFuture;
  
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 5.0;
  bool _isSendingComment = false;

  ProductVariant? _selectedVariant;
  int qty = 1;
  bool isFav = false;

  final Map<String, String> _imageHeaders = const {
    "ngrok-skip-browser-warning": "true",
  };

  // Helper xử lý ảnh
  String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return "https://via.placeholder.com/300";
    if (path.startsWith("http")) return path;
    String cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    String cleanPath = path.startsWith('/') ? path : '/$path';
    return "$cleanBase$cleanPath";
  }

  // Helper xử lý thông số kỹ thuật
  String getSpecValue(String? variantValue, String? productValue) {
    if (variantValue != null && variantValue.isNotEmpty && variantValue != "null") {
      return variantValue;
    }
    if (productValue != null && productValue.isNotEmpty && productValue != "null") {
      return productValue;
    }
    return "Đang cập nhật";
  }

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _productFuture = ProductController.getProductById(widget.productId);
    _reviewsFuture = ProductController.getReviews(widget.productId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    if (_commentController.text.trim().isEmpty) return;
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('user_token');

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bạn cần đăng nhập để bình luận!")),
        );
      }
      return;
    }

    setState(() => _isSendingComment = true);
    
    bool success = await ProductController.postReview(
      widget.productId,
      _commentController.text,
      _userRating,
    );

    if (mounted) {
      setState(() => _isSendingComment = false);
      if (success) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
        // Load lại danh sách review
        setState(() {
          _reviewsFuture = ProductController.getReviews(widget.productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gửi đánh giá thành công!"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gửi thất bại! Vui lòng thử lại."), backgroundColor: Colors.red));
      }
    }
  }

  String formatCurrency(double? price) {
    if (price == null) return "0 đ";
    final format = NumberFormat("#,###", "vi_VN");
    return "${format.format(price)} đ";
  }

  void _checkFavoriteStatus() async {
    bool status = await FavoriteController.checkIsFavorite(widget.productId);
    if (mounted) setState(() => isFav = status);
  }

  void _onFavoritePressed() async {
    bool oldStatus = isFav;
    setState(() => isFav = !isFav);
    bool success;
    if (oldStatus == false) {
      success = await FavoriteController.addFavorite(widget.productId);
    } else {
      success = await FavoriteController.removeFavorite(widget.productId);
    }
    if (!success && mounted) setState(() => isFav = oldStatus);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: FutureBuilder<Product?>(
          future: _productFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("Không tìm thấy thông tin sản phẩm"));
            }

            final Product product = snapshot.data!;
            final List<ProductVariant> variants = product.variants ?? [];

            if (variants.isEmpty) {
               return Scaffold(
                 appBar: AppBar(title: Text(product.name)), 
                 body: const Center(child: Text("Sản phẩm chưa có tùy chọn nào."))
               );
            }

            if (_selectedVariant == null) {
               if (widget.productVariantId != null) {
                  try {
                    _selectedVariant = variants.firstWhere((v) => v.id == widget.productVariantId);
                  } catch (e) {
                    _selectedVariant = variants[0];
                  }
               } else {
                  _selectedVariant = variants[0];
               }
            }

            final displayVariant = _selectedVariant ?? variants[0];
            String displayImage = getFullImageUrl(displayVariant.imageUrl);
            double displayPrice = displayVariant.price ?? 0;
            int displayStock = displayVariant.stockQuantity ?? 0;

            return Stack(
              children: [
                // 1. ẢNH SẢN PHẨM
                Positioned(
                  top: 0, left: 0, right: 0, height: size.height * 0.45,
                  child: Container(
                    color: const Color(0xFFF5F5F5),
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Image.network(
                      displayImage,
                      headers: _imageHeaders,
                      fit: BoxFit.contain,
                      errorBuilder: (_,__,___) => const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                    ),
                  ),
                ),

                // 2. NÚT BACK
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10, left: 16, right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                      _circleButton(isFav ? Icons.favorite : Icons.favorite_border, _onFavoritePressed, color: isFav ? Colors.deepOrange : Colors.black),
                    ],
                  ),
                ),

                // 3. NỘI DUNG CUỘN
                Positioned(
                  top: size.height * 0.4, left: 0, right: 0, bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                          const SizedBox(height: 20),

                          // Tên và Kho
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  displayVariant.name ?? product.name,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  children: [
                                    const Text("Kho", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    Text("$displayStock", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Chọn màu
                          if (variants.length > 1) ...[
                            Wrap(
                              spacing: 8, runSpacing: 8,
                              children: List.generate(variants.length, (index) {
                                final variant = variants[index];
                                final isSelected = _selectedVariant?.id == variant.id;
                                return GestureDetector(
                                  onTap: () => setState(() { _selectedVariant = variant; qty = 1; }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.deepOrange : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade300),
                                    ),
                                    child: Text(
                                      "${variant.color ?? 'Màu ${index + 1}'}",
                                      style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 20),
                          ],

                          const Text("Mô tả sản phẩm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                            displayVariant.description ?? product.description,
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.5),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 20),

                          // Thông số kỹ thuật
                          const Text("Thông số kỹ thuật", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                _specRow(Icons.phone_android, "Màn hình", getSpecValue(displayVariant.screenSize, product.screenSize)),
                                _specRow(Icons.camera_alt, "Camera", getSpecValue(displayVariant.camera, product.camera)),
                                _specRow(Icons.memory, "CPU", getSpecValue(displayVariant.cpu, product.cpu)),
                                _specRow(Icons.battery_charging_full, "Pin", getSpecValue(displayVariant.battery, product.battery)),
                                _specRow(Icons.storage, "RAM", getSpecValue(displayVariant.ram, null)), 
                                _specRow(Icons.sd_storage, "Bộ nhớ", getSpecValue(displayVariant.storage, null), isLast: true),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),
                          const Divider(thickness: 4, color: Color(0xFFEEEEEE)),
                          const SizedBox(height: 20),

                          // --- ĐÁNH GIÁ & BÌNH LUẬN ---
                          const Text("Đánh giá & Bình luận", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Đánh giá của bạn:", style: TextStyle(fontWeight: FontWeight.w500)),
                                Row(
                                  children: List.generate(5, (index) {
                                    return IconButton(
                                      icon: Icon(index < _userRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 28),
                                      onPressed: () => setState(() => _userRating = index + 1.0),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    );
                                  }),
                                ),
                                TextField(
                                  controller: _commentController,
                                  decoration: const InputDecoration(hintText: "Viết cảm nhận...", border: InputBorder.none, isDense: true),
                                  maxLines: 2,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const Divider(),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: _isSendingComment ? null : _submitReview,
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size(80, 36)),
                                    child: _isSendingComment 
                                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text("Gửi", style: TextStyle(color: Colors.white)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- DANH SÁCH REVIEW (SỬA LỖI REVIEW DATA) ---
                          FutureBuilder<ReviewData?>(
                            future: _reviewsFuture, // Đã đổi sang Future<ReviewData?>
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                              
                              final reviewData = snapshot.data;
                              // Kiểm tra null và list rỗng
                              if (reviewData == null || reviewData.rows.isEmpty) {
                                return const Text("Chưa có đánh giá nào.", style: TextStyle(color: Colors.grey));
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: reviewData.rows.length, // Lấy length từ rows
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  // Lấy từng item ReviewItem
                                  final review = reviewData.rows[index];
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.grey.shade200,
                                        // ReviewItem không có avatarUrl, dùng icon mặc định
                                        child: const Icon(Icons.person, color: Colors.grey, size: 16),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // ReviewItem dùng 'fullname'
                                                Text(review.fullname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                if (review.createdAt != null)
                                                  Text(DateFormat('dd/MM/yyyy').format(review.createdAt!), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                              ],
                                            ),
                                            Row(children: List.generate(5, (s) => Icon(Icons.star, size: 12, color: s < review.rating ? Colors.amber : Colors.grey.shade300))),
                                            const SizedBox(height: 4),
                                            // ReviewItem dùng 'comment'
                                            Text(review.comment, style: const TextStyle(fontSize: 13)),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. BOTTOM BAR - NÚT BÊN PHẢI (THEO YÊU CẦU)
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -3))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                        // --- TRÁI: GIÁ TIỀN ---
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Tổng cộng", style: TextStyle(color: Colors.grey, fontSize: 11)),
                            Text(
                              formatCurrency(displayPrice * qty),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                            ),
                          ],
                        ),

                        // --- PHẢI: CỤM THAO TÁC ([- 1 +] và [THÊM]) ---
                        Row(
                          children: [
                            // Nút tăng giảm
                            Container(
                              height: 36,
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(18)),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                children: [
                                  _qtyBtn(Icons.remove, () { if (qty > 1) setState(() => qty--); }),
                                  SizedBox(width: 20, child: Center(child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
                                  _qtyBtn(Icons.add, () { if (qty < displayStock) setState(() => qty++); }),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 10),

                            // Nút Thêm giỏ hàng
                            ElevatedButton.icon(
                              onPressed: displayStock > 0 ? () async {
                                if (_selectedVariant != null) {
                                  await CartController.addToCart(_selectedVariant!.id, qty);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã thêm $qty sản phẩm vào giỏ"), backgroundColor: Colors.green));
                                }
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                              label: const Text("Thêm", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onPressed, {Color color = Colors.black}) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: IconButton(icon: Icon(icon, color: color, size: 20), onPressed: onPressed),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(6), child: Icon(icon, size: 16, color: Colors.black87)));
  }

  Widget _specRow(IconData icon, String title, String? value, {bool isLast = false}) {
    String displayValue = (value == null || value.isEmpty || value == "null") ? "Đang cập nhật" : value;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              SizedBox(width: 80, child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13))),
              Expanded(
                child: Text(
                  displayValue, 
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                  softWrap: true, 
                )
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey.shade200, indent: 12, endIndent: 12),
      ],
    );
  }
}