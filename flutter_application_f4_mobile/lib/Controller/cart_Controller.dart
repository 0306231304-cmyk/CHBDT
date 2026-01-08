import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/cartModel.dart';

class CartController {
  final String baseUrl = 'http://192.168.30.212:3001';

  // --- 1. LẤY GIỎ HÀNG ---
  Future<CartResponse?> getCartData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('user_token');
    
    if (token != null && token.isNotEmpty) {
      return await _getCartFromServer(token);
    } else {
      return await _getCartFromLocal();
    }
  }

  Future<CartResponse?> _getCartFromServer(String token) async {
    try {
      await _mergeLocalCartToServer(token); // Gộp giỏ hàng trước khi lấy
      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CartResponse.fromJson(jsonData);
      }
    } catch (e) {
      print("Lỗi Server: $e");
    }
    return null;
  }

  Future<CartResponse?> _getCartFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartJson = prefs.getString('local_cart');
    
    if (cartJson != null) {
      List<dynamic> localList = jsonDecode(cartJson);
      int totalMoney = 0;
      
      // Tính tổng tiền dựa trên cấu trúc mới
      for (var item in localList) {
        totalMoney += (item['price'] as int) * (item['quantity'] as int);
      }

      List<CartItem> items = localList.map((i) => CartItem.fromJson(i)).toList();
      return CartResponse(succeeded: true, data: items, totalMoney: totalMoney);
    }
    return CartResponse(succeeded: true, data: [], totalMoney: 0);
  }

  // --- 2. LOGIC GỘP ---
  Future<void> _mergeLocalCartToServer(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartJson = prefs.getString('local_cart');

    if (cartJson != null) {
      List<dynamic> localList = jsonDecode(cartJson);
      if (localList.isNotEmpty) {
        for (var item in localList) {
          // Gửi đúng key product_variant_id lên server
          await http.post(
            Uri.parse('$baseUrl/cart/add'),
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
            body: jsonEncode({
              'product_variant_id': item['product_variant_id'],
              'quantity': item['quantity']
            }),
          );
        }
        await prefs.remove('local_cart');
      }
    }
  }

  // --- 3. THÊM VÀO GIỎ HÀNG ---
  Future<void> addToCart(CartItem newItem) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('user_token');

    if (token != null) {
      // Gọi API Add
       await http.post(
        Uri.parse('$baseUrl/cart/add'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'product_variant_id': newItem.productVariantId, 'quantity': newItem.quantity})
      );
    } else {
      // Lưu Local
      List<dynamic> currentList = [];
      if (prefs.getString('local_cart') != null) {
        currentList = jsonDecode(prefs.getString('local_cart')!);
      }

      bool exists = false;
      for (var item in currentList) {
        // So sánh product_variant_id
        if (item['product_variant_id'] == newItem.productVariantId) {
          item['quantity'] += newItem.quantity;
          exists = true;
          break;
        }
      }

      if (!exists) {
        currentList.add(newItem.toJson()); // toJson() đã match với cấu trúc Server
      }

      await prefs.setString('local_cart', jsonEncode(currentList));
    }
  }
}