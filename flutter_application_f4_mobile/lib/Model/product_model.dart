
// 1. Thêm dòng import này để lấy link ngrok từ Config
import '../Config/baseUrl.dart'; // Đảm bảo bạn đã có file này chứa link Ngrok

class Product {
  final int id;
  final int brandId;
  final String name;
  final String description;
  final String screenSize;
  final String cpu;
  final String camera;
  final String battery;
  final String imageUrl;
  final int soldCount;
  final String createdAt;
  final List<ProductVariant>? variants;

  Product({
    required this.id,
    required this.brandId,
    required this.name,
    required this.description,
    required this.screenSize,
    required this.cpu,
    required this.camera,
    required this.battery,
    required this.imageUrl,
    required this.soldCount,
    required this.createdAt,
    this.variants,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Logic ghép link ảnh cho Product cha
    String getFullUrl(String? path) {
      if (path == null || path.isEmpty) return "";
      if (path.startsWith("http")) return path;

      // Xử lý link Ngrok: bỏ đuôi /api nếu baseUrl có chứa /api để ghép với /uploads
      String rootUrl = baseUrl.endsWith('/api') 
          ? baseUrl.replaceAll('/api', '') 
          : baseUrl;
      
      // Xử lý dấu gạch chéo
      String cleanRoot = rootUrl.endsWith('/') ? rootUrl.substring(0, rootUrl.length - 1) : rootUrl;
      String cleanPath = path.startsWith('/') ? path : '/$path';
      
      return "$cleanRoot$cleanPath";
    }

    List<ProductVariant>? variantsList;
    if (json['variants'] != null) {
      var list = json['variants'] as List;
      variantsList = list.map((i) => ProductVariant.fromJson(i)).toList();
    }

    return Product(
      id: json['id'] ?? 0,
      brandId: json['brand_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      screenSize: json['screen_size'] ?? '',
      cpu: json['cpu'] ?? '',
      camera: json['camera'] ?? '',
      battery: json['battery'] ?? '',
      // Tự động ghép link cho ảnh
      imageUrl: getFullUrl(json['image_url'] ?? json['imageUrl'] ?? json['image']),
      soldCount: json['sold_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      variants: variantsList,
    );
  }
}

class ProductVariant {
  final int id;
  final int? brandId;
  final String? name;
  final String? description;
  final String? screenSize;
  final String? cpu;
  final String? camera;
  final String? battery;
  final int? productId;
  final String? color;
  final String? ram;
  final String? storage;
  final double? price;
  final int? stockQuantity;
  final String? imageUrl;

  ProductVariant({
    required this.id,
    this.brandId,
    this.name,
    this.description,
    this.screenSize,
    this.cpu,
    this.camera,
    this.battery,
    this.productId,
    this.color,
    this.ram,
    this.storage,
    this.price,
    this.stockQuantity,
    this.imageUrl,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    // Logic ghép link ảnh cho ProductVariant (QUAN TRỌNG VỚI TRANG HOME)
    String getFullUrl(String? path) {
      if (path == null || path.isEmpty) return "";
      if (path.startsWith("http")) return path;

      String rootUrl = baseUrl.endsWith('/api') 
          ? baseUrl.replaceAll('/api', '') 
          : baseUrl;
          
      String cleanRoot = rootUrl.endsWith('/') ? rootUrl.substring(0, rootUrl.length - 1) : rootUrl;
      String cleanPath = path.startsWith('/') ? path : '/$path';
      
      return "$cleanRoot$cleanPath";
    }

    return ProductVariant(
      id: json['id'] ?? 0,
      brandId: json['brand_id'] != null ? int.tryParse(json['brand_id'].toString()) : null,
      name: json['name'] as String?,
      description: json['description'],
      screenSize: json['screen_size'],
      cpu: json['cpu'],
      camera: json['camera'],
      battery: json['battery'],
      productId: json['product_id'] != null ? int.tryParse(json['product_id'].toString()) : null,
      color: json['color'],
      ram: json['ram'],
      storage: json['storage'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : 0.0,
      stockQuantity: json['stock_quantity'] != null ? int.tryParse(json['stock_quantity'].toString()) : 0,
      
      // SỬA LỖI Ở ĐÂY: Sử dụng hàm getFullUrl để đảm bảo ảnh luôn có link full
      imageUrl: getFullUrl(json['image'] ?? json['imageUrl'] ?? json['image_url']),
    );
  }
}