import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/product_model.dart'; // Đảm bảo đường dẫn đúng
import '../Config/baseUrl.dart';
import 'dart:developer' as dev;

void logPrettyJsonString(String jsonString) {
  try {
    // BƯỚC 1: Biến chuỗi String hỗn độn thành Object (Map hoặc List)
    dynamic jsonObject = jsonDecode(jsonString);

    // BƯỚC 2: Biến Object đó trở lại thành String nhưng có định dạng đẹp (thụt lề 2 space)
    var encoder = const JsonEncoder.withIndent("  ");
    String prettyString = encoder.convert(jsonObject);

    // BƯỚC 3: Dùng log thay vì print để tránh bị cắt bớt nếu nội dung quá dài
    dev.log(prettyString, name: 'JSON PRETTY'); 
    
  } catch (e) {
    // Nếu chuỗi không đúng chuẩn JSON, in báo lỗi và in chuỗi gốc
    print("Lỗi format JSON: $e");
    print(jsonString);
  }
}

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
      print("🎯 Status Code: ${response.statusCode}");
      logPrettyJsonString(response.body);
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