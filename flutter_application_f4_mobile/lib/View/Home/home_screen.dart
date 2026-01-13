import 'package:flutter/material.dart';
import 'package:flutter_application_f4_mobile/Controller/brandsController.dart';
import 'package:flutter_application_f4_mobile/View/Category/category_screen.dart';
import 'package:flutter_application_f4_mobile/View/login_screen.dart';
import 'package:flutter_application_f4_mobile/View/profile_screen.dart';
import 'package:flutter_application_f4_mobile/View/shoppingcard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Controller/product_controller.dart';
import '../../Model/product_model.dart';
import '../Category/product_by_category_screen.dart';
import '../../Controller/cart_Controller.dart';
import 'package:intl/intl.dart';
import '../../Model/brandsModel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _futureCombinedData;
  late Future<List<BrandsModel>> _futureBrands;

  String formatCurrency(double? amount) {
    // locale: 'vi_VN' để dùng dấu chấm phân cách hàng nghìn
    // symbol: '₫' hoặc 'đ' tùy bạn thích
    // decimalDigits: 0 để bỏ số thập phân (vì VND thường không dùng hào/xu)
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return format.format(amount);
  }

  String? _userToken;
  bool _isLoading = false;
  int hotProduct = 0;

  @override
  void initState() {
    super.initState();
    debugPrint("TOKEN: ${_userToken.toString()}");
    _loadToken();
    _futureCombinedData = Future.wait([
      ProductController.fetchProducts(),            // Index 0: Lấy tất cả Product
      ProductController.getAllProductVariants() // Index 1: Lấy tất cả Variant
    ]);
    getBrands();
  }

  Future<void> getBrands()async{
    if(mounted){
      _futureBrands = BrandsController.getAllBrands();
    }
  }
  Future<void> _loadToken()async{
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('user_token') ?? '';

    if(mounted) {
      setState(() {
        _userToken = token;
        debugPrint("TOKEN: ${_userToken.toString()}");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _futureCombinedData = Future.wait([
              ProductController.fetchProducts(),            // Index 0: Lấy tất cả Product
              ProductController.getAllProductVariants() // Index 1: Lấy tất cả Variant
            ]);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header (Logo, Xin chào, Icons)
                _buildHeader(),
                const SizedBox(height: 16),

                // 2. Search Bar
                _buildSearchBar(),
                const SizedBox(height: 16),

                // 3. Banner
                _buildBanner(),
                const SizedBox(height: 20),

                // 4. Categories Section
                _buildSectionTitle("Categories", onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CategoryScreen())
                  );
                }),
                const SizedBox(height: 10),
                _buildCategoryList(),
                const SizedBox(height: 20),

                // 5. Featured Products Section (API Data)
                _buildSectionTitle("Featured products", onTap: () {}),
                const SizedBox(height: 10),
                _buildProductGrid(),
                
                // Bottom padding
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Image.asset(
          'assets/Logo.png',
          height: 80,
          width: 80,
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.store, size: 40, color: Colors.purple),
        ),
        
        // Text Xin chào
        const Text(
          "F4 MOBILE",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        // Icons Action
        Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder:(context) => ShoppingCardScreen())
                );
              },
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 15),
            IconButton(
              onPressed: () {
                if(_userToken!.isNotEmpty){
                  Navigator.of(context).push(
                    MaterialPageRoute(builder:(context) => ProfileScreen())
                  );
                }
                else{
                  Navigator.of(context).push(
                    MaterialPageRoute(builder:(context) => LoginScreen())
                  );
                }
              },
              icon: const Icon(Icons.person_outline, color: Colors.black87),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100], // Màu nền xám nhạt
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search..",
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/trangchu1.png',
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            color: Colors.grey[300],
            child: const Center(child: Text("Banner Image Not Found")),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        InkWell(
          onTap: onTap,
          child: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 90, // Chiều cao cố định cho list ngang
      child: FutureBuilder<List<BrandsModel>>(
        future: _futureBrands, 
        builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Lỗi: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Không có sản phẩm nào"));
            }
            final List<BrandsModel>? brands = snapshot.data;
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: brands!.length,
              separatorBuilder: (context, index) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                final cat = brands[index];
                return InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ProductByCategoryScreen(category_id: cat.id, nameBrands: cat.name,))
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Image.network(
                          headers: const {"ngrok-skip-browser-warning": "true",},
                          cat.image_url,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Icon(Icons.image),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                );
              },
            );

          }
        )
    );
  }

  Widget _buildProductGrid() {
    return FutureBuilder<List<dynamic>>(
      future: _futureCombinedData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Không có sản phẩm nào"));
        }

        List<Product> listProducts = snapshot.data![0] as List<Product>;
        List<ProductVariant> listVariants = snapshot.data![1] as List<ProductVariant>;
                  
        // 2. Logic tìm Top 10 Product bán chạy nhất (dựa trên soldCount của Product)
        List<Product> sortedProducts = List.from(listProducts);
        // Sắp xếp giảm dần theo soldCount
        sortedProducts.sort((a, b) => (b.soldCount).compareTo(a.soldCount));
        
        // Lấy top 10 sản phẩm
        List<Product> hotProducts = sortedProducts.take(10).toList();
        
        // Tạo một Set chứa ID của top 10 để tra cứu cho nhanh (O(1))
        Set<int> hotProductIds = hotProducts.map((p) => p.id).toSet();

        //final products = snapshot.data!;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Để scroll theo trang chính
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72, // Tỷ lệ khung hình thẻ sản phẩm
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: listVariants.length,
          itemBuilder: (context, index) {
            final variant = listVariants[index];

            bool isHot = false;
            if(variant.productId != null){
              isHot = hotProductIds.contains(variant.productId);
            }
            return _buildProductCard(variant, isHot);
          },
        );
      },
    );
  }

  Widget _buildProductCard(ProductVariant variant, bool isHot) {
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
                              onTap: _isLoading
                              ?null                             
                              :() async {    
                                // Gọi hàm thêm giỏ hàng
                                await CartController.addToCart(null, variant.id); // Truyền null user_id nếu chưa có logic lấy user
                                
                                // Kiểm tra widget còn tồn tại trước khi hiển thị thông báo (Tránh lỗi context)
                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Đã thêm ${variant.name} ${variant.color} vào giỏ hàng"),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8), // 3. Bo góc cho hiệu ứng gợn sóng để không bị tràn ra ngoài
                              child: Container(
                                padding: const EdgeInsets.all(15), // 4. Container chỉ dùng để tạo khoảng cách (padding)
                                child:
                                _isLoading
                                ?CircularProgressIndicator()
                                :Icon(
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

            // --- LOGIC HIỂN THỊ TAG / NGỌN LỬA ---
            if (isHot)
              // Nếu sản phẩm cha nằm trong Top 10 -> Hiển thị Ngọn lửa bên phải
              Positioned(
                top: 8,
                right: 8, 
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1), 
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ]
                  ),
                  child: const Icon(
                    Icons.local_fire_department, 
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
             const SizedBox(), 
          ],
        ),
      ),
    );
  }
}