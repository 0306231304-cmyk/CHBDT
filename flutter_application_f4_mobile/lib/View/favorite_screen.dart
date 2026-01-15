import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Controller/favorite_controller.dart';
import '../../Controller/product_controller.dart';
import '../../Model/favorite_model.dart';
import '../../Model/product_model.dart';
import '../../View/Product/product_detail_screen.dart';
import '../../Config/baseUrl.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<FavoriteModel>> _favoriteFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoriteFuture = FavoriteController.fecthFavorite();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text("SẢN PHẨM YÊU THÍCH", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<FavoriteModel>>(
        future: _favoriteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          // Kiểm tra nếu có lỗi hoặc dữ liệu rỗng
          if (snapshot.hasError) {
            return Center(child: Text("Có lỗi xảy ra: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Bạn chưa có sản phẩm yêu thích nào"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return _FavoriteItemCard(
                favorite: snapshot.data![index],
                onRefresh: _loadFavorites,
              );
            },
          );
        },
      ),
    );
  }
}

class _FavoriteItemCard extends StatelessWidget {
  final FavoriteModel favorite;
  final VoidCallback onRefresh;

  const _FavoriteItemCard({required this.favorite, required this.onRefresh});

  String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith("http")) return path;
    String rootUrl = baseUrl.endsWith('/api') ? baseUrl.replaceAll('/api', '') : baseUrl;
    String cleanRoot = rootUrl.endsWith('/') ? rootUrl.substring(0, rootUrl.length - 1) : rootUrl;
    return "$cleanRoot${path.startsWith('/') ? path : '/$path'}";
  }

  @override
  Widget build(BuildContext context) {
    // SỬA: Sử dụng trực tiếp productId từ FavoriteModel
    return FutureBuilder<Product?>(
      future: ProductController.getProductDetail(favorite.productId), // Đảm bảo dùng đúng tên hàm lấy chi tiết
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox(); // Nếu không tìm thấy thông tin sản phẩm thì ẩn Card
        }

        final product = snapshot.data!;
        // Lấy giá an toàn
        final price = (product.variants != null && product.variants!.isNotEmpty)
            ? product.variants!.first.price
            : 0.0;

        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id))).then((_) => onRefresh()),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        child: Image.network(
                          getFullImageUrl(product.imageUrl),
                          headers: const {"ngrok-skip-browser-warning": "true"},
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 5),
                          Text(
                            NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(price),
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
                // Nút Xóa
                Positioned(
                  top: 5, right: 5,
                  child: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red, size: 24),
                    onPressed: () async {
                      // Gọi hàm remove và truyền ID sản phẩm
                      bool ok = await FavoriteController.removeFavorite(product.id);
                      if (ok) {
                        onRefresh();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Không thể xóa sản phẩm khỏi yêu thích"))
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}