import 'product_model.dart'; 

class FavoriteModel {
  final int id;
  final int productId; // Dùng productId (không có gạch dưới)
  final Product? product; 

  FavoriteModel({
    required this.id,
    required this.productId,
    this.product,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0, // Phải là product_id như JSON server trả về
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}