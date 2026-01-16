import 'product_model.dart'; 

class FavoriteModel {
  final int id;
  final int productVariantId; // Dùng productId (không có gạch dưới)
  final String name;
  final int productID;
  final String color;
  final String storage;
  final double price;
  final String image;

  FavoriteModel({
    required this.id,
    required this.productVariantId,
    required this.name,
    required this.productID,
    required this.color,
    required this.storage,
    required this.price,
    required this.image
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] ?? 0,
      productVariantId: json['product_variant_id'] ?? 0,
      name: json['name'],
      productID: json['product_id'],
      color: json['color'],
      storage: json['storage'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      image: json['image']
    );
  }
}

class FavoriteRespone{
  final bool succeeded;
  final String? message;
  final List<FavoriteModel>? favorites;

  FavoriteRespone({
    required this.succeeded,
    this.favorites,
    this.message
  });

  factory FavoriteRespone.fromJson(Map<String, dynamic> json){
    return FavoriteRespone(
      succeeded: json['succeeded'],
      message: json['message'],
      favorites: (json['favorites'] as List).map(
        (i) =>
        FavoriteModel.fromJson(i)
      ).toList()
    );
  }
}