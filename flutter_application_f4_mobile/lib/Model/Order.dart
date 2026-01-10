class OrderItem {
  final String productName;
  final int quantity;
  final int price;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['product_name'] ?? "Sản phẩm",
      quantity: json['quantity'] ?? 1,
      price: json['price'] ?? 0,
    );
  }
}

class Order {
  final int id;
  final int totalPrice;
  final String status;
  final String createdAt;
  final List<OrderItem>? items; // Có thể null nếu chỉ xem lịch sử

  Order({
    required this.id,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List?;
    List<OrderItem>? itemsList = list?.map((i) => OrderItem.fromJson(i)).toList();

    return Order(
      id: json['id'],
      totalPrice: json['total_price'] ?? 0,
      status: json['status'] ?? "pending",
      createdAt: json['created_at'] ?? "",
      items: itemsList,
    );
  }
}