class CartResponse {
  final bool succeeded;
  final List<CartItem> data;
  final double totalMoney;

  CartResponse({
    required this.succeeded,
    required this.data,
    required this.totalMoney,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      succeeded: json['succeeded'] ?? false,
      // Mapping danh sách CartItem
      data: (json['data'] as List? ?? []).map((e) => CartItem.fromJson(e)).toList(),
      
      // --- SỬA LỖI 1: Xử lý total_money ---
      // Chuyển về String rồi mới parse sang double để tránh lỗi type
      totalMoney: double.tryParse(json['total_money'].toString()) ?? 0.0,
    );
  }
}

class CartItem {
  final int? productVariantId;
  final String? productName;
  final String? color;
  final String? ram;
  final String? storage;
  final double? price;
  final int? quantity;
  final String? imageUrl;

  CartItem({
    this.productVariantId,
    this.productName,
    this.color,
    this.ram,
    this.storage,
    this.price,
    this.quantity,
    this.imageUrl,
  });

  // Hàm copyWith giữ nguyên, không cần sửa
  CartItem copyWith({
    int? productVariantId,
    String? productName,
    String? imageUrl,
    String? color,
    String? ram,
    String? storage,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      productVariantId: productVariantId ?? this.productVariantId,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      color: color ?? this.color,
      ram: ram ?? this.ram,
      storage: storage ?? this.storage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productVariantId: json['product_variant_id'] ?? 0,
      productName: json['name'] ?? '', // Kiểm tra lại server trả về 'name' hay 'product_name'
      color: json['color'] ?? '',
      ram: json['ram'] ?? '',
      storage: json['storage'] ?? '',
      
      // --- SỬA LỖI 2: Xử lý price ---
      // json['price'] đang là String "30990000.00", gán thẳng vào double sẽ lỗi
      // Cách sửa: .toString() -> tryParse -> nếu lỗi thì lấy 0.0
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      
      quantity: json['quantity'] ?? 1,
      imageUrl: json['image'] ?? '',
    );
  }
  
  // Hàm toJson nếu cần dùng để lưu xuống LocalStorage
  Map<String, dynamic> toJson() {
    return {
      'product_variant_id': productVariantId,
      'name': productName,
      'color': color,
      'ram': ram,
      'storage': storage,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
    };
  }
}