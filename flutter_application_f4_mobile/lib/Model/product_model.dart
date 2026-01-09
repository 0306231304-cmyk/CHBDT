class Product {
  final int id;
  final String name;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
    );
  }
}
