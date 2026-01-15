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
      data: (json['data'] as List? ?? []).map((e) => CartItem.fromJson(e)).toList(),
      // Parse safe double
      totalMoney: double.tryParse(json['total_money'].toString()) ?? 0.0,
    );
  }
}

class CartItem {
  int? productVariantId;
  String? productName;
  String? color;
  String? ram;
  String? storage;
  double? price;
  int? quantity;
  String? imageUrl;

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

  // QUAN TRỌNG: Hàm này giúp sửa lỗi gán biến final
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
      productName: json['name'] ?? '', 
      color: json['color'] ?? '',
      ram: json['ram'] ?? '',
      storage: json['storage'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: json['quantity'] ?? 1,
      imageUrl: json['image'] ?? '',
    );
  }
}