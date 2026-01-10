import 'dart:convert';
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
}