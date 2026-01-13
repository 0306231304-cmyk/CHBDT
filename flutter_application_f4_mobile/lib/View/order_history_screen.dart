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

  // Danh sách các tab trạng thái (Tiếng Việt)
  final List<String> _filters = ["Tất cả", "Chờ xác nhận", "Đang giao", "Đã hoàn thành", "Đã hủy"];
  String _selectedFilter = "Tất cả";

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderController.getOrderHistory();
  }

  // --- 1. HÀM XỬ LÝ TRẠNG THÁI (CORE LOGIC) ---
  Map<String, dynamic> getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return {'text': 'Chờ xác nhận', 'color': Colors.blue};
      case 'processing':
        return {'text': 'Đang chuẩn bị', 'color': Colors.deepPurple};
      case 'shipping':
        return {'text': 'Đang giao', 'color': Colors.orange};
      case 'delivered':
      case 'completed':
        return {'text': 'Đã hoàn thành', 'color': Colors.green};
      case 'cancelled':
        return {'text': 'Đã hủy', 'color': Colors.red};
      default:
        return {'text': status, 'color': Colors.grey};
    }
  }

  // --- 2. HÀM HỖ TRỢ KHÁC ---
  String formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  List<Order> filterOrders(List<Order> allOrders) {
    if (_selectedFilter == "Tất cả") return allOrders;
    
    return allOrders.where((order) {
      final statusVN = getStatusConfig(order.status)['text'];
      return statusVN == _selectedFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Lịch sử đơn hàng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryOrange,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- THANH TAB BỘ LỌC ---
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 16), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(_filters.length, (index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryOrange : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // --- DANH SÁCH ĐƠN HÀNG ---
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final displayedOrders = filterOrders(snapshot.data!);

                if (displayedOrders.isEmpty) {
                  return Center(child: Text("Không có đơn hàng ở mục '$_selectedFilter'"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: displayedOrders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(displayedOrders[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text("Bạn chưa có đơn hàng nào", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusConfig = getStatusConfig(order.status);
    final statusText = statusConfig['text'];
    final statusColor = statusConfig['color'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Trạng thái
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // Body: Sản phẩm
          InkWell(
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)));
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(4),
                      image: const DecorationImage(
                        image: NetworkImage("https://via.placeholder.com/150"), 
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "iPhone 13", 
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Màu đen", 
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "x2", 
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatCurrency(10000000), 
                    style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.status == 'pending' || order.status == 'processing')
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildActionButton(
                      text: "Hủy",
                      color: Colors.white,
                      textColor: Colors.black54,
                      isOutlined: true,
                      onPressed: () {},
                    ),
                  ),

                if (order.status == 'completed' || order.status == 'delivered')
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildActionButton(
                      text: "Xem đánh giá",
                      color: Colors.white,
                      textColor: Colors.black54,
                      isOutlined: true,
                      onPressed: () {},
                    ),
                  ),
                
                _buildActionButton(
                  text: "Mua lại",
                  color: AppColors.primaryOrange,
                  textColor: Colors.white,
                  isOutlined: false,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5),

          // Footer: Tổng tiền (Nằm DƯỚI buttons)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tổng số tiền:", style: TextStyle(color: Colors.black54, fontSize: 14)),
                Text(
                  formatCurrency(order.totalPrice),
                  style: TextStyle(
                    color: AppColors.primaryOrange, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 16
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text, 
    required Color color, 
    required Color textColor,
    required bool isOutlined, 
    required VoidCallback onPressed
  }) {
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: isOutlined ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}