import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/delete_cart_model.dart';
import '../Config/baseUrl.dart';

class DeleteCartController {
  // CẬP NHẬT URL MỚI TẠI ĐÂY


  // --- HÀM CHÍNH ---
  Future<bool> deleteCartItem(int variantId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('user_token');

    if (token != null && token.isNotEmpty) {
      return await _deleteOnServer(token, variantId);
    } else {
      return await _deleteOnLocal(variantId);
    }
  }

  // 1. XÓA TRÊN SERVER
  Future<bool> _deleteOnServer(String token, int variantId) async {
    try {
      final requestBody = DeleteCartRequest(productVariantId: variantId);

      // Gọi API DELETE: /cart/remove
      // Lưu ý: http.delete có hỗ trợ body để gửi variant_id
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/remove'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode(requestBody.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return DeleteCartResponse.fromJson(responseData).succeeded;
      }
    } catch (e) {
      debugPrint("Lỗi Delete Server: $e");
    }
    return false;
  }

  // 2. XÓA DƯỚI LOCAL (Offline)
  Future<bool> _deleteOnLocal(int variantId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? cartJson = prefs.getString('local_cart');

      if (cartJson != null) {
        List<dynamic> currentList = jsonDecode(cartJson);
        int initialLength = currentList.length;

        // Xóa phần tử có variant_id tương ứng
        currentList.removeWhere((item) => item['product_variant_id'] == variantId);

        // Nếu độ dài thay đổi nghĩa là đã xóa thành công -> Lưu lại
        if (currentList.length < initialLength) {
          await prefs.setString('local_cart', jsonEncode(currentList));
          return true;
        }
      }
    } catch (e) {
      debugPrint("Lỗi Delete Local: $e");
    }
    return false;
  }
}