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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      brandId: json['brand_id'] ?? 0, // Khớp với JSON "brand_id"
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      screenSize: json['screen_size'] ?? '', // Khớp với JSON "screen_size"
      cpu: json['cpu'] ?? '',
      camera: json['camera'] ?? '',
      battery: json['battery'] ?? '',
      imageUrl: json['image_url'] ?? '', // Khớp với JSON "image_url"
      soldCount: json['sold_count'] ?? 0, // Khớp với JSON "sold_count"
      createdAt: json['created_at'] ?? '',
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

  // Hàm chuyển từ JSON sang Object
  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'],
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
      // Xử lý giá: JSON trả về chuỗi "34990000.00" nên cần parse sang double
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : 0.0,
      stockQuantity: json['stock_quantity'] != null ? int.tryParse(json['stock_quantity'].toString()) : 0,
      imageUrl: json['image_url'],
    );
  }

  // Hàm chuyển từ Object sang JSON (nếu cần gửi dữ liệu đi)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand_id': brandId,
      'name': name,
      'description': description,
      'screen_size': screenSize,
      'cpu': cpu,
      'camera': camera,
      'battery': battery,
      'product_id': productId,
      'color': color,
      'ram': ram,
      'storage': storage,
      'price': price,
      'stock_quantity': stockQuantity,
      'image_url': imageUrl,
    };
  }
}