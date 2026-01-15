
/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- CONTROLLER IMPORTS ---
import 'package:flutter_application_f4_mobile/Controller/brandsController.dart';
import '../../Controller/product_controller.dart';
import '../../Controller/cart_Controller.dart';

// --- MODEL IMPORTS ---
import '../../Model/product_model.dart';
import '../../Model/brandsModel.dart';

// --- VIEW IMPORTS ---
import 'package:flutter_application_f4_mobile/View/Category/category_screen.dart';
import 'package:flutter_application_f4_mobile/View/login_screen.dart';
import 'package:flutter_application_f4_mobile/View/profile_screen.dart';
import 'package:flutter_application_f4_mobile/View/shoppingcard_screen.dart';
import '../Category/product_by_category_screen.dart';
import '../Product/product_detail_screen.dart';
import '../Product/all_product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _futureCombinedData;
  late Future<List<BrandsModel>> _futureBrands;

  // --- BIẾN LOGIC TÌM KIẾM MỚI ---
  List<ProductVariant> _cachedAllVariants = []; // Lưu trữ toàn bộ sản phẩm để lọc
  String _searchText = ""; // Lưu từ khóa tìm kiếm
  
  String? _userToken;

  // --- SEARCH VARIABLES ---
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); 
  
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

    // Lấy dữ liệu và lưu vào Cache Local
    _futureCombinedData = Future.wait([
      ProductController.fetchProducts(),            
      ProductController.getAllProductVariants()     
    ]).then((data) {
      if (mounted) {
        setState(() {
          // Lưu danh sách biến thể vào biến cache
          _cachedAllVariants = data[1] as List<ProductVariant>;
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

  Future<void> _loadToken()async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token') ?? '';

    if(mounted) {
      setState(() {
        _userToken = token;
        _isLoading = false;
      });
    }
  }

 // --- LOGIC TÌM KIẾM LOCAL (Không gọi lại API) ---
  void _onSearchChanged(String query) {
    setState(() {
      _searchText = query.toLowerCase();
    });
  }

  // --- MAIN BUILD ---
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

            // --- LOGIC HIỂN THỊ ---
            Expanded(
              child: hasText
                  ? _buildSearchResultList() // Có chữ -> Hiện list tìm kiếm
                  : _buildHomeContent(),     // Không chữ -> Hiện trang chủ
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/Logo.png', height: 80, width: 80, fit: BoxFit.fill, errorBuilder: (_,__,___) => const Icon(Icons.store, size: 40, color: Colors.purple)),
        const Text("F4 MOBILE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder:(context) => ShoppingCardScreen())),
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
            ),
            const SizedBox(width: 15),
            IconButton(
              onPressed: () {
                if(_userToken != null && _userToken!.isNotEmpty){
                  Navigator.of(context).push(MaterialPageRoute(builder:(context) => ProfileScreen()));
                } else{
                  Navigator.of(context).push(MaterialPageRoute(builder:(context) => LoginScreen()));
                }
              },
              icon: const Icon(Icons.person_outline, color: Colors.black87),
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
        onChanged: _onSearchChanged, // Tìm kiếm ngay khi gõ
        decoration: InputDecoration(
          hintText: "Bạn muốn mua gì hôm nay?",
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
            : const Icon(Icons.mic_none, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // 3. HOME CONTENT
  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _futureCombinedData = Future.wait([
            ProductController.fetchProducts(),
            ProductController.getAllProductVariants()
          ]).then((data) {
             setState(() { _cachedAllVariants = data[1] as List<ProductVariant>; });
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
            _buildBanner(), // Banner ở đây
            const SizedBox(height: 20),
            _buildSectionTitle("Categories", onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => CategoryScreen()));
            }),
            const SizedBox(height: 10),
            _buildCategoryList(),
            const SizedBox(height: 20),
            _buildSectionTitle(
              "Featured products",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllProductsScreen(
                      products: [], // hoặc truyền list phù hợp
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),
            _buildProductGrid(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- LIST KẾT QUẢ TÌM KIẾM ---
  Widget _buildSearchResultList() {
    // Lọc cục bộ
    final results = _cachedAllVariants.where((variant) {
      final name = (variant.name ?? "").toLowerCase();
      return name.contains(_searchText);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 10),
            const Text("Không tìm thấy sản phẩm nào"),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final variant = results[index];

        // Xử lý ảnh
        Widget imageWidget;
        if (variant.imageUrl != null && variant.imageUrl!.isNotEmpty) {
          imageWidget = Image.network(
            variant.imageUrl!,
            width: 60, height: 60, fit: BoxFit.cover,
            headers: const {"ngrok-skip-browser-warning": "true"},
            errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
          );
        } else {
          imageWidget = Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.image_not_supported));
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageWidget,
          ),
          title: Row(
            children: [
              Text(variant.name ?? ''),
              SizedBox(width: 10,),
              Text(variant.color ?? '', style: TextStyle(color: Colors.amberAccent))
            ]
          ),
          //title: Text(variant.name ?? "Sản phẩm", style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(formatCurrency(variant.price), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          onTap: () async {
             await CartController.addToCart(null, variant.id);
             if(!mounted) return;
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã chọn ${variant.name}"), duration: const Duration(seconds: 1)));
          },
        );
      },
    );
  }

  // --- WIDGET BANNER (ĐÃ SỬA LẠI HEIGHT 300) ---
  Widget _buildBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/trangchu1.png',
        width: double.infinity,
        height: 300, // <--- ĐÃ TRẢ VỀ 300 CHO TO RA NHƯ CŨ
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 300,
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
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
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
            final List<BrandsModel>? brands = snapshot.data;
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: brands!.length,
              separatorBuilder: (context, index) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                final cat = brands[index];
                return InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductByCategoryScreen(category_id: cat.id, nameBrands: cat.name))),
                  child: Column(
                    children: [
                      Container(
                        width: 60, height: 60, padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3)]),
                        child: (cat.image_url != null) 
                          ? Image.network(cat.image_url, headers: const {"ngrok-skip-browser-warning": "true"}, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.image))
                          : const Icon(Icons.image),
                      ),
                      const SizedBox(height: 8),
                      Text(cat.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
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
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();

        List<Product> listProducts = snapshot.data![0] as List<Product>;
        List<ProductVariant> listVariants = snapshot.data![1] as List<ProductVariant>;
                  
        List<Product> sortedProducts = List.from(listProducts);
        sortedProducts.sort((a, b) => (b.soldCount).compareTo(a.soldCount));
        Set<int> hotProductIds = sortedProducts.take(10).map((p) => p.id).toSet();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 16, mainAxisSpacing: 16),
          itemCount: listVariants.length,
          itemBuilder: (context, index) {
            final variant = listVariants[index];
            bool isHot = (variant.productId != null && hotProductIds.contains(variant.productId));
            return _buildProductCard(variant, isHot);
          },
        );
      },
    );
  }

  Widget _buildProductCard(ProductVariant variant, bool isHot) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3))]),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: (variant.imageUrl != null)
                     ? Image.network(variant.imageUrl!, headers: const {"ngrok-skip-browser-warning": "true"}, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50))
                     : const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${variant.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), maxLines: 2, overflow: TextOverflow.ellipsis),
                      Text("${variant.color}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.amberAccent), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatCurrency(variant.price), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 26)),
                          Material(
                            color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () async {    
                                await CartController.addToCart(null, variant.id);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã thêm ${variant.name} vào giỏ hàng"), duration: const Duration(seconds: 1), backgroundColor: Colors.green));
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(padding: const EdgeInsets.all(15), child: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.orange)),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isHot)
              Positioned(
                top: 8, right: 8, 
                child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.local_fire_department, color: Colors.red, size: 20)),
              ),
          ],
        ),
      ),
    );
  }

}*/


