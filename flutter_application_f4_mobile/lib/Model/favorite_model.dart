/*class favoriteModel{
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
}*/


class FavoriteModel { // Đổi tên favoriteModel -> FavoriteModel (Chuẩn Dart)
  final int id;
  final int product_id;
  // Nếu API có trả về thông tin chi tiết sản phẩm (như tên, ảnh) lồng bên trong,
  // bạn cần khai báo thêm ở đây (ví dụ: final Product? product;). 
  // Hiện tại mình giữ nguyên theo code của bạn.

  FavoriteModel({
    required this.id,
    required this.product_id,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      // Dùng ?? 0 để nếu server trả về null thì app không bị crash
      id: json['id'] ?? 0, 
      product_id: json['product_id'] ?? 0,
    );
  }
}