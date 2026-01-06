import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';

class OrderDetailScreen extends StatelessWidget {
  // Nhận toàn bộ object đơn hàng từ màn hình danh sách
  final Map<String, dynamic> orderData;

  const OrderDetailScreen({Key? key, required this.orderData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String status = orderData['status'];
    String total = orderData['total'];
    String id = orderData['id'];
    List<dynamic> items = orderData['items'];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Thông tin đơn hàng",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- TRẠNG THÁI & ĐỊA CHỈ ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  // Trạng thái đơn hàng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const Divider(height: 24),

                  // Thông tin người nhận
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.grey, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Địa chỉ nhận hàng", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text("152 Lý Tự Trọng, Quận 1, TP.HCM", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            Text("(098) 123-4567", style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- DANH SÁCH SẢN PHẨM ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Sản phẩm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  
                  ...items.map((item) {
                    return Column(
                      children: [
                        _buildProductItem(item),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),

                  const Divider(),
                  
                  // Tổng tiền
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tổng thanh toán", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
                      Text(total, style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // --- Nút bấm thay đổi theo trạng thái ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, -2))],
        ),
        child: SafeArea(child: _buildActionButtons(context, status)),
      ),
    );
  }


  // Widget hiển thị 1 dòng sản phẩm
  Widget _buildProductItem(Map<String, dynamic> item) {
    return Row(
      children: [
        // Ảnh sản phẩm
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.phone_iphone, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        // Tên và số lượng
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text("Số lượng: x${item['qty']}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        // Giá tiền
        Text(item['price'], style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  // Logic màu sắc trạng thái
  Color _getStatusColor(String status) {
    switch (status) {
      case "Đã hoàn thành": return Colors.green;
      case "Chờ xác nhận": return Colors.blue;
      case "Đã hủy": return Colors.red;
      default: return AppColors.primaryOrange;
    }
  }

  // 3. Logic nút bấm
  Widget _buildActionButtons(BuildContext context, String status) {
    // Trường hợp: Chờ xác nhận -> Cho phép Hủy
    if (status == "Chờ xác nhận") {
      return SizedBox(
        height: 50,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã gửi yêu cầu hủy đơn")));
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Hủy đơn hàng", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      );
    }

    // Trường hợp: Đã hoàn thành -> Mua lại & Đánh giá
    if (status == "Đã hoàn thành") {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Đánh giá", style: TextStyle(color: Colors.black)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Mua lại", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      );
    }

    // Trường hợp: Đã hủy -> Chỉ Mua lại
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("Mua lại", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}