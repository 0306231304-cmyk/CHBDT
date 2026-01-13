import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/create_order_model.dart';
import '../Model/cartModel.dart';
import '../Config/baseUrl.dart';

class CreateOrderController {

  Future<bool> createOrder({
    required String fullName,
    required String phone,
    required String address,
    required String city,       // <--- Nhận tham số City
    required String couponCode, // <--- Nhận tham số Coupon
    required String note,
    required double totalPrice,
    required bool isBuyNow,
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

      // 1. Convert CartItem -> OrderDetailItem
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

      // 2. Tạo Request Body với đầy đủ dữ liệu final
      final requestBody = CreateOrderRequest(
        fullName: fullName,
        phoneNumber: phone,
        address: address,
        city: city,               // <--- Đưa vào Model
        couponCode: couponCode,   // <--- Đưa vào Model
        note: note,
        totalMoney: totalPrice,
        paymentMethod: paymentMethod,
        is_buy_now: isBuyNow,
        orderDetails: details,
      );

      // 3. Gọi API
      final response = await http.post(
        Uri.parse('$baseUrl/orders/order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode(requestBody.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        return CreateOrderResponse.fromJson(jsonResponse).succeeded;
      } else {
        debugPrint("Lỗi Server: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Lỗi Exception: $e");
    }
    return false;
  }
}