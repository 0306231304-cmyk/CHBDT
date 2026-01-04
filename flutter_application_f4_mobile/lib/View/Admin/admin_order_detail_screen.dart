import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';

class AdminOrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const AdminOrderDetailScreen({Key? key, required this.orderData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy trạng thái đơn hàng
    String status = orderData['status'];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOrange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Đơn hàng ${orderData['id']}",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- 1. THÔNG TIN KHÁCH HÀNG ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar giả
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(orderData['customer'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            const Text("(454) 726-0592", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      // Nút Gọi
                      if (status != "Thành công" && status != "Đã hủy") ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text("Gọi", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        )
                      ]

                    ],
                  ),
                  const Divider(height: 24),
                  // Địa chỉ
                  Row(
                    children: const [
                      Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
                      SizedBox(width: 8),
                      Text("152 Lý Tự Trọng, Quận 1", style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 2. DANH SÁCH SẢN PHẨM ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  // Item 1
                  _buildProductItem("iPhone 13", "Màu đen", "10.000.000đ", "x2"),
                  const Divider(),
                  // Item 2
                  _buildProductItem("iPhone 17", "Màu tím", "27.740.000đ", "x1"),
                  const SizedBox(height: 16),

                  // Tổng kết tiền
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tổng số tiền:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(orderData['total'], style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Trạng thái (Text màu)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Trạng thái:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // --- 3. BOTTOM BAR (Nút bấm thay đổi theo trạng thái) ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: _buildActionButtons(status),
      ),
    );
  }

  // Helper tạo 1 dòng sản phẩm
  Widget _buildProductItem(String name, String color, String price, String qty) {
    return Row(
      children: [
        Container(
          width: 75, height: 75,
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.phone_iphone, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(color, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('blank', style: const TextStyle(color: Colors.white)),
            Text(qty, style: const TextStyle(color: Colors.grey)),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  // Helper lấy màu chữ dựa trên trạng thái
  Color _getStatusColor(String status) {
    if (status == "Chờ lấy hàng") return Colors.purple;
    if (status == "Chờ xử lý") return Colors.blue;
    if (status == "Thành công") return Colors.green;
    return Colors.red;
  }

  // Helper xử lý nút bấm theo trạng thái (Giống hình mẫu)
  Widget _buildActionButtons(String status) {
    // 1. Nếu là "Chờ lấy hàng" (Shipping) -> Nút Xanh "Hoàn tất đơn"
    if (status == "Chờ lấy hàng") {
      return ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8F5E9), // Nền xanh nhạt
          foregroundColor: Colors.green, // Chữ xanh
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text("Hoàn tất đơn", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );
    }

    // 2. Nếu là "Chờ xử lý" (Pending) -> 2 Nút: "Soạn hàng xong" & "Hủy đơn"
    if (status == "Chờ xử lý") {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEEE5FF), // Tím nhạt
                foregroundColor: Colors.deepPurple,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Soạn hàng xong", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEBEE), // Đỏ nhạt
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Hủy đơn", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    }

    // 3. Nếu là "Thành công" hoặc "Đã hủy" -> Chỉ hiện chữ to ở giữa
    return Text(
      status == "Thành công" ? "Đã hoàn thành" : "Đã hủy",
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 20, 
        fontWeight: FontWeight.bold, 
        color: Colors.grey
      ),
    );
  }
}