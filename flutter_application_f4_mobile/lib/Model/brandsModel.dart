class BrandsModel{
  final int id;
  final String name;
  final String image_url;

  BrandsModel({
    required this.id,
    required this.image_url,
    required this.name
  });

  factory BrandsModel.fromJson(Map<String,dynamic> json){
    return BrandsModel(
      id: json['id'],
      name: json['name'],
      image_url: json['image_url']
    );
  }
}