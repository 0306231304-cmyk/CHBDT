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
  final OrderController _orderController = OrderController();
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderController.getOrderHistory();
  }

  // Hàm format tiền tệ
  String formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  // Hàm map trạng thái tiếng Anh sang tiếng Việt và màu sắc
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
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Bạn chưa có đơn hàng nào"));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final statusInfo = getStatusInfo(order.status);

              return GestureDetector(
                onTap: () {
                  // Chuyển sang trang chi tiết, truyền ID đơn hàng
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(orderId: order.id),
                    ),
                  );
                },
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