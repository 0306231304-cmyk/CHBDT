import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/product_model.dart'; // Đảm bảo đường dẫn đúng
import '../Config/baseUrl.dart';

class ProductController {

  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/products"),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        // Sử dụng utf8.decode để hiển thị tiếng Việt chính xác
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        if (data['succeeded'] == true) {
          final List<dynamic> productList = data['products'];
          return productList.map((e) => Product.fromJson(e)).toList();
        } else {
          throw Exception(data['message'] ?? "Lỗi server trả về");
        }
      } else {
        throw Exception("Lỗi kết nối server: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching products: $e");
      throw Exception("Không thể tải danh sách sản phẩm");
    }
  }

  static Future<List<ProductVariant>> getAllProductVariants() async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/products/product-variants/get-all'),
          headers: {
            "ngrok-skip-browser-warning": "true",
          }
      );
      if (response.statusCode == 200) {
        // 1. Decode dữ liệu JSON thô
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // 2. Kiểm tra biến 'succeeded' từ server trả về
        if (responseData['succeeded'] == true) {
          
          // 3. Lấy danh sách từ key 'product_variants'
          List<dynamic> variantList = responseData['product_variants'];

          // 4. Map từng phần tử sang Object Model
          List<ProductVariant> result = variantList
              .map((item) => ProductVariant.fromJson(item))
              .toList();
              
          return result;
        } else {
          // Trường hợp server trả về succeeded: false
          throw Exception(responseData['message'] ?? "Lỗi logic từ server");
        }
      } else {
        throw Exception("Lỗi kết nối server: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi (getAllProductVariants): $e");
    }
  }
}