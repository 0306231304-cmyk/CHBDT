class UpdateCartRequest {
  final int productVariantId;
  final int quantity;

  UpdateCartRequest({
    required this.productVariantId,
    required this.quantity,
  });

  // Dùng để đóng gói dữ liệu gửi lên Server
  Map<String, dynamic> toJson() {
    return {
      'variant_id': productVariantId,
      'quantity': quantity,
    };
  }
}

class UpdateCartResponse {
  final bool succeeded;
  final String message;

  UpdateCartResponse({
    required this.succeeded,
    required this.message,
  });

  // Dùng để nhận kết quả từ Server
  factory UpdateCartResponse.fromJson(Map<String, dynamic> json) {
    return UpdateCartResponse(
      succeeded: json['succeeded'] ?? false,
      message: json['message'] ?? '',
    );
  }
}