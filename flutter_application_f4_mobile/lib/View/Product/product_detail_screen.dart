import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Thêm dòng này
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
  late Future<List<ProductVariant>> _productFuture;
  
  // Biến cho phần bình luận
  ReviewData? _reviewData;
  bool _isLoadingReviews = true;
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 5.0; 
  bool _isSendingComment = false;
  late Future<ReviewData?> _reviewsFuture;

  // Biến state cũ
  ProductVariant? _selectedVariant;
  int qty = 1;
  bool isFav = false;

  final Map<String, String> _imageHeaders = const {
    "ngrok-skip-browser-warning": "true",
  };

  String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return "https://via.placeholder.com/300";
    if (path.startsWith("http")) return path;
    String cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    String cleanPath = path.startsWith('/') ? path : '/$path';
    return "$cleanBase$cleanPath";
  }

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _productFuture = ProductController.getVariantsByProductId(widget.productId);
    //_reviewsFuture = ProductController.getReviews(widget.productId);
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      print(">>> Đang gọi API lấy Review...");
      
      // Lưu ý: Đảm bảo bạn dùng đúng ID (widget.productId hoặc widget.product.id tùy code của bạn)
      var data = await ProductController.getReviews(widget.productId);
      
      if (data == null) {
        print(">>> LỖI: API trả về NULL. Kiểm tra lại: ");
        print("   1. URL API có đúng không?");
        print("   2. Server có đang chạy không?");
        print("   3. JSON trả về có đúng format ReviewResponse không?");
      } else {
        print(">>> THÀNH CÔNG: Lấy được ${data.rows.length} đánh giá.");
        print(">>> Điểm trung bình: ${data.avgRating}");
      }

      if (mounted) {
        setState(() {
          _reviewData = data;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      print(">>> EXCEPTION tại _loadReviews: $e");
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Hàm gửi bình luận
 void _submitReview() async {
    // 1. Kiểm tra rỗng
    if (_commentController.text.trim().isEmpty) return;

    // 2. Kiểm tra đăng nhập
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

    // 3. Gửi đánh giá (SỬA Ở ĐÂY: Dùng thẳng widget.productId)
    setState(() => _isSendingComment = true);

    bool success = await ProductController.postReview(
      widget.productId, // <--- ĐÚNG: Lấy trực tiếp biến này, nó là int sẵn rồi
      _commentController.text,
      _userRating,
    );

    if (mounted) {
      setState(() => _isSendingComment = false);
      
      if (success) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
        // Cập nhật lại list review
        setState(() {
          _reviewsFuture = ProductController.getReviews(widget.productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gửi đánh giá thành công!"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gửi thất bại! Vui lòng thử lại."), backgroundColor: Colors.red),
        );
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
    if (!success && mounted) {
      setState(() => isFav = oldStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder<List<ProductVariant>>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không tìm thấy thông tin sản phẩm"));
          }

          final List<ProductVariant> variants = snapshot.data!;
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
              // 1. ẢNH SẢN PHẨM (NỀN)
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

              // 2. NÚT BACK VÀ TIM
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

              // 3. NỘI DUNG CUỘN (SHEET)
              Positioned(
                top: size.height * 0.4, left: 0, right: 0, bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 100), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                        const SizedBox(height: 20),

                        // Tên sản phẩm
                        Text(displayVariant.name ?? "Tên sản phẩm", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
                        const SizedBox(height: 12),

                        // Chọn phiên bản
                        if (variants.length > 1) ...[
                          Wrap(
                            spacing: 10, runSpacing: 10,
                            children: List.generate(variants.length, (index) {
                              final variant = variants[index];
                              final isSelected = _selectedVariant?.id == variant.id;
                              return GestureDetector(
                                onTap: () => setState(() { _selectedVariant = variant; qty = 1; }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.deepOrange : Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade300),
                                  ),
                                  child: Text("${variant.color ?? 'Màu ${index + 1}'}", style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        const Text("Mô tả sản phẩm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          displayVariant.description ?? "Đang cập nhật mô tả...", 
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.5),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 20),

                        // Thông số kỹ thuật
                        const Text("Thông số kỹ thuật", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200)
                          ),
                          child: Column(
                            children: [
                              _specRow(Icons.phone_android, "Màn hình", displayVariant.screenSize),
                              _specRow(Icons.camera_alt, "Camera", displayVariant.camera),
                              _specRow(Icons.memory, "CPU", displayVariant.cpu),
                              _specRow(Icons.battery_charging_full, "Pin", displayVariant.battery),
                              _specRow(Icons.storage, "RAM", displayVariant.ram),
                              _specRow(Icons.sd_storage, "Bộ nhớ", displayVariant.storage),
                            ],
                          ),
                        ),
                

                        const SizedBox(height: 30), 
                        const Divider(thickness: 4, color: Color(0xFFEEEEEE)), 
                        const SizedBox(height: 20),

                        _buildReviewSection(),

                        // Phần Bình luận
                        const Text("Đánh giá & Bình luận", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Đánh giá sản phẩm:", style: TextStyle(fontWeight: FontWeight.w500)),
                              Row(
                                children: List.generate(5, (index) {
                                  return IconButton(
                                    icon: Icon(index < _userRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 30),
                                    onPressed: () => setState(() => _userRating = index + 1.0),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  );
                                }),
                              ),
                              TextField(
                                controller: _commentController,
                                decoration: const InputDecoration(hintText: "Hãy chia sẻ cảm nhận của bạn...", border: InputBorder.none, isDense: true),
                                maxLines: 3,
                              ),
                              const Divider(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: _isSendingComment ? null : _submitReview,
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size(100, 40)),
                                  child: _isSendingComment 
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text("Gửi đánh giá", style: TextStyle(color: Colors.white)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // =========================================================================
              // 4. BOTTOM BAR MỚI (GIÁ GÓC TRÁI) - (SỐ LƯỢNG + NÚT CÓ CHỮ GÓC PHẢI)
              // =========================================================================
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -3))],
                  ),
                  child: Row(
                    children: [
                      // --- GÓC TRÁI: TỔNG TIỀN ---
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Tổng cộng", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            formatCurrency(displayPrice * qty), 
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)
                          ),
                        ],
                      ),
                      
                      const Spacer(), // Đẩy cụm bên phải ra hết mức

                      // --- GÓC PHẢI: [ - 1 + ] VÀ [NÚT CÓ CHỮ] ---
                      Row(
                        children: [
                          // 1. Khung số lượng
                          Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100, 
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Row(
                              children: [
                                _qtyBtn(Icons.remove, () { if (qty > 1) setState(() => qty--); }),
                                SizedBox(
                                  width: 24, 
                                  child: Center(child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)))
                                ),
                                _qtyBtn(Icons.add, () { if (qty < displayStock) setState(() => qty++); }),
                              ],
                            ),
                          ),

                          // 2. Nút Thêm vào giỏ (CÓ ICON + CHỮ)
                          ElevatedButton.icon(
                            onPressed: displayStock > 0 ? () async {
                              if (_selectedVariant != null) {
                                await CartController.addToCart(null, _selectedVariant!.id);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã thêm $qty sp vào giỏ"), backgroundColor: Colors.green));
                              }
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Padding cho nút
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                            label: const Text(
                              "Thêm vào giỏ", // Chữ hiển thị
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                            ),
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
    );
  }

  // Helper Widgets
  Widget _circleButton(IconData icon, VoidCallback onPressed, {Color color = Colors.black}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: IconButton(icon: Icon(icon, color: color, size: 20), onPressed: onPressed),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(8), child: Icon(icon, size: 18, color: Colors.black87)));
  }

  Widget _specRow(IconData icon, String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
      Icon(icon, size: 18, color: Colors.grey), 
      const SizedBox(width: 10), 
      Text("$title: ", style: const TextStyle(color: Colors.grey, fontSize: 13)), 
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))
    ]));
  }

  // ==================== PHẦN GIAO DIỆN REVIEW ====================

  Widget _buildReviewSection() {
    if (_isLoadingReviews) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    print("DEBUG: $_reviewData");
    // Nếu không có dữ liệu hoặc danh sách rỗng
    if (_reviewData == null || _reviewData!.rows.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            const Text("Chưa có đánh giá nào", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tiêu đề & Thống kê tổng quan
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                "Đánh giá (${_reviewData!.totalRating})",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                "${_reviewData!.avgRating.toStringAsFixed(1)}/5.0 ",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
              const Icon(Icons.star, color: Colors.amber, size: 20),
            ],
          ),
        ),
        
        const SizedBox(height: 10),
        const Divider(height: 1, thickness: 5, color: Color(0xFFF5F5F5)), // Đường kẻ ngăn cách dày
        
        // 2. Danh sách các bình luận
        ListView.separated(
          shrinkWrap: true, // Quan trọng: để nằm trong ScrollView chính
          physics: const NeverScrollableScrollPhysics(), // Không cuộn riêng lẻ
          padding: const EdgeInsets.all(16),
          itemCount: _reviewData!.rows.length,
          separatorBuilder: (ctx, index) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final review = _reviewData!.rows[index];
            return _buildReviewItem(review);
          },
        ),
      ],
    );
  }

  // Widget hiển thị từng dòng comment
  Widget _buildReviewItem(ReviewItem review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar (Lấy chữ cái đầu nếu không có ảnh)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              child: Text(
                review.fullname.isNotEmpty ? review.fullname[0].toUpperCase() : "U",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            
            // Tên và Ngày tháng
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.fullname,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  // Hiển thị sao đánh giá
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          size: 12,
                          color: Colors.amber,
                        );
                      }),
                      const SizedBox(width: 8),
                      if (review.createdAt != null)
                        Text(
                          DateFormat('dd/MM/yyyy').format(review.createdAt!),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Nội dung comment
        Padding(
          padding: const EdgeInsets.only(left: 42), // Thụt đầu dòng cho thẳng với tên
          child: Text(
            review.comment,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
        ),
      ],
    );
  }
}