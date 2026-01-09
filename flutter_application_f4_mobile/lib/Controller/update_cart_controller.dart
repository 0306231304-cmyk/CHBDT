import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/update_cart_model.dart'; // Import model request/response

class UpdateCartController {
  // Copy y chang IP từ CartController của bạn
  final String baseUrl = 'http://192.168.30.212:3001';

  // --- HÀM CHÍNH: QUYẾT ĐỊNH DÙNG SERVER HAY LOCAL ---
  Future<bool> updateCartQuantity(int variantId, int newQuantity) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('user_token'); // Key token giống CartController

    if (token != null && token.isNotEmpty) {
      // Có Token -> Gọi lên Server
      return await _updateOnServer(token, variantId, newQuantity);
    } else {
      // Không Token -> Sửa ở Local Storage
      return await _updateOnLocal(variantId, newQuantity);
    }
  }

  // --- 1. XỬ LÝ TRÊN SERVER (KHI ĐÃ LOGIN) ---
  Future<bool> _updateOnServer(String token, int variantId, int newQuantity) async {
    try {
      final requestModel = UpdateCartRequest(
        productVariantId: variantId,
        quantity: newQuantity,
      );

      // Gọi API Update (kiểm tra lại endpoint backend của bạn có phải /cart/update ko nhé)
      final response = await http.post(
        Uri.parse('$baseUrl/cart/update'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestModel.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Nếu server trả về JSON kết quả
        final responseData = jsonDecode(response.body);
        return UpdateCartResponse.fromJson(responseData).succeeded;
        
        // Hoặc nếu lười check model thì cứ return true;
      }
    } catch (e) {
      print("Lỗi Update Server: $e");
    }
    return false;
  }

  // --- 2. XỬ LÝ DƯỚI LOCAL (KHI CHƯA LOGIN) ---
  // Logic này update trực tiếp vào chuỗi JSON 'local_cart'
  Future<bool> _updateOnLocal(int variantId, int newQuantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? cartJson = prefs.getString('local_cart');

      if (cartJson != null) {
        // 1. Giải nén chuỗi JSON thành List
        List<dynamic> currentList = jsonDecode(cartJson);
        bool found = false;

        // 2. Tìm sản phẩm và sửa số lượng
        for (var item in currentList) {
          if (item['product_variant_id'] == variantId) {
            item['quantity'] = newQuantity; // Cập nhật số lượng mới
            found = true;
            break;
          }
        }

        // 3. Nếu tìm thấy thì Lưu ngược lại vào máy
        if (found) {
          await prefs.setString('local_cart', jsonEncode(currentList));
          return true;
        }
      }
    } catch (e) {
      print("Lỗi Update Local: $e");
    }
    return false;
  }
}