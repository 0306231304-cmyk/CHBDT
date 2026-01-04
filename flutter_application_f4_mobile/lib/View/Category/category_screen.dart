import 'package:flutter/material.dart';
import 'product_by_category_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  final List<Map<String, String>> categories = const [
    {
      "key": "apple",
      "name": "APPLE",
      "img": "assets/images/anh1.png",
    },
    {
      "key": "samsung",
      "name": "SAMSUNG",
      "img": "assets/images/anh2.png",
    },
    {
      "key": "xiaomi",
      "name": "XIAOMI",
      "img": "assets/images/anh3.png",
    },
    {
      "key": "oppo",
      "name": "OPPO",
      "img": "assets/images/anh4.png",
    },
    {
      "key": "huawei",
      "name": "HUAWEI",
      "img": "assets/images/anh5.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Categories",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.tune, color: Colors.black),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final cat = categories[index];

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductByCategoryScreen(
                      category: cat['key']!, // ✅ GIỜ KHÔNG CÒN NULL
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ===== VÒNG TRÒN NGOÀI =====
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF5F5F5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(
                          cat['img']!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      cat['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
