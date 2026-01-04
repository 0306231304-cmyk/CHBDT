import 'package:flutter/material.dart';
import '../Product/product_detail_screen.dart';
import '../Category/category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  /* =======================
   * DATA SẢN PHẨM (CHUẨN HÓA)
   * ======================= */
  final List<Map<String, dynamic>> products = [
    {
      "name": "Samsung A53",
      "price": "12.000.000 VND",
      "storage": "128GB",
      "img": "assets/images/anh6.png",
      // này là icon trái tim và chữ new -15%
      "tag": "",
      "isFav": false,
      "showQty": false,// thanh số lượng

      "qty": 0,// số lượng
      "rating": 4.9,
      "ratingPercent": {// % sao cho mỗi sản phẩm
        5: 0.8,   // 80%
        4: 0.12,  // 12%
        3: 0.05,
        2: 0.02,
        1: 0.01,
      },
      
      "reviewCount": 47,
      "stock": 300,
      "desc": [
        "Chip xử lý mạnh mẽ, tiết kiệm pin",
        "Camera chất lượng cao, chụp đêm tốt",
        "Màn hình lớn, hiển thị sắc nét",
        "Thiết kế sang trọng, cao cấp"
      ],
      "colors": [Colors.black, Colors.blue, Colors.white],
      "reviewList": [
        {
          "user": "Nguyễn Văn A",
          "star": 5,
          "content": "Máy rất mượt, pin trâu, camera cực đẹp."
        },
        {
          "user": "Trần Thị B",
          "star": 4,
          "content": "Thiết kế đẹp, dùng ổn nhưng giá hơi cao."
        },
      ],

    },
    {
      "name": "Iphone 14 ProMax",
      "price": "15.900.000 VND",
      "storage": "1TB",
      "img": "assets/images/anh7.png",
      "tag": "NEW",
      "isFav": false,
      "showQty": true,
      "qty": 1,
      "rating": 4.8,
      "ratingPercent": {
        5: 0.7,   // 80%
        4: 0.10,  // 12%
        3: 0.03,
        2: 0.02,
        1: 0.01,
      },
      
      "reviewCount": 20,
      "stock": 120,
      "desc": [
        "Chip A16 Bionic mạnh mẽ",
        "Camera 48MP siêu nét",
        "Màn hình ProMotion 120Hz",
        "Thiết kế cao cấp"
      ],
      "colors": [Colors.black, Colors.blue, Colors.white],
      "reviewList": [
        {
          "user": "Nguyễn Văn A",
          "star": 5,
          "content": "Máy rất mượt, pin trâu, camera cực đẹp."
        },
        {
          "user": "Trần Thị B",
          "star": 4,
          "content": "Thiết kế đẹp, dùng ổn nhưng giá hơi cao."
        },
      ],
    },
    {
      "name": "Huawei",
      "price": "10.550.000 VND",
      "storage": "256GB",
      "img": "assets/images/anh11.png",
      "tag": "",
      "isFav": true,
      "showQty": false,
      "qty": 0,
      "rating": 4.3,
      "stock": 80,//số lượng tồn kho
      "reviewCount": 100,
      "ratingPercent": {
        5: 0.5,   // 80%
        4: 0.09,  // 12%
        3: 0.04,
        2: 0.03,
        1: 0.02,
      },
      
      "desc": [
        "Hiệu năng ổn định",
        "Camera AI thông minh"
      ],
      "colors": [Colors.black, Colors.blue, Colors.white],
      "reviewList": [
        {
          "user": "Nguyễn Văn c",
          "star": 5,
          "content": "Máy rất mượt, pin trâu, camera cực đẹp."
        },
        {
          "user": "Trần Thị d",
          "star": 4,
          "content": "Thiết kế đẹp, dùng ổn nhưng giá hơi cao."
        },
      ],
    },
    {
      "name": "Iphone 11",
      "price": "10.990.000 VND",
      "storage": "1TB",
      "img": "assets/images/anh9.png",
      "tag": "-15%",
      "isFav": false,
      "showQty": false,
      "qty": 0,
      "rating": 4.5,
      "stock": 60,
      "reviewCount": 100,
      "ratingPercent": {
        5: 0.10,   // 80%
        4: 0.09,  // 12%
        3: 0.04,
        2: 0.03,
        1: 0.06,
      },
      "desc": [
        "Chip A13 mạnh mẽ",
        "Camera kép chụp đẹp",
        "Pin ổn định"
      ],
      "colors": [Colors.black, Colors.white, Colors.red],
      "reviewList": [
        {
          "user": "Nguyễn Văn e",
          "star": 5,
          "content": "Máy rất mượt, pin trâu, camera cực đẹp."
        },
        {
          "user": "Trần Thị f",
          "star": 4,
          "content": "Thiết kế đẹp, dùng ổn nhưng giá hơi cao."
        },
      ],
    },
    {
      "name": "SamSung A70",
      "price": "10.000.000 VND",
      "storage": "256GB",
      "img": "assets/images/anh10.png",
      "tag": "-5%",
      "isFav": false,
      "showQty": false,
      "qty": 0,
      "rating": 4.1,
      "stock": 150,
      "reviewCount": 100,
      "ratingPercent": {
        5: 0.10,   // 80%
        4: 0.15,  // 12%
        3: 0.04,
        2: 0.03,
        1: 0.06,
      },
      "desc": [
        "Màn hình lớn",
        "Pin dung lượng cao"
      ],
      "colors": [Colors.black, Colors.blue],
      "reviewList": [
        {
          "user": "Nguyễn Văn h",
          "star": 5,// đánh giá theo số lượng phần % ở trên
          "content": "Máy rất mượt, pin trâu, camera cực đẹp."
        },
        {
          "user": "Trần Thị j",
          "star": 4,
          "content": "Thiết kế đẹp, dùng ổn nhưng giá hơi cao."
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildBanner(constraints),

                // ✅ FIX DUY NHẤT Ở ĐÂY
                _buildSectionTitle(
                  "Categories",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoryScreen(),
                      ),
                    );
                  },
                ),

                _buildCategoryList(),

                // ❌ FEATURED KHÔNG CÓ onTap → KHÔNG CHUYỂN TRANG
                _buildSectionTitle("Featured products"),

                _buildProductGrid(constraints),
              ],
            ),
          );
        },
      ),
    );
  }

  /* ======================= APP BAR ======================= */
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        "Xin chào",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  /* ======================= SEARCH ======================= */
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Tìm kiếm...",
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
      ),
    );
  }

  /* ======================= BANNER ======================= */
  Widget _buildBanner(BoxConstraints constraints) {
    return AspectRatio(
      aspectRatio: constraints.maxWidth > 900 ? 3 / 1 : 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage('assets/images/trangchu1.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  /* ======================= GRID ======================= */
  Widget _buildProductGrid(BoxConstraints constraints) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: constraints.maxWidth > 1200 ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: constraints.maxWidth > 1200 ? 0.9 : 0.75,
      ),
      itemBuilder: (context, index) {
        return _buildProductCard(index);
      },
    );
  }

