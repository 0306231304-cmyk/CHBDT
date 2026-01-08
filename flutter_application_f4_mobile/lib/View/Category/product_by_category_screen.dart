import 'package:flutter/material.dart';
import '../Product/product_detail_screen.dart';

class ProductByCategoryScreen extends StatefulWidget {
  final String category;
  const ProductByCategoryScreen({super.key, required this.category});

  @override
  State<ProductByCategoryScreen> createState() =>
      _ProductByCategoryScreenState();
}

class _ProductByCategoryScreenState extends State<ProductByCategoryScreen> {
  List<Map<String, dynamic>> getProducts() {
    final Map<String, List<Map<String, dynamic>>> data = {
      "apple": [
        {
          "name": "Iphone 14 ProMax",
          "price": "15.900.000 VND",
          "storage": "1TB",
          "img": "assets/images/anh15.png",
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
      ],
      "samsung": [
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
          "name": "Samsung A70",
          "price": "10.000.000 VND",
          "storage": "128GB",
          "img": "assets/images/anh10.png",
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
      ],
      "xiaomi": [
        {
          "name": "Xiaomi 13",
          "price": "20.000.000 VND",
          "storage": "128GB",
          "img": "assets/images/anh13.png",
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
      ],
      "oppo": [
        {
          "name": "Oppo Reno 10",
          "price": "11.000.000 VND",
          "storage": "128GB",
          "img": "assets/images/anh17.png",
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
            
            "Màn hình lớn, hiển thị sắc nét",
            
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
      ],
    };

    return data[widget.category] ?? [];
  }

  late List<Map<String, dynamic>> products;

  @override
  void initState() {
    super.initState();
    products = getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          widget.category.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth > 1200 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    constraints.maxWidth > 1200 ? 0.9 : 0.75,
              ),
              itemBuilder: (context, index) {
                return _buildProductCard(index);
              },
            ),
          );
        },
      ),
    );
  }

  /* ======================= CARD GIỐNG HOME ======================= */
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
                      color: Colors.green,
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

            // ❤️ TIM
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: () {
                  setState(() {
                    p['isFav'] = !p['isFav'];
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

            // TAG
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
}
