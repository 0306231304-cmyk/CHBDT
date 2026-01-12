import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/create_order_model.dart';
import '../Model/cartModel.dart';

class CreateOrderController {
  // URL giống hệt bên DeleteCart
  final String baseUrl = 'https://irretentive-alex-wanly.ngrok-free.dev';

  Future<bool> createOrder({
    required String fullName,
    required String phone,
    required String address,
    required String note,
    required double totalPrice,
    required String paymentMethod,
    required List<CartItem> cartItems,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('user_token');

      if (token == null) {
        debugPrint("Lỗi: Chưa có Token");
        return false;
      }

      // 1. Convert CartItem sang OrderDetailItem
      List<OrderDetailItem> details = cartItems.map((item) {
        double price = item.price ?? 0;
        int qty = item.quantity ?? 1;
        return OrderDetailItem(
          productVariantId: item.productVariantId ?? 0,
          price: price,
          quantity: qty,
          totalMoney: price * qty,
        );
      }).toList();

      // 2. Tạo Body Request
      final requestBody = CreateOrderRequest(
        fullName: fullName,
        phoneNumber: phone,
        address: address,
        note: note,
        totalMoney: totalPrice,
        paymentMethod: paymentMethod,
        orderDetails: details,
      );

      // 3. Gọi API
      final response = await http.post(
        Uri.parse('$baseUrl/orders/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true', // Header quan trọng để qua mặt Ngrok
        },
        body: jsonEncode(requestBody.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        return CreateOrderResponse.fromJson(jsonResponse).succeeded;
      } else {
        debugPrint("Lỗi server: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Lỗi Exception: $e");
    }
    return false;
  }
}