/* ======================= CARD ======================= */
Widget _buildProductCard(int index) {
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
                  p['storage'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: p['showQty']
                      ? _buildQtySelector(index)
                      : _buildAddToCartBtn(index),
                ),
              ],
            ),
          ),

          // ===================== TRÁI TIM =====================
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

          // ===================== TAG (NEW / -15%) =====================
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





  /* ======================= ADD / QTY ======================= */
  Widget _buildAddToCartBtn(int index) {
    return InkWell(
      onTap: () {
        setState(() {
          products[index]['showQty'] = true;
          products[index]['qty'] = 1;
        });
      },
      child: Container(
        height: 32,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            "Add to cart",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQtySelector(int index) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _iconBtn(Icons.remove, () {
            setState(() {
              products[index]['qty']--;
              if (products[index]['qty'] <= 0) {
                products[index]['showQty'] = false;
                products[index]['qty'] = 0;
              }
            });
          }),
          Text("${products[index]['qty']}"),
          _iconBtn(Icons.add, () {
            setState(() {
              products[index]['qty']++;
            });
          }),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(icon, size: 18, color: Colors.green),
      ),
    );
  }

  /* ======================= CATEGORY ======================= */
  Widget _buildCategoryList() {
    final categories = [
      {"name": "APPLE", "img": 'assets/images/anh1.png'},
      {"name": "SAMSUNG", "img": 'assets/images/anh2.png'},
      {"name": "XIAOMI", "img": 'assets/images/anh3.png'},
      {"name": "OPPO", "img": 'assets/images/anh4.png'},
      {"name": "HUAWEI", "img": 'assets/images/anh5.png'},
    ];

    return Row(
      children: categories.map((cat) {
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFF9F9F9),
                child: Image.asset(cat['img']!, fit: BoxFit.contain),
              ),
              const SizedBox(height: 8),
              Text(
                cat['name']!,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  
  /* ======================= SECTION TITLE =======================
   * - Luôn hiển thị mũi tên
   * - Có Navigator hay không là do onTap
   * =========================================================== */
  Widget _buildSectionTitle(
    String title, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          InkWell(
            onTap: onTap,
            child: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }


}


