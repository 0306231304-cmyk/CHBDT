import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../resources/app_colors.dart';
import '../../Controller/order_controller.dart';
import '../../Model/Order.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  // --- 1. KHAI BÁO BIẾN ---
  final OrderController _orderController = OrderController();
  late Future<List<Order>> _ordersFuture; // Biến chứa dữ liệu Order bất đồng bộ

  // --- 2. KHỞI TẠO ---
  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderController.getOrderHistory(); // Gọi API lấy danh sách đơn hàng
  }

  // --- 3. HÀM HỖ TRỢ ---

  // Hàm định dạng tiền tệ (VD: 100000 -> 100.000đ)
  String formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  // Hàm chuyển đổi trạng thái đơn hàng (Anh -> Việt) và gán màu sắc tương ứng
  Map<String, dynamic> getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return {'text': 'Chờ xác nhận', 'color': Colors.orange};
      case 'shipping':
        return {'text': 'Đang giao', 'color': Colors.blue};
      case 'completed':
        return {'text': 'Đã hoàn thành', 'color': Colors.green};
      case 'cancelled':
        return {'text': 'Đã hủy', 'color': Colors.red};
      default:
        return {'text': status, 'color': Colors.grey};
    }
  }

  // --- 4. GIAO DIỆN ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Lịch sử đơn hàng", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryOrange,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      // FutureBuilder: Quản lý trạng thái tải dữ liệu
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          
          // Trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Trạng thái không có dữ liệu hoặc lỗi
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Bạn chưa có đơn hàng nào"));
          }

          // Trạng thái thành công -> Lấy danh sách đơn hàng
          final orders = snapshot.data!;
          
          // Hiển thị danh sách dạng cuộn
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final statusInfo = getStatusInfo(order.status);

              return GestureDetector(
                onTap: () {
                  // Chuyển sang màn hình chi tiết khi bấm vào đơn hàng
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(orderId: order.id),
                    ),
                  );
                },
                // Card hiển thị thông tin tóm tắt của đơn hàng
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Dòng 1: Mã đơn hàng + Trạng thái
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Đơn hàng #${order.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusInfo['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusInfo['text'],
                              style: TextStyle(color: statusInfo['color'], fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      
                      const Divider(height: 20),
                      
                      // Dòng 2: Ngày đặt + Tổng tiền
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order.createdAt, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            formatCurrency(order.totalPrice),
                            style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}