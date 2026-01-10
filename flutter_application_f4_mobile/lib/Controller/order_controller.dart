import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/Order.dart';

class OrderController {
  static const String baseUrl = "https://irretentive-alex-wanly.ngrok-free.dev"; 

  // Lấy danh sách lịch sử mua hàng
  Future<List<Order>> getOrderHistory() async {
    final url = Uri.parse('$baseUrl/orders/order-history');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('user_token');

    if (token == null) return [];

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['orders'] != null) {
          return (data['orders'] as List)
              .map((e) => Order.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print("Lỗi getOrderHistory: $e");
    }
    return [];
  }

  // Lấy chi tiết đơn hàng (kèm sản phẩm)
  Future<Order?> getOrderDetail(int orderId) async {
    final url = Uri.parse('$baseUrl/orders/$orderId');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('user_token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Response trả về object "order"
        if (data['order'] != null) {
          return Order.fromJson(data['order']);
        }
      }
    } catch (e) {
      print("Lỗi getOrderDetail: $e");
    }
    return null;
  }
}