
import 'package:flutter/material.dart';

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
                  color: Colors.green.withOpacity(0.08),
                ),
                child: Image.asset(
                  widget.product['img'],
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // =================== TÊN SẢN PHẨM ===================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.product['name'],
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

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
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.orange, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            "${widget.product['rating']} (${widget.product['reviewCount']} reviews)",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
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
              child: Row(
                children: [
                  const Text(
                    "Reviews",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Icon(Icons.star, color: Colors.green, size: 18),
                  Text(" ${widget.product['rating']}"),
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
                  const Icon(Icons.edit, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  const Text("Write a review",
                      style: TextStyle(color: Colors.green)),
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
                  color: Colors.green,
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
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
                    color: Colors.green,
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
              color: Colors.green,
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
            child: Text(name[0], style: const TextStyle(color: Colors.green)),
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
