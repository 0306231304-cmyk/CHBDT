import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/product_model.dart';

class ProductController {
  static const String PRODUCT_API =
      "https://irretentive-alex-wanly.ngrok-free.dev/products"; // 👈 sửa lại

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse(PRODUCT_API),
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List list = data['products'];
      return list.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("Không lấy được danh sách sản phẩm");
    }
  }
}
