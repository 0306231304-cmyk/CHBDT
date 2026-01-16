import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- CONTROLLER IMPORTS (GIỮ NGUYÊN) ---
import '../../Controller/brandsController.dart';
import '../../Controller/product_controller.dart';
import '../../Controller/cart_Controller.dart';

// --- MODEL IMPORTS (GIỮ NGUYÊN) ---
import '../../Model/product_model.dart';
import '../../Model/brandsModel.dart';

// --- VIEW IMPORTS (GIỮ NGUYÊN) ---
import '../Category/category_screen.dart';
import '../../View/login_screen.dart';
import '../../View/profile_screen.dart';
import '../../View/shoppingcard_screen.dart';
import '../Category/product_by_category_screen.dart';
import '../Product/product_detail_screen.dart';
import '../Product/all_product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- GIỮ NGUYÊN TOÀN BỘ LOGIC CŨ ---
  late Future<List<dynamic>> _futureCombinedData;
  late Future<List<BrandsModel>> _futureBrands;
  List<ProductVariant> _cachedAllVariants = []; 
  String _searchText = ""; 
  String? _userToken;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  final Map<String, String> _imageHeaders = const {
    "ngrok-skip-browser-warning": "true",
  };

  String formatCurrency(double? amount) {
    if (amount == null) return "0₫";
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return format.format(amount);
  }

  @override
  void initState() {
    super.initState();
    _loadToken();
    _futureBrands = BrandsController.getAllBrands();
    _futureCombinedData = Future.wait([
      ProductController.fetchProducts(),
      ProductController.getAllProductVariants()
    ]).then((data) {
      if (mounted) {
        setState(() {
          if (data[1] is List<ProductVariant>) {
             _cachedAllVariants = data[1] as List<ProductVariant>;
          }
        });
      }
      return data;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token') ?? '';
    if (mounted) {
      setState(() { _userToken = token; });
    }
  }

  void _onSearchChanged(String query) {
    setState(() { _searchText = query.toLowerCase(); });
  }

  void _navigateToDetail(int? productId, int? productVariantID) {
    if (productId != null && productId > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: productId, productVariantId: productVariantID),
        ),
      );
    }
  }

  // --- BẮT ĐẦU PHẦN UI ---
  @override
  Widget build(BuildContext context) {
    bool hasText = _searchText.isNotEmpty;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: _buildHeader(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSearchBar(),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: hasText
                  ? _buildSearchResultList()
                  : _buildHomeContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/Logo.png', height: 50, width: 50, fit: BoxFit.contain, 
            errorBuilder: (_,__,___) => const Icon(Icons.store, size: 40, color: Colors.orange)),
        const Text("F4 MOBILE", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder:(context) => const ShoppingCardScreen())),
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder:(context) => (_userToken != null && _userToken!.isNotEmpty) 
                      ? const ProfileScreen() : const LoginScreen()));
              },
              icon: const Icon(Icons.person_outline, color: Colors.black),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        textInputAction: TextInputAction.search,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: "Bạn tìm gì hôm nay?",
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchText.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged("");
                  FocusScope.of(context).unfocus();
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _futureBrands = BrandsController.getAllBrands();
          _futureCombinedData = Future.wait([
            ProductController.fetchProducts(),
            ProductController.getAllProductVariants()
          ]).then((data) {
             if(mounted && data[1] is List<ProductVariant>) {
                setState(() { _cachedAllVariants = data[1] as List<ProductVariant>; });
             }
             return data;
          });
        });
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildBanner(),
            const SizedBox(height: 20),
            _buildSectionTitle("Danh mục", onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CategoryScreen()));
            }),
            const SizedBox(height: 10),
            _buildCategoryList(),
            const SizedBox(height: 20),
            _buildSectionTitle(
              "Sản phẩm nổi bật",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AllProductsScreen(products: _cachedAllVariants)));
              },
            ),
            const SizedBox(height: 10),
            _buildProductGrid(), // Grid view đã được chỉnh sửa
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- 🔥 ĐÃ CHỈNH SỬA PHẦN NÀY THEO YÊU CẦU 🔥 ---
  Widget _buildSearchResultList() {
    final results = _cachedAllVariants.where((variant) {
      final name = (variant.name ?? "").toLowerCase();
      return name.contains(_searchText);
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text("Không tìm thấy sản phẩm nào"));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final variant = results[index];
        return ListTile(
          leading: SizedBox(
            width: 60, height: 60,
            child: Image.network(variant.imageUrl ?? '', headers: _imageHeaders, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
          ),
          title: Text(variant.name ?? ''),
          // 👇 CHỈNH SỬA TẠI ĐÂY: DÙNG ROW ĐỂ HIỂN THỊ GIÁ VÀ MÀU
          subtitle: Row(
            children: [
              Text(formatCurrency(variant.price), style: const TextStyle(color: Colors.red)),
              const SizedBox(width: 8), // Khoảng cách nhỏ
              if (variant.color != null && variant.color!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  // Background nhạt cho dễ nhìn, chữ màu vàng cam đậm
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: Text(
                    variant.color!, 
                    style: TextStyle(
                      color: Colors.orange[800], // Màu vàng cam đậm cho rõ trên nền trắng
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    )
                  ),
                ),
            ],
          ),
          onTap: () => _navigateToDetail(variant.productId, variant.id),
        );
      },
    );
  }

  Widget _buildBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset('assets/images/trangchu1.png', width: double.infinity, height: 180, fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(height: 180, color: Colors.grey[300])),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        InkWell(onTap: onTap, child: const Icon(Icons.chevron_right, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 90, 
      child: FutureBuilder<List<BrandsModel>>(
        future: _futureBrands, 
        builder: (context, snapshot){
           if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
           final brands = snapshot.data!;
           return ListView.separated(
             scrollDirection: Axis.horizontal,
             itemCount: brands.length,
             separatorBuilder: (_, __) => const SizedBox(width: 15),
             itemBuilder: (context, index) {
               final cat = brands[index];
               return InkWell(
                 onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductByCategoryScreen(category_id: cat.id, nameBrands: cat.name))),
                 child: Column(
                   children: [
                     Container(
                       width: 55, height: 55, padding: const EdgeInsets.all(10),
                       decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, 
                         border: Border.all(color: Colors.orange.withOpacity(0.3)),
                         boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 3)]),
                       child: (cat.image_url != null) ? Image.network(cat.image_url!, headers: _imageHeaders, fit: BoxFit.contain) : const Icon(Icons.phone_android),
                     ),
                     const SizedBox(height: 5),
                     Text(cat.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                   ],
                 )
               );
             },
           );
        }
      )
    );
  }

  // --- PHẦN CHỈNH SỬA GRID VÀ CARD ---

  Widget _buildProductGrid() {
    return FutureBuilder<List<dynamic>>(
      future: _futureCombinedData,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();

        List<Product> listProducts = [];
        if (snapshot.data![0] is List<Product>) listProducts = snapshot.data![0] as List<Product>;
        List<ProductVariant> listVariants = [];
        if (snapshot.data![1] is List<ProductVariant>) listVariants = snapshot.data![1] as List<ProductVariant>;
        
        Set<int> hotProductIds = {};
        if (listProducts.isNotEmpty) {
           List<Product> sorted = List.from(listProducts);
           sorted.sort((a, b) => (b.soldCount).compareTo(a.soldCount));
           hotProductIds = sorted.take(10).map((p) => p.id).toSet();
        }

        // --- TÍNH TOÁN CỘT (RESPONSIVE) ---
        // Lấy chiều rộng màn hình hiện tại
        double screenWidth = MediaQuery.of(context).size.width;
        
        // Nếu Web (>1200) thì 5 cột, Tablet (>800) thì 4 cột, Mobile thì 2 cột
        int crossAxisCount = screenWidth >= 1200 ? 5 : screenWidth >= 800 ? 4 : 2;
        
        // Điều chỉnh tỷ lệ khung hình để Card không bị kéo giãn quá dài
        double childAspectRatio = screenWidth >= 800 ? 0.72 : 0.70;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount, // Số cột linh hoạt
              childAspectRatio: childAspectRatio, 
              crossAxisSpacing: 12, 
              mainAxisSpacing: 12
          ),
          itemCount: listVariants.length,
          itemBuilder: (context, index) {
            final variant = listVariants[index];
            bool isHot = hotProductIds.contains(variant.productId);
            
            // Sử dụng Widget _HoverProductCard đã tách bên dưới
            return _HoverProductCard(
              variant: variant,
              isHot: isHot,
              imageHeaders: _imageHeaders,
              onTap: () => _navigateToDetail(variant.productId, variant.id),
              formatCurrency: formatCurrency,
            );
          },
        );
      },
    );
  }
}

