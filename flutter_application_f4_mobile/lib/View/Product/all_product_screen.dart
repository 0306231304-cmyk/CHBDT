import 'package:flutter/material.dart';
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
                    builder: (_) => ProductDetailScreen(product: p),
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
