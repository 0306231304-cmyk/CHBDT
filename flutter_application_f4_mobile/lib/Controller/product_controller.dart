/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/product_model.dart';
import '../Config/baseUrl.dart';
import '../Model/review_model.dart';

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
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['succeeded'] == true) {
          List<dynamic> variantList = responseData['product_variants'];
          List<ProductVariant> result = variantList
              .map((item) => ProductVariant.fromJson(item))
              .toList();
          return result;
        } else {
          throw Exception(responseData['message'] ?? "Lỗi logic từ server");
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
  static Future<ReviewData?> getReviews(int productId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/products/reviews/$productId"), 
        headers: _headers
      );

      if (response.statusCode == 200) {
        final jsonMap = json.decode(utf8.decode(response.bodyBytes));
        
        // 1. Parse toàn bộ JSON qua ReviewResponse
        final res = ReviewResponse.fromJson(jsonMap);

        // 2. Kiểm tra thành công và trả về data (ReviewData)
        if (res.succeeded && res.data != null) {
          return res.data; 
        }
      }
    } catch (e) {
      print("Error getReviews: $e");
    }
    return null; // Trả về null nếu lỗi hoặc không có dữ liệu
  }

  static Future<bool> postReview(int productId, String content, double rating) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('user_token');

      if (token == null || token.isEmpty) return false;

      final url = Uri.parse('$baseUrl/products/add-review');
      final body = {
        'product_id': productId,
        'rating': rating.toInt(), // Đảm bảo gửi số nguyên
        'comment': content, // Backend nhận key 'comment'
      };

      print("--- Sending Review ---");
      print("Body: $body");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

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
  
  static Future<Product?> getProductById(int id) async {
    return getProductDetail(id); // Tái sử dụng hàm getProductDetail ở trên cho gọn
  }
}*/

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/product_model.dart';
import '../Config/baseUrl.dart';
import '../Model/review_model.dart';

class ProductController {
  
  static final Map<String, String> _headers = {
    "ngrok-skip-browser-warning": "true",
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

  // Lấy danh sách sản phẩm (Trang Home)
  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/products"), headers: _headers);
      if (response.statusCode == 200) {
        // utf8.decode để tránh lỗi font tiếng Việt
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (data['succeeded'] == true && data['products'] != null) {
          final List<dynamic> productList = data['products'];
          return productList.map((e) => Product.fromJson(e)).toList();
        }
      }
    } catch (e) { print("Error fetchProducts: $e"); }
    return [];
  }

  // Lấy chi tiết một sản phẩm (Dùng để hiển thị Card trong FavoriteScreen)
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

  // Bí danh để gọi cho dễ nhớ
  static Future<Product?> fetchProductById(int id) async {
    return getProductDetail(id);
  }

  // Tìm kiếm sản phẩm
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

  // --- REVIEW ---
  static Future<ReviewData?> getReviews(int productId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/products/reviews/$productId"), 
        headers: _headers
      );

      if (response.statusCode == 200) {
        final jsonMap = json.decode(utf8.decode(response.bodyBytes));
        final res = ReviewResponse.fromJson(jsonMap);
        if (res.succeeded && res.data != null) {
          return res.data; 
        }
      }
    } catch (e) { print("Error getReviews: $e"); }
    return null;
  }

  static Future<bool> postReview(int productId, String content, double rating) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('user_token');

      if (token == null || token.isEmpty) return false;

      final url = Uri.parse('$baseUrl/products/add-review');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_id': productId,
          'rating': rating.toInt(),
          'comment': content,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['succeeded'] == true;
      }
      return false;
    } catch (e) {
      print("Lỗi postReview: $e");
      return false;
    }
  }

  // --- OPTIONAL: Lấy tất cả các biến thể ---
  static Future<List<ProductVariant>> getAllProductVariants() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/product-variants/get-all'), headers: _headers);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['succeeded'] == true) {
          List<dynamic> variantList = responseData['product_variants'];
          return variantList.map((item) => ProductVariant.fromJson(item)).toList();
        }
      }
    } catch (e) { print("Error getAllProductVariants: $e"); }
    return [];
  }
}