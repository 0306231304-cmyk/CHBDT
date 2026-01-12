class DeleteCartRequest {
  final int productVariantId;

  DeleteCartRequest({
    required this.productVariantId,
  });

  Map<String, dynamic> toJson() {
    return {
      'variant_id': productVariantId,
    };
  }
}

class DeleteCartResponse {
  final bool succeeded;
  final String message;

  DeleteCartResponse({
    required this.succeeded,
    required this.message,
  });

  factory DeleteCartResponse.fromJson(Map<String, dynamic> json) {
    return DeleteCartResponse(
      succeeded: json['succeeded'] ?? false,
      message: json['message'] ?? '',
    );
  }
}