import 'dart:convert';
import 'package:flutter_application_f4_mobile/Model/brandsModel.dart';
import 'package:http/http.dart' as http;
import '../Config/baseUrl.dart';
import '../debugConfig/fromJson.dart';

class BrandsController{
  static Future<List<BrandsModel>> getAllBrands()async{
    try{
      final respone = await http.get(
        Uri.parse("$baseUrl/categories"),
        headers: {
          "ngrok-skip-browser-warning": "true",
        }
      );
      logPrettyJsonString(respone.body);
      if(respone.statusCode == 200){
        Map<String,dynamic> data = jsonDecode(respone.body);
        List<dynamic> brands = data['categories'];
        return brands.map((brand) => BrandsModel.fromJson(brand)).toList();
      }
      return [];
    }
    catch(e){
      print("DEBUG (getAllBrands): $e");
      throw Exception("Lỗi server (brands): $e");
    }
  }
}