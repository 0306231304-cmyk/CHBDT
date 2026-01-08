class CartResponse {
  final bool succeeded;
  final List<CartItem> data;
  final int totalMoney;

  CartResponse({
    required this.succeeded,
    required this.data,
    required this.totalMoney,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      succeeded: json['succeeded'] ?? false,
      data: (json['data'] as List? ?? []).map((e) => CartItem.fromJson(e)).toList(),
      totalMoney: json['total_money'] ?? 0, // Chú ý key là total_money
    );
  }
}

class CartItem {
  final int productVariantId; // Sửa từ id thành product_variant_id
  final String productName;   // Sửa từ name thành product_name
  final String color;
  final String ram;
  final String storage;       // Thêm trường storage (như trong ảnh 256GB)
  final String price;
  final int quantity;
  final String imageUrl;      // Sửa từ image thành image_url

  CartItem({
    required this.productVariantId,
    required this.productName,
    required this.color,
    required this.ram,
    required this.storage,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productVariantId: json['product_variant_id'] ?? 0,
      productName: json['name'] ?? '',
      color: json['color'] ?? '',
      ram: json['ram'] ?? '',
      storage: json['storage'] ?? '',
      price: json['price'] ?? '0',
      quantity: json['quantity'] ?? 1,
      imageUrl: json['image_url'] ?? '',
    );
  }

  // Hàm này dùng để lưu xuống Local Storage (phải khớp key với Server)
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