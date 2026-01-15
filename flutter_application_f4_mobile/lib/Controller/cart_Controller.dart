


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/cartModel.dart';
import '../Config/baseUrl.dart';

class CartController {

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

  static Future<CartResponse?> _getCartFromServer(String token) async {
    try {
      await _mergeLocalCartToServer(token); // Gộp giỏ hàng trước khi lấy
      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: {
          "ngrok-skip-browser-warning": "true",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CartResponse.fromJson(jsonData);
      }
      print("Lỗi lấy danh sách sản phẩm trong giỏ hàng trên server (${response.statusCode}): ${jsonDecode(response.body)['message']}");
    } catch (e) {
      print("Lỗi lấy danh sách sản phẩm trong giỏ hàng trên server: $e");
    }
    return null;
  }

  // --- Hàm xử lý lấy giỏ hàng Local (Khi chưa đăng nhập) ---
  static Future<CartResponse?> _getCartFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    String? localCartJson = prefs.getString('local_cart');

    // 1. Nếu local chưa có gì, trả về rỗng (đúng format Model)
    if (localCartJson == null || localCartJson.isEmpty) {
      return CartResponse(succeeded: true, data: [], totalMoney: 0);
    }

    List<dynamic> localList = [];
    try {
      localList = jsonDecode(localCartJson);
      print('LOCAL CART JSON: $localList');
    } catch (e) {
      return CartResponse(succeeded: true, data: [], totalMoney: 0);
    }

    // 2. Gọi API lấy danh sách biến thể để tra cứu thông tin
    try {
      // Đảm bảo URL này đúng với server của bạn
      final response = await http.get(
          Uri.parse('$baseUrl/products/product-variants/get-all'),
          headers: {
            "ngrok-skip-browser-warning": "true",
          }  
        );

      if (response.statusCode == 200) {
        final serverData = jsonDecode(response.body);
        
        if (serverData['succeeded'] == true) {
          List<dynamic> allVariants = serverData['product_variants'];
          List<CartItem> finalCartItems = [];
          double tempTotalMoney = 0.0;

          // 3. Vòng lặp ghép dữ liệu
          for (var localItem in localList) {
            int localId = localItem['product_variant_id'];
            int localQty = localItem['quantity'] ?? 1;

            // Tìm thông tin trên server khớp với ID local
            var variantInfo = allVariants.firstWhere(
              (v) => v['id'] == localId,
              orElse: () => null,
            );

            if (variantInfo != null) {
              double price = double.tryParse(variantInfo['price'].toString()) ?? 0.0;
              print("DEBUG: $localId\n ${variantInfo['name']}\n ${variantInfo['storage']}");
              // Tạo CartItem đúng với tên trường trong cartModel.dart
              final item = CartItem(
                productVariantId: localId,
                productName: variantInfo['name'], // Model dùng productName
                color: variantInfo['color'],      // Map thêm màu
                ram: variantInfo['ram'],          // Map thêm ram
                storage: variantInfo['storage'],  // Map thêm bộ nhớ
                imageUrl: variantInfo['image'], // Model dùng imageUrl
                price: price,
                quantity: localQty,
              );

              finalCartItems.add(item);
              
              // Cộng dồn tổng tiền
              tempTotalMoney += price * localQty;
            }
          }

          // Trả về kết quả đúng với CartResponse model
          return CartResponse(
            succeeded: true, 
            data: finalCartItems,        // Sửa 'result' thành 'data'
            totalMoney: tempTotalMoney.toDouble() // Thêm 'totalMoney'
          );
        }
      }
    } catch (e) {
      print("Lỗi khi lấy thông tin chi tiết cho giỏ hàng Local: $e");
    }

    return CartResponse(succeeded: true, data: [], totalMoney: 0);
  }

  // --- 2. LOGIC GỘP ---
  static Future<void> _mergeLocalCartToServer(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartJson = prefs.getString('local_cart');

    if (cartJson != null) {
      List<dynamic> localList = jsonDecode(cartJson);
      if (localList.isNotEmpty) {
        for (var item in localList) {
          // Gửi đúng key product_variant_id lên server
          await http.post(
            Uri.parse('$baseUrl/cart/merge'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              //"ngrok-skip-browser-warning": "true",
            },
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
  // SỬA 1: Thêm tham số 'quantity' vào đây
  static Future<void> addToCart(int productVariantId, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('user_token');

    // 1. TRƯỜNG HỢP ĐÃ ĐĂNG NHẬP (GỌI API)
    if (token != null) {
      try {
        print("DEBUG: Đang thêm vào giỏ hàng Server với số lượng: $quantity");
        final response = await http.post(
          Uri.parse('$baseUrl/cart/add'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            "ngrok-skip-browser-warning": "true",
          },
          body: jsonEncode({
            'variant_id': productVariantId,
            'quantity': quantity, // SỬA 2: Gửi số lượng người dùng chọn lên server
          }),
        );
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          print("DEBUG: Thêm vào server thành công $productVariantId sl: $quantity");
        } else {
          print("DEBUG: Lỗi server ${response.body}");
        }
      } catch (e) {
        print("Lỗi thêm vào giỏ hàng (API): $e");
      }
    } 
    // 2. TRƯỜNG HỢP CHƯA ĐĂNG NHẬP (LƯU LOCAL)
    else {
      try {
        print("DEBUG: Đang xử lý giỏ hàng Local...");
        List<dynamic> currentList = [];
        String? localCartJson = prefs.getString('local_cart');
        
        // Decode JSON cũ nếu có
        if (localCartJson != null && localCartJson.isNotEmpty) {
          try {
            currentList = jsonDecode(localCartJson);
          } catch (e) {
            print("Lỗi decode JSON cũ, sẽ reset giỏ hàng: $e");
            currentList = [];
          }
        }

        bool exists = false;
        
        // Duyệt qua danh sách để tìm sản phẩm trùng
        for (var i = 0; i < currentList.length; i++) {
          // Ép kiểu về Map để truy cập an toàn
          Map<String, dynamic> item = currentList[i];

          if (item['product_variant_id'] == productVariantId) {
            // SỬA LỖI ĐƠ: Kiểm tra null trước khi cộng
            int currentQty = item['quantity'] ?? 0;
            
            // SỬA 3: Cộng dồn số lượng người dùng chọn (thay vì +1)
            item['quantity'] = currentQty + quantity; 
            
            // Cập nhật lại vào list
            currentList[i] = item;
            exists = true;
            print("DEBUG: Đã cộng dồn số lượng lên ${item['quantity']}");
            break; // Tìm thấy rồi thì thoát vòng lặp ngay
          }
        }

        // Nếu chưa tồn tại thì thêm mới
        if (!exists) {
          currentList.add({
            'product_variant_id': productVariantId,
            // SỬA 4: Gán số lượng ban đầu bằng số lượng người dùng chọn (thay vì 1)
            'quantity': quantity, 
            // Có thể thêm ngày tạo nếu cần để sort
            'added_at': DateTime.now().toIso8601String(), 
          });
          print("DEBUG: Đã thêm mới sản phẩm vào local với sl: $quantity");
        }

        // Lưu ngược lại vào SharedPreferences
        await prefs.setString('local_cart', jsonEncode(currentList));
        print("DEBUG: Lưu local thành công");

      } catch (e) {
        print("Lỗi nghiêm trọng khi lưu Local Cart: $e");
        // Không throw lỗi để tránh crash UI
      }
    }
  }
}