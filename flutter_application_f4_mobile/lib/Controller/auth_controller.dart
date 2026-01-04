import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/User.dart';

class AuthController {
  static const String baseUrl = "https://irretentive-alex-wanly.ngrok-free.dev"; 

  // --- 1. HÀM ĐĂNG KÝ ---
  Future<void> register(BuildContext context, {
    required String email,
    required String password,
    String? fullname,            
    String? phone,           
    String? address,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    print("🌍 Calling Register API: $url");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullname': fullname ?? '',   
          'phone': phone ?? '', 
          'address': address ?? '',
        }),
      );

      print("Response Code: ${response.statusCode}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thành công! Hãy đăng nhập."), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Về màn hình Login
      } else {
        final errorData = jsonDecode(response.body);
        String message = errorData['message'] ?? "Đăng ký thất bại";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi kết nối Server!"), backgroundColor: Colors.red),
      );
    }
  }

  // --- 2. HÀM ĐĂNG NHẬP ---
  Future<void> login(BuildContext context, String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    print("🌍 Calling Login API: $url");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email, 
          'password': password,
        }),
      );

      print("Login Status: ${response.statusCode}");
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['succeeded'] == true) {
        String token = data['token'];
        
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', token);
        await prefs.setString('email', email);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng nhập thành công!"), backgroundColor: Colors.green),
        );
        
      } else {
        String message = data['message'] ?? "Sai Email hoặc mật khẩu";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("Error Login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể kết nối Server"), backgroundColor: Colors.red),
      );
    }
  }

  // --- 3. HÀM LẤY PROFILE ---
  Future<User?> getProfile() async {
    final url = Uri.parse('$baseUrl/profile');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('user_token');

    if (token == null) return null;

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']); 
      }
    } catch (e) {
      print("Lỗi kết nối Profile: $e");
    }
    return null;
  }
  
  // --- 4. HÀM ĐĂNG XUẤT ---
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
    await prefs.remove('email');
  }
}