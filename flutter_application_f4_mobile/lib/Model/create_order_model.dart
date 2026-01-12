class CreateOrderRequest {
  final String fullName;
  final String phoneNumber;
  final String address;
  final String note;
  final double totalMoney;
  final String paymentMethod; // "COD" hoặc "E_WALLET"
  final List<OrderDetailItem> orderDetails;

  CreateOrderRequest({
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.note,
    required this.totalMoney,
    required this.paymentMethod,
    required this.orderDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'address': address,
      'note': note,
      'total_money': totalMoney,
      'payment_method': paymentMethod,
      'order_details': orderDetails.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderDetailItem {
  final int productVariantId;
  final double price;
  final int quantity;
  final double totalMoney;

  OrderDetailItem({
    required this.productVariantId,
    required this.price,
    required this.quantity,
    required this.totalMoney,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_variant_id': productVariantId,
      'price': price,
      'quantity': quantity,
      'total_money': totalMoney,
    };
  }
}

class CreateOrderResponse {
  final bool succeeded;
  final String message;

  CreateOrderResponse({required this.succeeded, required this.message});

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      succeeded: json['succeeded'] ?? false,
      message: json['message'] ?? '',
    );
  }
}