// --- WIDGET XỬ LÝ HOVER & UI ---
// Đặt cùng file, không cần tạo file mới
class _HoverProductCard extends StatefulWidget {
  final ProductVariant variant;
  final bool isHot;
  final Map<String, String> imageHeaders;
  final VoidCallback onTap;
  final Function(double?) formatCurrency;

  const _HoverProductCard({
    required this.variant,
    required this.isHot,
    required this.imageHeaders,
    required this.onTap,
    required this.formatCurrency,
  });

  @override
  State<_HoverProductCard> createState() => _HoverProductCardState();
}

class _HoverProductCardState extends State<_HoverProductCard> {
  // Biến trạng thái để kiểm tra chuột có đang trỏ vào hay không
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Bắt sự kiện chuột vào/ra
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click, // Đổi con trỏ chuột thành hình bàn tay
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), // Hiệu ứng chuyển màu mượt mà
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            // VIỀN: Nếu Hover -> Màu Đen, Bình thường -> Màu xám nhạt
            border: Border.all(
              color: _isHovering ? Colors.black : Colors.grey.shade200, 
              width: _isHovering ? 1.5 : 1 // Hover thì viền dày hơn chút
            ),
            // BÓNG: Nếu Hover -> Đậm hơn
            boxShadow: [
              BoxShadow(
                color: _isHovering ? Colors.black.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                blurRadius: _isHovering ? 10 : 5,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh sản phẩm
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        color: Colors.white,
                        child: Image.network(
                          widget.variant.imageUrl ?? '',
                          headers: widget.imageHeaders,
                          fit: BoxFit.contain, // Đảm bảo ảnh nằm gọn trong khung, không bị phóng to vỡ hình
                          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  
                  // Thông tin Text
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.variant.name ?? "Sản phẩm", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), 
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        if (widget.variant.color != null)
                          Text(widget.variant.color!, style: const TextStyle(fontSize: 11, color: Colors.orange)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.formatCurrency(widget.variant.price), 
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                            
                            // Nút giỏ hàng: Hover -> Màu đen, Bình thường -> Cam/Trắng
                            InkWell(
                              onTap: () async {
                                  await CartController.addToCart(widget.variant.id,1);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã thêm ${widget.variant.name} vào giỏ"), duration: const Duration(seconds: 1)));
                                  }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  // Nếu Hover khung to -> Nút giỏ hàng chuyển đen cho ngầu
                                  color: _isHovering ? Colors.black : Colors.white, 
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _isHovering ? Colors.black : Colors.orange)
                                ),
                                child: Icon(
                                  Icons.add_shopping_cart, 
                                  size: 18, 
                                  // Đổi màu icon tương phản
                                  color: _isHovering ? Colors.white : Colors.orange
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
              
              if (widget.isHot)
                Positioned(
                  top: 0, left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomRight: Radius.circular(8)),
                    ),
                    child: const Text("HOT", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}