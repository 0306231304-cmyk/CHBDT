
/*import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedColorIndex = 0;
  int qty = 1;

  // ======================= DANH SÁCH SẢN PHẨM KHÁC =======================
  // Bạn có thể thêm/sửa/xóa sản phẩm ở đây
  final List<Map<String, dynamic>> otherProducts = [
    {

      "name": "Xiaomi 12",
      "price": "9.990.000 VND",
      "storage": "128GB",
      "img": "assets/images/anh13.png",
      "tag": "-10%",
      "isFav": false,
      "showQty": false,
      "qty": 0,
      "rating": 4.1,// SAO Ở REVIEW
      "stock": 150,// SỐ LƯỢNG TỒN
      "reviewCount": 50,
      "ratingPercent": {
        5: 0.1,   // 80%
        4: 0.15,  // 12%
        3: 0.01,
        2: 0.03,
        1: 0.06,
      },
      "desc": [
        "Màn hình sắc nét",
        "Pin dung lượng cao"
      ],
      "colors": [Colors.black, const Color.fromARGB(255, 165, 165, 176)],
      "reviewList": [
        {
          "user": "Nguyễn Văn an",
          "star": 5,// đánh giá theo số lượng phần % ở trên
          "content": "Máy rất mượt, pin trâu, camera cực đẹp."
        },
        {
          "user": "Trần Thị diễm chi",
          "star": 4,
          "content": "Thiết kế đẹp, dùng ổn nhưng giá hơi cao."
        },
      ],
    },

    {
      "name": "Iphone 11",
      "price": "10.000.000 VND",
      "storage": "256GB",
      "img": "assets/images/anh8.png",
      "tag": "-5%",
      "isFav": false,
      "showQty": false,
      "qty": 0,
      "rating": 4.1,
      "stock": 150,
      "reviewCount": 100,
      "ratingPercent": {
        5: 0.10,   // 80%
        4: 0.16,  // 12%
        3: 0.06,
        2: 0.03,
        1: 0.02,
      },
      "desc": [
        "Màn hình độ phân giải cao",
        "Pin dung lượng cao"
      ],
      "colors": [const Color.fromARGB(255, 250, 247, 247), const Color.fromARGB(255, 213, 222, 87)],
      "reviewList": [
        {
          "user": "Nguyễn Văn hưng",
          "star": 5,// đánh giá theo số lượng phần % ở trên
          "content": "Máy rất mượt, pin trâu, camera cực đẹp."
        },
        {
          "user": "Trần Thị Lệ Cẩm",
          "star": 4,
          "content": "Thiết kế đẹp, dùng ổn nhưng giá hơi cao."
        },
      ],
    },
    {
      "name": "Samsung S22",
      "price": "11.000.000 VND",
      "storage": "128GB",
      "img": "assets/images/anh14.png",
      "tag": "",
      "isFav": false,
      "showQty": false,
      "qty": 0,
      "rating": 4.5,
      "stock": 10,
      "reviewCount": 30,
      "ratingPercent": {
        5: 0.18,   // 80%
        4: 0.17,  // 12%
        3: 0.06,
        2: 0.03,
        1: 0.02,
      },
      "desc": [
        "Chơi game mượt",
        "Pin dung lượng cao lâu hết pin"
      ],
      "colors": [const Color.fromARGB(255, 250, 247, 247), const Color.fromARGB(255, 10, 10, 8)],
      "reviewList": [
        {
          "user": "Nguyễn Văn Tím",
          "star": 5,// đánh giá theo số lượng phần % ở trên
          "content": "Máy rất mượt, pin trâu, camera cực đẹp."
        },
        {
          "user": "Trần Thị Cẩm Nhung",
          "star": 4,
          "content": "Thiết kế đẹp, dùng ổn nhưng giá hơi cao."
        },
      ],
    },
    // Thêm sản phẩm mới ở đây nếu muốn
  ];
//SẢN PHẨM DỰ PHÒNG
  final List<Map<String, dynamic>> replacementProducts = [
  {
    "name": "Realme 11",
    "price": "7.990.000 VND",
    "storage": "128GB",
    "img": "assets/images/anh12.png",
    "tag": "NEW",
    "isFav": false,
    "colors": [Colors.black, Colors.blue],
    "desc": ["Màn hình AMOLED", "Pin 5000mAh"],
    "reviewList": [
      {
          "user": "Nguyễn Văn Tím",
          "star": 5,// đánh giá theo số lượng phần % ở trên
          "content": "Máy rất mượt, pin trâu, camera cực đẹp."
        },
        {
          "user": "Lê Văn Liêm",
          "star": 3,
          "content": "Thiết kế đẹp, dùng ổn nhưng giá hơi cao."
        },
    ],
    "rating": 4.4,
    "reviewCount": 10,
    "stock": 50,
    "ratingPercent": {5: 0.6, 4: 0.2, 3: 0.1, 2: 0.05, 1: 0.05},
  },
  // Thêm sản phẩm khác nếu muốn
];

  @override
  void initState() {
    super.initState();
    qty = widget.product['qty'] ?? 1;
    widget.product['isFav'] ??= false;
  }

  @override
  Widget build(BuildContext context) {
    final List reviews = widget.product['reviewList'] ?? [];
    final Map<int, double> ratingPercent =
        Map<int, double>.from(widget.product['ratingPercent'] ?? {});

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: widget.product['isFav'] ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                widget.product['isFav'] = !widget.product['isFav'];
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================== HÌNH ẢNH SẢN PHẨM ===================
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withOpacity(0.08),
                ),
                child: Image.asset(
                  widget.product['img'],
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // =================== TÊN SẢN PHẨM ===================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.product['name'],
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),

            // =================== DUNG LƯỢNG + SAO + TỒN KHO ===================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.product['storage']),
                      const SizedBox(height: 2),
                      
                    ],
                  ),
                  const Spacer(),
                  
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${widget.product['stock']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Số lượng tồn kho",
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // =================== NGĂN CÁCH DÒNG ===================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                color: Colors.grey.shade300,
                thickness: 1,
              ),
            ),
            const SizedBox(height: 8),

            // =================== CHỌN MÀU ===================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text("Màu sắc:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Row(
                    children: List.generate(
                      (widget.product['colors'] as List<Color>).length,
                      (index) {
                        final color = widget.product['colors'][index];
                        final isSelected = selectedColorIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => selectedColorIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                color: Colors.grey.shade300,
                thickness: 1,
              ),
            ),
            const SizedBox(height: 8),

            // =================== MÔ TẢ SẢN PHẨM ===================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (widget.product['desc'] as List<String>)
                    .map((line) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            "• $line",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            // =================== HEADER REVIEW ===================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Reviews",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      

                      // ❤️ TRÁI TIM (CODE THÊM TRÁI TIM)
                      /*InkWell(
                        onTap: () {
                          setState(() {
                            widget.product['isFav'] = !widget.product['isFav'];
                          });
                        },
                        child: Icon(
                          Icons.favorite,
                          size: 20,
                          color: widget.product['isFav'] ? Colors.red : Colors.grey,
                        ),
                      ),*/
                    ],
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      // ---- 4.9 ----
                      Text(
                        "${widget.product['rating']}",
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 6),

                      // ---- out of 5 (CÙNG HÀNG, KHÔNG TỤT) ----
                      const Text(
                        "out of 5",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      const Spacer(),

                      // ---- SAO + RATINGS (GÓC PHẢI) ----
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: List.generate(
                              5,
                              (_) => const Icon(
                                Icons.star,
                                size: 18,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${reviews.length} ratings",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // =================== BIỂU ĐỒ % SAO ===================
            ...ratingPercent.entries.map(
              (e) => _ratingBar(e.key.toString(), e.value, (e.value * 100).toInt()),
            ),
            const SizedBox(height: 16),

            // =================== TỔNG REVIEW + WRITE ===================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    "${widget.product['reviewCount']} reviews",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Text("Write a review",
                      style: TextStyle(color: Colors.orange)),

                  const Icon(Icons.edit, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // =================== DANH SÁCH REVIEW ===================
            ...reviews.map(
              (r) => _reviewItem(
                name: r['user'],
                rating: r['star'],
                content: r['content'],
              ),
            ),

            const SizedBox(height: 24),

            // =================== CÁC SẢN PHẨM KHÁC ===================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Các sản phẩm khác",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 220, // chiều cao card
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: otherProducts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final p = otherProducts[index];
                  return _buildOtherProductCard(p);
                },
              ),
            ),

            const SizedBox(height: 24),

            // =================== KHUNG SỐ LƯỢNG MUA HÀNG ===================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Số lượng",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        _iconBtnQty(Icons.remove, () {
                          setState(() {
                            qty--;
                            if (qty < 1) qty = 1;
                          });
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "$qty",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                        _iconBtnQty(Icons.add, () {
                          setState(() {
                            qty++;
                          });
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // =================== BOTTOM ADD TO CART ===================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Text(
              widget.product['price'],
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đã thêm $qty sản phẩm vào giỏ hàng")),
                  );
                },
                child: const Text("Add to cart", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildOtherProductCard(Map<String, dynamic> p) {
  return Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    elevation: 3,
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          // 1️⃣ Xóa sản phẩm vừa bấm khỏi danh sách
          otherProducts.remove(p);

          // 2️⃣ Nếu muốn, thay thế bằng sản phẩm từ replacementProducts
          if (replacementProducts.isNotEmpty) {
            // Lấy sản phẩm đầu tiên trong replacementProducts
            Map<String, dynamic> newProduct = replacementProducts.removeAt(0);
            // Chèn vào vị trí của sản phẩm vừa xóa
            otherProducts.add(newProduct);
          }
        });

        // 3️⃣ Mở ProductDetailScreen cho sản phẩm vừa bấm
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: p),
          ),
        );
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Image.asset(
                      p['img'],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  p['name'],
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p['price'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p['storage'] ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Trái tim yêu thích
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () {
                setState(() {
                  p['isFav'] = !(p['isFav'] as bool);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite,
                  size: 18,
                  color: p['isFav'] ? Colors.red : Colors.grey,
                ),
              ),
            ),
          ),
          // Tag
          if ((p['tag'] ?? '').toString().isNotEmpty)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  p['tag'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}


  // =================== HỖ TRỢ ===================
  Widget _ratingBar(String star, double value, int percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(star),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey.shade300,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Text("$percent%"),
        ],
      ),
    );
  }

  Widget _reviewItem({
    required String name,
    required int rating,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.green.shade100,
            child: Text(name[0], style: const TextStyle(color: Colors.orange)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: List.generate(
                    rating,
                    (_) => const Icon(Icons.star, size: 14, color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtnQty(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
*/





/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- IMPORT CONTROLLER & MODEL ---
import '../../Controller/product_controller.dart';
import '../../Controller/favorite_controller.dart';
import '../../Controller/cart_Controller.dart';
import '../../Model/product_model.dart';
import '../../Config/baseUrl.dart'; // [QUAN TRỌNG] Thêm dòng này để lấy link Ngrok

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final int? productVariantId; // Dùng để focus vào biến thể cụ thể (nếu cần)

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

  // State quản lý biến thể đang chọn
  ProductVariant? _selectedVariant;
  int _selectedVariantIndex = 0;

  int qty = 1;
  bool isFav = false;

  // [THÊM MỚI] Header để ảnh load được qua Ngrok
  final Map<String, String> _imageHeaders = const {
    "ngrok-skip-browser-warning": "true",
  };

  // [THÊM MỚI] Hàm xử lý link ảnh chắc chắn hiển thị
  String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://via.placeholder.com/300"; // Ảnh lỗi
    }
    if (path.startsWith("http")) {
      return path; // Đã là link full
    }
    // Ghép baseUrl vào
    String cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    String cleanPath = path.startsWith('/') ? path : '/$path';
    return "$cleanBase$cleanPath";
  }

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    // Gọi API lấy danh sách biến thể sản phẩm
    _productFuture = ProductController.getVariantsByProductId(widget.productId);
  }

  String formatCurrency(double? price) {
    if (price == null) return "0 đ";
    final format = NumberFormat("#,###", "vi_VN");
    return "${format.format(price)} đ";
  }

  void _checkFavoriteStatus() async {
    bool status = await FavoriteController.checkIsFavorite(widget.productId);
    if (mounted) {
      setState(() {
        isFav = status;
      });
    }
  }

  void _onFavoritePressed() async {
    bool oldStatus = isFav;
    setState(() {
      isFav = !isFav;
    });

    bool success;
    if (oldStatus == false) {
      success = await FavoriteController.addFavorite(widget.productId);
    } else {
      success = await FavoriteController.removeFavorite(widget.productId);
    }

    if (!success) {
      if (mounted) {
        setState(() {
          isFav = oldStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Có lỗi xảy ra, vui lòng thử lại")),
        );
      }
    } else {
      if (mounted && !oldStatus) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đã thêm vào yêu thích"),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text("Không tìm thấy thông tin sản phẩm"));
          }

          final List<ProductVariant> variants = snapshot.data!;

          // --- LOGIC CHỌN BIẾN THỂ MẶC ĐỊNH ---
          if (_selectedVariant == null) {
            if (widget.productVariantId != null) {
              final int foundIndex =
                  variants.indexWhere((v) => v.id == widget.productVariantId);
              if (foundIndex != -1) {
                _selectedVariant = variants[foundIndex];
                _selectedVariantIndex = foundIndex;
              } else {
                _selectedVariant = variants[0];
                _selectedVariantIndex = 0;
              }
            } else {
              _selectedVariant = variants[0];
              _selectedVariantIndex = 0;
            }
          }

          // Lấy biến thể đang hiển thị
          final displayVariant = _selectedVariant ?? variants[0];
          
          // [SỬA] Gọi hàm xử lý link ảnh ở đây
          String displayImage = getFullImageUrl(displayVariant.imageUrl);

          double displayPrice = displayVariant.price ?? 0;
          int displayStock = displayVariant.stockQuantity ?? 0;

          String configLabel = "";
          if (displayVariant.ram != null || displayVariant.storage != null) {
            configLabel = "${displayVariant.ram ?? ''} / ${displayVariant.storage ?? ''}";
          }

          return Stack(
            children: [
              // 1. ẢNH SẢN PHẨM (Nằm dưới cùng, chiếm 45% màn hình)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size.height * 0.45,
                child: Container(
                  color: const Color(0xFFF5F5F5),
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Image.network(
                    displayImage,
                    headers: _imageHeaders, // [QUAN TRỌNG] Thêm header để qua mặt Ngrok
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                  ),
                ),
              ),

              // 2. NÚT BACK VÀ YÊU THÍCH (Custom AppBar)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                    _circleButton(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      () {
                        _onFavoritePressed();
                      },
                      color: isFav ? Colors.red : Colors.black,
                    ),
                  ],
                ),
              ),

              // 3. THÔNG TIN CHI TIẾT (Trượt lên trên ảnh)
              Positioned(
                top: size.height * 0.4, 
                left: 0,
                right: 0,
                bottom: 80, 
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      )
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thanh gạch ngang nhỏ trang trí
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // TÊN VÀ GIÁ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayVariant.name ?? "Tên sản phẩm",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (configLabel.trim().isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        configLabel,
                                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              formatCurrency(displayPrice),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // CHỌN BIẾN THỂ (MÀU SẮC)
                        if (variants.length > 1) ...[
                          const Text(
                            "Chọn phiên bản",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List.generate(variants.length, (index) {
                              final variant = variants[index];
                              final isSelected = _selectedVariantIndex == index;
                              
                              String label = variant.color ?? "Màu ${index + 1}";
                              if(variant.storage != null) label += " - ${variant.storage}";

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedVariantIndex = index;
                                    _selectedVariant = variant;
                                    qty = 1; 
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.black : Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: isSelected ? Colors.black : Colors.grey.shade300,
                                    ),
                                    boxShadow: isSelected 
                                      ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]
                                      : null
                                  ),
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // MÔ TẢ & THÔNG SỐ
                        const Text(
                          "Mô tả sản phẩm",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          displayVariant.description ?? "Đang cập nhật...",
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.6),
                        ),
                        
                        const SizedBox(height: 16),
                        _specRow(Icons.settings_overscan, "Màn hình", displayVariant.screenSize),
                        _specRow(Icons.camera_alt_outlined, "Camera", displayVariant.camera),
                        _specRow(Icons.memory, "CPU", displayVariant.cpu),
                        _specRow(Icons.battery_charging_full, "Pin", displayVariant.battery),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. BOTTOM BAR (CỐ ĐỊNH Ở DƯỚI)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.black12)),
                  ),
                  child: Row(
                    children: [
                      // Bộ chọn số lượng
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            _qtyBtn(Icons.remove, () {
                              if (qty > 1) setState(() => qty--);
                            }),
                            SizedBox(
                              width: 30,
                              child: Text(
                                "$qty",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            _qtyBtn(Icons.add, () {
                              if (qty < displayStock) {
                                setState(() => qty++);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Quá số lượng tồn kho")));
                              }
                            }),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 20),

                      // Nút Add to Cart
                      Expanded(
                        child: ElevatedButton(
                          onPressed: displayStock > 0 ? () async {
                            if (_selectedVariant != null) {
                              await CartController.addToCart(null, _selectedVariant!.id);
                              
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Đã thêm $qty sản phẩm vào giỏ"),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            displayStock > 0 ? "Thêm vào giỏ" : "Hết hàng",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget con: Nút tròn cho AppBar
  Widget _circleButton(IconData icon, VoidCallback onPressed, {Color color = Colors.black}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  // Widget con: Nút tăng giảm số lượng
  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 20, color: Colors.black54),
      ),
    );
  }
  
  // Widget con: Dòng thông số kỹ thuật
  Widget _specRow(IconData icon, String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text("$title: ", style: const TextStyle(color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
*/



/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- IMPORT CONTROLLER & MODEL ---
import '../../Controller/product_controller.dart';
import '../../Controller/favorite_controller.dart';
import '../../Controller/cart_Controller.dart';
import '../../Model/product_model.dart';
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

  // Biến quản lý trạng thái
  ProductVariant? _selectedVariant;
  int _selectedVariantIndex = 0;
  int qty = 1;
  bool isFav = false;

  // Header cho ảnh Ngrok
  final Map<String, String> _imageHeaders = const {
    "ngrok-skip-browser-warning": "true",
  };

  // Hàm xử lý link ảnh
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi kết nối")));
    } else if (mounted && !oldStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã thêm vào yêu thích"), duration: Duration(seconds: 1)),
      );
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
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không tìm thấy thông tin sản phẩm"));
          }

          final List<ProductVariant> variants = snapshot.data!;

          // Logic chọn biến thể mặc định
          if (_selectedVariant == null) {
            if (widget.productVariantId != null) {
              final int foundIndex = variants.indexWhere((v) => v.id == widget.productVariantId);
              if (foundIndex != -1) {
                _selectedVariant = variants[foundIndex];
                _selectedVariantIndex = foundIndex;
              } else {
                _selectedVariant = variants[0];
                _selectedVariantIndex = 0;
              }
            } else {
              _selectedVariant = variants[0];
              _selectedVariantIndex = 0;
            }
          }

          final displayVariant = _selectedVariant ?? variants[0];
          String displayImage = getFullImageUrl(displayVariant.imageUrl);
          double displayPrice = displayVariant.price ?? 0;
          int displayStock = displayVariant.stockQuantity ?? 0;

          String configLabel = "";
          if (displayVariant.ram != null || displayVariant.storage != null) {
            configLabel = "${displayVariant.ram ?? ''} / ${displayVariant.storage ?? ''}";
          }

          return Stack(
            children: [
              // 1. ẢNH SẢN PHẨM (NỀN)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size.height * 0.45,
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
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                    _circleButton(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      _onFavoritePressed,
                      color: isFav ? Colors.deepOrange : Colors.black,
                    ),
                  ],
                ),
              ),

              // 3. KHUNG TRẮNG CHỨA NỘI DUNG (CUỘN ĐƯỢC)
              Positioned(
                top: size.height * 0.4,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 50, height: 5,
                            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tên sản phẩm
                        Text(
                          displayVariant.name ?? "Tên sản phẩm",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
                        ),
                        
                        // Cấu hình
                        if (configLabel.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                            child: Text(configLabel, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Chọn màu
                        if (variants.length > 1) ...[
                          const Text("Chọn phiên bản", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List.generate(variants.length, (index) {
                              final variant = variants[index];
                              final isSelected = _selectedVariantIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedVariantIndex = index;
                                    _selectedVariant = variant;
                                    qty = 1;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.deepOrange : Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    "${variant.color ?? 'Màu ${index + 1}'}",
                                    style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Mô tả
                        const Text("Mô tả sản phẩm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(
                          displayVariant.description ?? "Đang cập nhật...",
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.6),
                        ),
                        const SizedBox(height: 16),
                        _specRow(Icons.settings_overscan, "Màn hình", displayVariant.screenSize),
                        _specRow(Icons.camera_alt_outlined, "Camera", displayVariant.camera),
                        _specRow(Icons.memory, "CPU", displayVariant.cpu),
                        _specRow(Icons.battery_charging_full, "Pin", displayVariant.battery),

                        const SizedBox(height: 40),

                        // ============================================================
                        // KHUNG MUA HÀNG (ĐI THEO TRANG - LAYOUT TÁCH BIỆT)
                        // ============================================================
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Đẩy 2 bên ra xa
                            children: [
                              
                              // --- A. BÊN TRÁI: GIÁ TIỀN (TO, MÀU CAM) ---
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Tổng tiền:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    Text(
                                      formatCurrency(displayPrice * qty), // Tổng giá
                                      style: const TextStyle(
                                        fontSize: 22, 
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange, // Cam
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // --- B. BÊN PHẢI: CỤM [-1+] VÀ NÚT GIỎ HÀNG ---
                              Row(
                                children: [
                                  // 1. Khung chỉnh số lượng (Bo tròn, xám)
                                  Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _qtyBtn(Icons.remove, () {
                                          if (qty > 1) setState(() => qty--);
                                        }),
                                        Text(
                                          "$qty",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        _qtyBtn(Icons.add, () {
                                          if (qty < displayStock) setState(() => qty++);
                                        }),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 12), // Khoảng cách giữa nút số lượng và nút giỏ

                                  // 2. Nút Thêm Giỏ Hàng (Màu cam, bo tròn)
                                  InkWell(
                                    onTap: displayStock > 0 ? () async {
                                      if (_selectedVariant != null) {
                                        await CartController.addToCart(null, _selectedVariant!.id);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Đã thêm $qty sản phẩm vào giỏ"), backgroundColor: Colors.green),
                                        );
                                      }
                                    } : null,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      height: 44,
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: displayStock > 0 ? Colors.deepOrange : Colors.grey,
                                        borderRadius: BorderRadius.circular(16), // Bo tròn vừa phải
                                        boxShadow: displayStock > 0 ? [
                                          BoxShadow(color: Colors.deepOrange.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                                        ] : null,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            displayStock > 0 ? "Thêm" : "Hết hàng",
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30), // Khoảng trống cuối cùng
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET CON ---

  Widget _circleButton(IconData icon, VoidCallback onPressed, {Color color = Colors.black}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)],
      ),
      child: IconButton(icon: Icon(icon, color: color, size: 20), onPressed: onPressed),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  Widget _specRow(IconData icon, String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text("$title: ", style: const TextStyle(color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}*/



/*
//SƯỜN CODE CŨ HÔM QUA
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- IMPORT CONTROLLER & MODEL ---
import '../../Controller/product_controller.dart';
import '../../Controller/favorite_controller.dart';
import '../../Controller/cart_Controller.dart';
import '../../Model/product_model.dart';
import '../../Model/review_model.dart'; // [MỚI] Nhớ import file review_model
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
  
  // [MỚI] Biến cho phần bình luận
  late Future<List<Review>> _reviewsFuture;
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 5.0; // Mặc định 5 sao
  bool _isSendingComment = false;

  // Biến state cũ
  ProductVariant? _selectedVariant;
  int _selectedVariantIndex = 0;
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
    
    // [MỚI] Load bình luận khi vào trang
    _reviewsFuture = ProductController.getReviews(widget.productId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // [MỚI] Hàm gửi bình luận
  void _submitReview() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSendingComment = true);

    // 1. Gọi API
    bool success = await ProductController.postReview(widget.productId, _commentController.text, _userRating);

    if (mounted) {
      setState(() => _isSendingComment = false);

      if (success) {
        // 2. Nếu thành công: Xóa ô nhập liệu ngay
        _commentController.clear();
        FocusScope.of(context).unfocus(); // Đóng bàn phím

        // 3. Cập nhật lại danh sách bình luận mới nhất từ API
        setState(() {
          _reviewsFuture = ProductController.getReviews(widget.productId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bình luận thành công!"), backgroundColor: Colors.green),
        );
      } else {
        // Nếu thất bại: Giữ nguyên nội dung để người dùng gửi lại
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gửi thất bại, hãy thử lại!"), backgroundColor: Colors.red),
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
            _selectedVariant = variants[0];
             // Logic chọn variant mặc định (giữ nguyên logic cũ của bạn ở đây nếu cần)
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
                    padding: const EdgeInsets.all(24),
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
                              final isSelected = _selectedVariant == variant;
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

                        // Mô tả & Thông số
                        const Text("Mô tả sản phẩm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(displayVariant.description ?? "Đang cập nhật...", style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.6)),
                        const SizedBox(height: 16),
                        _specRow(Icons.memory, "CPU", displayVariant.cpu),
                        _specRow(Icons.battery_charging_full, "Pin", displayVariant.battery),

                        const Divider(height: 60),

                        // ============================================================
                        // [MỚI] PHẦN BÌNH LUẬN (REVIEWS)
                        // ============================================================
                        const Text("Đánh giá & Bình luận", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),

                        // Form nhập bình luận
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Viết đánh giá của bạn:", style: TextStyle(fontWeight: FontWeight.w500)),
                              Row(
                                children: List.generate(5, (index) {
                                  return IconButton(
                                    icon: Icon(
                                      index < _userRating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                    ),
                                    onPressed: () => setState(() => _userRating = index + 1.0),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  );
                                }),
                              ),
                              TextField(
                                controller: _commentController,
                                decoration: const InputDecoration(
                                  hintText: "Nhập nội dung...",
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                maxLines: 2,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: _isSendingComment ? null : _submitReview,
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size(80, 36)),
                                  child: _isSendingComment 
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text("Gửi", style: TextStyle(color: Colors.white)),
                                ),
                              )
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),

                        // Danh sách bình luận từ API
                        FutureBuilder<List<Review>>(
                          future: _reviewsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const Text("Lỗi tải bình luận");
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text("Chưa có đánh giá nào. Hãy là người đầu tiên!", style: TextStyle(color: Colors.grey)));
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(), // Để scroll theo cha
                              itemCount: snapshot.data!.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final review = snapshot.data![index];
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage: (review.avatarUrl != null) ? NetworkImage(getFullImageUrl(review.avatarUrl)) : null,
                                      child: (review.avatarUrl == null) ? const Icon(Icons.person, color: Colors.grey) : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                              Text(
                                                // Format ngày (nếu chuỗi date đúng chuẩn ISO)
                                                review.createdAt.split('T')[0], 
                                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: List.generate(5, (starIndex) => Icon(Icons.star, size: 14, color: starIndex < review.rating ? Colors.amber : Colors.grey.shade300)),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(review.content, style: const TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // ============================================================
                        // KHUNG MUA HÀNG (GIỮ NGUYÊN NHƯ CŨ)
                        // ============================================================
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Tổng tiền:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    Text(formatCurrency(displayPrice * qty), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 44,
                                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(22)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _qtyBtn(Icons.remove, () { if (qty > 1) setState(() => qty--); }),
                                        Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        _qtyBtn(Icons.add, () { if (qty < displayStock) setState(() => qty++); }),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: displayStock > 0 ? () async {
                                      if (_selectedVariant != null) {
                                        await CartController.addToCart(null, _selectedVariant!.id);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã thêm $qty sản phẩm vào giỏ"), backgroundColor: Colors.green));
                                      }
                                    } : null,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      height: 44,
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: displayStock > 0 ? Colors.deepOrange : Colors.grey,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                                          const SizedBox(width: 8),
                                          Text(displayStock > 0 ? "Thêm" : "Hết", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
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
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15), child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, size: 18, color: Colors.black87)));
  }

  Widget _specRow(IconData icon, String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Icon(icon, size: 18, color: Colors.grey), const SizedBox(width: 10), Text("$title: ", style: const TextStyle(color: Colors.grey)), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)))]));
  }
}*/

/*
import 'package:flutter/material.dart';
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
  final int? productVariantId; // ID của biến thể cụ thể (nếu click từ trang AllProduct)

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
  late Future<List<Review>> _reviewsFuture;
  
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 5.0;
  bool _isSendingComment = false;

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
    // Load variants và reviews
    _productFuture = ProductController.getVariantsByProductId(widget.productId);
    _reviewsFuture = ProductController.getReviews(widget.productId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // --- LOGIC: Tìm variant đúng với variantId được truyền vào ---
  void _initializeSelectedVariant(List<ProductVariant> variants) {
    if (_selectedVariant != null) return; // Đã chọn rồi thì thôi

    if (widget.productVariantId != null) {
      // Tìm variant khớp ID
      try {
        _selectedVariant = variants.firstWhere((element) => element.id == widget.productVariantId);
      } catch (e) {
        _selectedVariant = variants.isNotEmpty ? variants[0] : null;
      }
    } else {
      // Mặc định cái đầu tiên
      _selectedVariant = variants.isNotEmpty ? variants[0] : null;
    }
  }

  void _submitReview() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isSendingComment = true);
    bool success = await ProductController.postReview(widget.productId, _commentController.text, _userRating);
    if (mounted) {
      setState(() => _isSendingComment = false);
      if (success) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
        setState(() {
          _reviewsFuture = ProductController.getReviews(widget.productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đánh giá thành công!"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi khi gửi đánh giá"), backgroundColor: Colors.red));
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
            return Scaffold(
              appBar: AppBar(title: const Text("Lỗi"), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black)),
              body: const Center(child: Text("Không tìm thấy thông tin sản phẩm")),
            );
          }

          final List<ProductVariant> variants = snapshot.data!;
          // Logic chọn variant ngay khi có data
          _initializeSelectedVariant(variants);

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

              // 2. HEADER BUTTONS
              Positioned(
                top: MediaQuery.of(context).padding.top + 10, left: 16, right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                    _circleButton(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      _onFavoritePressed,
                      color: isFav ? Colors.deepOrange : Colors.black
                    ),
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
                  child: Column(
                    children: [
                      // Thanh kéo nhỏ
                      const SizedBox(height: 12),
                      Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                      
                      // Nội dung cuộn được
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100), // padding bottom để tránh nút mua che
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tên
                              Text(displayVariant.name ?? "Tên sản phẩm", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2)),
                              const SizedBox(height: 12),

                              // Chọn màu (Variant)
                              if (variants.length > 1) ...[
                                Wrap(
                                  spacing: 10, runSpacing: 10,
                                  children: List.generate(variants.length, (index) {
                                    final variant = variants[index];
                                    final isSelected = _selectedVariant?.id == variant.id;
                                    return GestureDetector(
                                      onTap: () => setState(() { _selectedVariant = variant; qty = 1; }),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.deepOrange : Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade300),
                                        ),
                                        child: Text(
                                          variant.color ?? 'Màu ${index + 1}',
                                          style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 24),
                              ],

                              // Mô tả
                              const Text("Thông số & Mô tả", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              _specRow(Icons.memory, "CPU", displayVariant.cpu),
                              _specRow(Icons.camera_alt, "Camera", displayVariant.camera),
                              _specRow(Icons.battery_std, "Pin", displayVariant.battery),
                              const SizedBox(height: 8),
                              Text(displayVariant.description ?? "Chưa có mô tả", style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
                              
                              const Divider(height: 40),

                              // PHẦN BÌNH LUẬN (REVIEWS)
                              const Text("Đánh giá khách hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              _buildReviewInput(),
                              const SizedBox(height: 20),
                              _buildReviewList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. BOTTOM BAR (MUA HÀNG)
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Tổng cộng", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(formatCurrency(displayPrice * qty), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        ],
                      ),
                      const Spacer(),
                      // Tăng giảm số lượng
                      Container(
                        height: 40,
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            _qtyBtn(Icons.remove, () { if (qty > 1) setState(() => qty--); }),
                            Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold)),
                            _qtyBtn(Icons.add, () { if (qty < displayStock) setState(() => qty++); }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Nút thêm giỏ hàng
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                        label: Text(displayStock > 0 ? "Thêm" : "Hết hàng"),
                      ),
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

  // --- WIDGET CON (TÁCH RA CHO GỌN) ---
  Widget _buildReviewInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) {
              return InkWell(
                onTap: () => setState(() => _userRating = index + 1.0),
                child: Icon(index < _userRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 28),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(hintText: "Nhập đánh giá của bạn...", border: InputBorder.none, isDense: true),
            maxLines: 2,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _isSendingComment ? null : _submitReview,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size(70, 30)),
              child: _isSendingComment 
                ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Gửi", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReviewList() {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("Chưa có đánh giá nào.", style: TextStyle(color: Colors.grey));
        
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final review = snapshot.data![index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: review.avatarUrl != null ? NetworkImage(getFullImageUrl(review.avatarUrl)) : null,
                  child: review.avatarUrl == null ? const Icon(Icons.person, size: 20) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text(review.createdAt.split('T')[0], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      Row(children: List.generate(5, (i) => Icon(Icons.star, size: 12, color: i < review.rating ? Colors.amber : Colors.grey.shade300))),
                      Text(review.content),
                    ],
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onPressed, {Color color = Colors.black}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: IconButton(icon: Icon(icon, color: color, size: 20), onPressed: onPressed),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15), child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, size: 18)));
  }

  Widget _specRow(IconData icon, String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [Icon(icon, size: 16, color: Colors.grey), const SizedBox(width: 8), Text("$title: ", style: const TextStyle(color: Colors.grey, fontSize: 13)), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)))]));
  }
}*/



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
  late Future<List<Review>> _reviewsFuture;
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 5.0; 
  bool _isSendingComment = false;

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
    _reviewsFuture = ProductController.getReviews(widget.productId);
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
                        
                        const SizedBox(height: 20),

                        // List Review
                        FutureBuilder<List<Review>>(
                          future: _reviewsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                            if (snapshot.hasError) return const Text("Lỗi tải bình luận");
                            if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("Chưa có đánh giá nào.", style: TextStyle(color: Colors.grey))));

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final review = snapshot.data![index];
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.grey.shade200,
                                        backgroundImage: (review.avatarUrl != null) ? NetworkImage(getFullImageUrl(review.avatarUrl)) : null,
                                        child: (review.avatarUrl == null) ? const Icon(Icons.person, color: Colors.grey) : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                Text(review.createdAt.split('T')[0], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                              ],
                                            ),
                                            Row(children: List.generate(5, (starIndex) => Icon(Icons.star, size: 14, color: starIndex < review.rating ? Colors.amber : Colors.grey.shade300))),
                                            const SizedBox(height: 4),
                                            Text(review.content, style: const TextStyle(fontSize: 14)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
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
}