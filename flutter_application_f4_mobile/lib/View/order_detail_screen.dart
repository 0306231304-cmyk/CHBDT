import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../resources/app_colors.dart';
import '../../Controller/order_controller.dart';
import '../../Model/Order.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderController _orderController = OrderController();
  late Future<Order?> _orderDetailFuture;

  @override
  void initState() {
    super.initState();
    // Gọi API lấy chi tiết dựa trên ID truyền vào
    _orderDetailFuture = _orderController.getOrderDetail(widget.orderId);
  }

  // Hàm format tiền tệ
  String formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryOrange,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Order?>(
        future: _orderDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Không tìm thấy thông tin đơn hàng"));
          }

          final order = snapshot.data!;
          final items = order.items ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin chung
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      _buildInfoRow("Mã đơn hàng", "#${order.id}"),
                      const SizedBox(height: 10),
                      _buildInfoRow("Trạng thái", order.status, isStatus: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Danh sách sản phẩm
                const Text("Sản phẩm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                
                // Hiển thị list items
                ...items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      // Ảnh placeholder vì API chưa trả về ảnh
                      Container(
                        width: 50, height: 50,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.shopping_bag, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("x${item.quantity}", style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text(formatCurrency(item.price), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )).toList(),
                
                const SizedBox(height: 16),
                
                // Tổng cộng (API chi tiết không trả về tổng tiền ở root, nên ta có thể tự tính hoặc lấy từ item)
                // Tuy nhiên ở code Model mình đã xử lý hứng totalPrice từ JSON nếu có.
                // Nếu API chi tiết thiếu total_price, ta có thể cộng dồn items.
                Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text("Tổng thanh toán", style: TextStyle(fontWeight: FontWeight.bold)),
                       // Nếu totalPrice = 0 (do API chi tiết thiếu), ta tự tính
                       Text(
                         formatCurrency(order.totalPrice > 0 
                             ? order.totalPrice 
                             : items.fold(0, (sum, item) => sum + (item.price * item.quantity))),
                         style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 18),
                       ),
                     ],
                   ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget tạo ra một dòng hiển thị thông tin gồm: Tiêu đề (bên trái) và Giá trị (bên phải).
  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: isStatus ? AppColors.primaryOrange : Colors.black
          )
        ),
      ],
    );
  }
}