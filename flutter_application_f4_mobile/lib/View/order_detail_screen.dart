import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../resources/app_colors.dart';
import '../../Controller/order_controller.dart';
import '../../Model/Order.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId; // Nhận ID đơn hàng
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
    // Gọi API lấy chi tiết
    _orderDetailFuture = _orderController.getOrderDetail(widget.orderId);
  }

  // Định dạng tiền tệ
  String formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  // Định dạng ngày đặt
  String formatDate(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(dateString));
    } catch (e) { return dateString; }
  }

  // Dịch trạng thái sang tiếng Việt
  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return "Chờ xử lý";
      case 'processing': return "Đang chuẩn bị hàng";
      case 'shipping': return "Đang giao hàng";
      case 'delivered': return "Giao hàng thành công";
      case 'cancelled': return "Đã hủy";
      default: return status;
    }
  }

  // Lấy màu sắc theo trạng thái
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'shipping': return Colors.blue;
      default: return AppColors.primaryOrange;
    }
  }

  // --- WIDGET CON: HIỂN THỊ DÒNG THÔNG TIN ---
  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Thông tin đơn hàng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            return const Center(child: Text("Không tìm thấy đơn hàng"));
          }

          final order = snapshot.data!;
          final items = order.items ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // --- CARD 1: THÔNG TIN CHUNG ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      _buildInfoRow("Mã đơn hàng", "#${order.id}", isBold: true),
                      const Divider(height: 20, thickness: 0.5),
                      _buildInfoRow(
                        "Trạng thái", 
                        _translateStatus(order.status), 
                        valueColor: _getStatusColor(order.status),
                        isBold: true
                      ),
                      if (order.createdAt.isNotEmpty) 
                        _buildInfoRow("Ngày đặt: ",formatDate(order.createdAt)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- CARD 2: ĐỊA CHỈ NHẬN HÀNG ---
                if (order.fullName != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Địa chỉ nhận hàng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text("${order.fullName} | ${order.phoneNumber ?? ''}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(order.address ?? "Không có địa chỉ", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // --- CARD 3: DANH SÁCH SẢN PHẨM ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Tiêu đề
                      const Text("Sản phẩm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(height: 24, thickness: 0.5),
                      
                      // 2. Danh sách item
                      ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            // Ảnh sản phẩm
                            Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            
                            // Tên & Số lượng
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName, 
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                    maxLines: 2, 
                                    overflow: TextOverflow.ellipsis
                                  ),
                                  const SizedBox(height: 4),
                                  Text("x${item.quantity}", style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            
                            // Giá tiền
                            Text(formatCurrency(item.price), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),

                // --- CARD 4: TỔNG THANH TOÁN ---
                Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                   child: Column(
                     children: [
                       _buildInfoRow("Tổng tiền", formatCurrency(
                          items.fold(0, (sum, item) => sum + (item.price * item.quantity))
                       )),
                       _buildInfoRow("Phí vận chuyển", formatCurrency(order.shippingFee)),
                       const Divider(height: 24),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           const Text("Tổng thanh toán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                           Text(
                             formatCurrency(order.totalPrice > 0 ? order.totalPrice : items.fold(0, (sum, item) => sum + (item.price * item.quantity)) + order.shippingFee),
                             style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 18),
                           ),
                         ],
                       ),
                     ],
                   ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}