//SƯỜN CODE HÔM QUA
/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- CONTROLLER IMPORTS ---
import '../../Controller/brandsController.dart';
import '../../Controller/product_controller.dart';
import '../../Controller/cart_Controller.dart';

// --- MODEL IMPORTS ---
import '../../Model/product_model.dart';
import '../../Model/brandsModel.dart';

// --- VIEW IMPORTS ---
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
  late Future<List<dynamic>> _futureCombinedData;
  late Future<List<BrandsModel>> _futureBrands;

  // --- BIẾN LOGIC TÌM KIẾM ---
  List<ProductVariant> _cachedAllVariants = []; 
  String _searchText = ""; 
  String? _userToken;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Header giúp ảnh load được qua Ngrok (quan trọng)
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

    // Load dữ liệu: Data[0] là Product cha, Data[1] là Variant (để hiển thị lưới)
    _futureCombinedData = Future.wait([
      ProductController.fetchProducts(),       // index 0
      ProductController.getAllProductVariants() // index 1
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
      setState(() {
        _userToken = token;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchText = query.toLowerCase();
    });
  }

  // --- HÀM CHUYỂN TRANG CHI TIẾT ---
  void _navigateToDetail(int? productId, int? productVariantID) {
    if (productId != null && productId > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: productId, productVariantId: productVariantID),
        ),
      );
    } else {
      print("Lỗi: Product ID bị null hoặc bằng 0");
    }
  }

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
                  ? _buildSearchResultList() // Search mode
                  : _buildHomeContent(),     // Home mode
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER & SEARCH ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Image.asset('assets/Logo.png', 
            height: 50, width: 50, fit: BoxFit.contain, 
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
                      ? const ProfileScreen() 
                      : const LoginScreen()));
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

  // --- HOME CONTENT ---
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
                // CHUYỂN TRANG: Truyền danh sách _cachedAllVariants sang AllProductsScreen
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (_) => AllProductsScreen(products: _cachedAllVariants)
                  )
                );
              },
            ),
            const SizedBox(height: 10),
            
            _buildProductGrid(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- DANH SÁCH TÌM KIẾM ---
  Widget _buildSearchResultList() {
    final results = _cachedAllVariants.where((variant) {
      final name = (variant.name ?? "").toLowerCase();
      return name.contains(_searchText);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 10),
            const Text("Không tìm thấy sản phẩm nào"),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final variant = results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60, height: 60,
              child: Image.network(
                variant.imageUrl ?? '',
                headers: _imageHeaders, // Thêm header
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.image)),
              ),
            ),
          ),
          title: Text(variant.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(formatCurrency(variant.price), style: const TextStyle(color: Colors.red)),
          onTap: () => _navigateToDetail(variant.productId, variant.id),
        );
      },
    );
  }

  // --- BANNER ---
  Widget _buildBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/trangchu1.png',
        width: double.infinity,
        height: 180, 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            color: Colors.grey[300],
            child: const Center(child: Text("Banner Image")),
          );
        },
      ),
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
                 onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProductByCategoryScreen(category_id: cat.id, nameBrands: cat.name))),
                 child: Column(
                   children: [
                     Container(
                       width: 55, height: 55, padding: const EdgeInsets.all(10),
                       decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, 
                         border: Border.all(color: Colors.orange.withOpacity(0.3)),
                         boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 3)]),
                       child: (cat.image_url != null) 
                         ? Image.network(cat.image_url!, headers: _imageHeaders, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Icon(Icons.phone_android))
                         : const Icon(Icons.phone_android, color: Colors.orange),
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

  // --- GRID SẢN PHẨM ---
  Widget _buildProductGrid() {
    return FutureBuilder<List<dynamic>>(
      future: _futureCombinedData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();

        List<Product> listProducts = [];
        if (snapshot.data![0] is List<Product>) {
           listProducts = snapshot.data![0] as List<Product>;
        }

        List<ProductVariant> listVariants = [];
        if (snapshot.data![1] is List<ProductVariant>) {
           listVariants = snapshot.data![1] as List<ProductVariant>;
        }
                  
        Set<int> hotProductIds = {};
        if (listProducts.isNotEmpty) {
           List<Product> sorted = List.from(listProducts);
           sorted.sort((a, b) => (b.soldCount).compareTo(a.soldCount));
           hotProductIds = sorted.take(10).map((p) => p.id).toSet();
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              childAspectRatio: 0.70, 
              crossAxisSpacing: 12, 
              mainAxisSpacing: 12
          ),
          itemCount: listVariants.length,
          itemBuilder: (context, index) {
            final variant = listVariants[index];
            bool isHot = hotProductIds.contains(variant.productId);
            return _buildProductCard(variant, isHot);
          },
        );
      },
    );
  }

  Widget _buildProductCard(ProductVariant variant, bool isHot) {
    return GestureDetector(
      onTap: () => _navigateToDetail(variant.productId, variant.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(12), 
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2))
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
                      padding: const EdgeInsets.all(10),
                      child: Image.network(
                        variant.imageUrl ?? '', 
                        headers: _imageHeaders, // THÊM HEADER ĐỂ LOAD ẢNH NGROK
                        fit: BoxFit.contain, 
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        },
                        errorBuilder: (context, error, stackTrace) {
                           return const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey));
                        },
                      ),
                    ),
                  ),
                ),
                // Thông tin Text
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(variant.name ?? "Sản phẩm", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), 
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      if (variant.color != null)
                        Text(variant.color!, style: const TextStyle(fontSize: 11, color: Colors.orange)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatCurrency(variant.price), 
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                          
                          // Nút thêm nhanh vào giỏ
                          InkWell(
                            onTap: () async {    
                               await CartController.addToCart(null, variant.id);
                               if (!mounted) return;
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                 content: Text("Đã thêm ${variant.name} vào giỏ"), 
                                 duration: const Duration(seconds: 1),
                               ));
                            },
                            child: const Icon(Icons.add_shopping_cart, size: 20, color: Colors.orange),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Icon HOT
            if (isHot)
              Positioned(
                top: 0, left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
    );
  }
}*/




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