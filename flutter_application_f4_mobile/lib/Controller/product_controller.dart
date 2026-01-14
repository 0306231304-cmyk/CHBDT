import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/product_model.dart';
import '../Config/baseUrl.dart';
import '../Model/review_model.dart'; // Đảm bảo dòng này không bị lỗi đỏ

class ProductController {
  
  static final Map<String, String> _headers = {
    "ngrok-skip-browser-warning": "true",
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/products"), headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (data['succeeded'] == true && data['products'] != null) {
          final List<dynamic> productList = data['products'];
          return productList.map((e) => Product.fromJson(e)).toList();
        }
      }
    } catch (e) { print("Error fetchProducts: $e"); }
    return [];
  }

  static Future<List<ProductVariant>> getAllProductVariants() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/product-variants/get-all'), headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (data['succeeded'] == true && data['product_variants'] != null) {
          List<dynamic> variantList = data['product_variants'];
          return variantList.map((item) => ProductVariant.fromJson(item)).toList();
        }
      }
    } catch (e) { print("Error getAllProductVariants: $e"); }
    return [];
  }

  static Future<Product?> getProductDetail(int id) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/products/$id"), headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['succeeded'] == true && data['product'] != null) {
          return Product.fromJson(data['product']);
        }
      }
    } catch (e) { print("Error getProductDetail: $e"); }
    return null;
  }

  static Future<List<ProductVariant>> getVariantsByProductId(int productId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/products/product-variants/$productId"), headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['succeeded'] == true && data['product_variants'] != null) {
          List<dynamic> list = data['product_variants'];
          return list.map((e) => ProductVariant.fromJson(e)).toList();
        }
      }
    } catch (e) { print("Error getVariantsByProductId: $e"); }
    return [];
  }

  static Future<List<Product>> searchProducts(String keyword) async {
    if (keyword.trim().isEmpty) return [];
    try {
      final response = await http.get(Uri.parse("$baseUrl/products/search?q=$keyword"), headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['succeeded'] == true && data['products'] != null) {
          final List<dynamic> list = data['products'];
          return list.map((e) => Product.fromJson(e)).toList();
        }
      }
    } catch (e) { print("Error searchProducts: $e"); }
    return [];
  }

  // --- PHẦN MỚI THÊM CHO REVIEW ---
  static Future<List<Review>> getReviews(int productId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/products/$productId/reviews"), headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['succeeded'] == true && data['reviews'] != null) {
           return (data['reviews'] as List).map((e) => Review.fromJson(e)).toList();
        }
      }
    } catch (e) { print("Error getReviews: $e"); }
    return [];
  }

  static Future<bool> postReview(int productId, String content, double rating) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('user_token');

      if (token == null || token.isEmpty) return false;

      final url = Uri.parse('$baseUrl/products/add-review');

      // CHUẨN BỊ DỮ LIỆU JSON
      final body = {
        'product_id': productId,
        'rating': rating.toInt(), // Ép về số nguyên (5)
        'content': content,       // <--- ĐỔI KEY TỪ 'comment' SANG 'content'
      };

      print("--- GỬI REVIEW (JSON FIXED) ---");
      print("URL: $url");
      print("Body: $body");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // BẮT BUỘC PHẢI CÓ
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body), // Gửi JSON
      );

      print("Status Code: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['succeeded'] == true) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Lỗi postReview: $e");
      return false;
    }
  }
}
