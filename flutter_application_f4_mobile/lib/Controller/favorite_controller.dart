/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/favorite_model.dart';
import '../Config/baseUrl.dart';

class FavoriteController {
  static Future<List<favoriteModel>> fecthFavorite() async{
    try{
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      final respone = await http.get(
        Uri.parse('$baseUrl/favorites/get-all'),
        headers: {
          'Authorization' : 'Bearer $token'
        }
      );

      if(respone.statusCode == 200){
        final Map<String, dynamic> data = jsonDecode(respone.body);

        if(data['succeeded']){
          final List<dynamic> favoriteList = data['favorites'];
          return favoriteList.map((e) => favoriteModel.fromJson(e)).toList();
        }
        else{
          throw Exception(data['message'] ?? 'Lỗi server');
        }
      }
      else{
        throw Exception('Lỗi kết nối server ${respone.statusCode}');
      }
    }
    catch(e){
      print('Lỗi không thể tải danh sách sản phẩm ưa thích: $e');
      throw Exception('Không thể tải danh sách sản phẩm ưa thích');
    }
  }

  static Future<bool> addFavorite(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      
      // Giả định API endpoint là /favorites/add hoặc tương tự
      final response = await http.post(
        Uri.parse('$baseUrl/favorites/add'), // <--- Kiểm tra lại đường dẫn API của bạn
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_id': productId, 
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Kiểm tra xem backend trả về thành công hay không
        return data['succeeded'] ?? false; 
      } else {
        print('Lỗi thêm favorite: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception addFavorite: $e');
      return false;
    }
  }

  // 2. Hàm Xóa khỏi danh sách ưa thích
  static Future<bool> removeFavorite(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');

      // Giả định API xóa cần gửi product_id
      // Nếu API của bạn cần ID của dòng favorite (favorite_id), logic sẽ khác một chút
      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/remove/$productId'), // <--- Kiểm tra lại endpoint xóa
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        // Nếu API yêu cầu body cho method DELETE:
        /*
        body: jsonEncode({
          'product_id': productId,
        }),
        */
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['succeeded'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Exception removeFavorite: $e');
      return false;
    }
  }

  // 3. Hàm kiểm tra xem sản phẩm này đã được thích chưa
  // (Cách đơn giản: Lấy toàn bộ list về và tìm ID)
  static Future<bool> checkIsFavorite(int productId) async {
    try {
      List<favoriteModel> list = await fecthFavorite(); // Gọi hàm fetch cũ
      // Kiểm tra xem có item nào có product_id trùng với productId đang xem không
      bool exists = list.any((element) => element.product_id == productId);
      return exists;
    } catch (e) {
      return false;
    }
  }
}*/
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/favorite_model.dart';
import '../Config/baseUrl.dart';

class FavoriteController {
  static Map<String, String> getHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  static Future<List<FavoriteModel>> fecthFavorite() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token') ?? '';
      
      final response = await http.get(
        Uri.parse('$baseUrl/products/favorites/get-all'),
        headers: getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['succeeded'] == true && data['favorites'] != null) {
          final List<dynamic> favoriteList = data['favorites'];
          return favoriteList.map((e) => FavoriteModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Lỗi fetchFavorite: $e");
      return [];
    }
  }

  static Future<bool> addFavorite(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token') ?? '';
      final response = await http.post(
        Uri.parse('$baseUrl/products/favorites/add/$productId'),
        headers: getHeaders(token),
      );
      return (response.statusCode == 200 || response.statusCode == 201);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removeFavorite(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token') ?? '';
      
      // Sửa lại URL cho khớp với lệnh ADD (thêm /products)
      final response = await http.delete(
        Uri.parse('$baseUrl/products/favorites/remove/$productId'),
        headers: getHeaders(token),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkIsFavorite(int productId) async {
    try {
      List<FavoriteModel> list = await fecthFavorite();
      // Kiểm tra dựa trên productId bên trong model
      return list.any((element) => element.productId == productId);
    } catch (e) {
      return false;
    }
  }
}