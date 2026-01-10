class favoriteModel{
  final int id;
  final int product_id;

  favoriteModel({
    required this.id,
    required this.product_id,
  });

  factory favoriteModel.fromJson(Map<String, dynamic> json){
    return favoriteModel(
      id: json['id'],
      product_id: json['product_id'],
    );
  }
}