import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../resources/app_colors.dart';
import '../../Model/Order.dart';
import '../../Controller/order_controller.dart';
import '../../Controller/product_controller.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final Order order;
  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final OrderController _orderController = OrderController();
  late Future<Order?> _orderDetailFuture;

  @override
  void initState() {
    super.initState();
    // Gọi API lấy chi tiết đơn hàng (để có list items đầy đủ)
    _orderDetailFuture = _orderController.getOrderDetail(widget.order.id);
  }

  // Hàm hỗ trợ
  // Định dạng tiền tệ
  String formatCurrency(int amount) => 
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);

  // Định dạng ngày đặt
  String formatDate(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(dateString));
    } catch (e) { return dateString; }
  }

  // Dịch trạng thái sang tiếng Việt
  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return "Đã hoàn thành";
      case 'delivered': return "Giao hàng thành công";
      case 'cancelled': return "Đã hủy";
      case 'shipping': return "Đang giao hàng";
      case 'pending': return "Chờ xác nhận";
      case 'processing': return "Đang chuẩn bị";
      default: return status;
    }
  }

  // Lấy màu sắc theo trạng thái
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'shipping': return Colors.orange;
      case 'pending': return Colors.blue;
      case 'processing': return Colors.deepPurple;
      default: return Colors.grey;
    }
  }

  // Xử lý cập nhật trạng thái đơn hàng
  void _updateStatus(String newStatus) async {
    await _orderController.updateOrderStatus(widget.order.id, newStatus);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đã cập nhật: ${getStatusText(newStatus)}")),
    );
    // Reload lại dữ liệu sau khi update
    setState(() {
      _orderDetailFuture = _orderController.getOrderDetail(widget.order.id);
    });
  }

  //Giao diện
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Đơn hàng #${widget.order.id}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryOrange,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context, true), // Pop true để reload list bên ngoài
        ),
      ),
      
      body: FutureBuilder<Order?>(
        future: _orderDetailFuture,
        builder: (context, snapshot) {
          // Trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Lấy dữ liệu
          final order = snapshot.data ?? widget.order;
          final items = order.items ?? [];
          
          // Tính tổng tiền hàng
          int productTotal = items.fold(0, (sum, item) => sum + (item.price * item.quantity));
          if (productTotal == 0) productTotal = order.totalPrice - order.shippingFee;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCustomerInfo(order),
                const SizedBox(height: 16),
                _buildProductList(items),
                const SizedBox(height: 16),
                _buildPaymentInfo(order, productTotal),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      // Thanh thao tác dưới cùng (Chỉ hiện khi đơn chưa hoàn tất)
      bottomNavigationBar: _buildBottomActionBar(widget.order.status),
    );
  }

  //Các Widget con
  // Widget khung thẻ trắng bo góc
  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12)
      ),
      child: child,
    );
  }

  // Widget dòng thông tin: Label - Value
  Widget _buildInfoRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.black, 
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: 15
            ),
          ),
        ],
      ),
    );
  }

  // --- CARD 1: THÔNG TIN KHÁCH HÀNG ---
  Widget _buildCustomerInfo(Order order) {
    return _buildCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24, backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.fullName ?? "Khách lẻ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(order.phoneNumber ?? "Không có SĐT", style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(order.address ?? "Chưa cập nhật địa chỉ", style: const TextStyle(fontSize: 14))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text("Ngày đặt: ${formatDate(order.createdAt)}", style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  // --- CARD 2: DANH SÁCH SẢN PHẨM ---
  Widget _buildProductList(List<OrderItem> items) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Sản phẩm (${items.length})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 24),
          
          if (items.isEmpty) 
            const Center(child: Text("Đang tải hoặc không có sản phẩm", style: TextStyle(color: Colors.grey))),

          ...items.map((item) => _buildProductItem(item)).toList(),
        ],
      ),
    );
  }

  // Item con: Hiển thị từng sản phẩm
  Widget _buildProductItem(OrderItem item) {
    return FutureBuilder<dynamic>(
      future: ProductController.getProductById(item.productId),
      builder: (context, snapshot) {
        String name = item.productName;
        if (snapshot.hasData && snapshot.data != null) {
          name = (snapshot.data as dynamic).name;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100, 
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text("x${item.quantity}", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Text(formatCurrency(item.price), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  // --- CARD 3: THANH TOÁN & TRẠNG THÁI ---
  Widget _buildPaymentInfo(Order order, int productTotal) {
    return _buildCard(
      child: Column(
        children: [
          _buildInfoRow("Tạm tính", formatCurrency(productTotal)),
          _buildInfoRow("Phí vận chuyển", formatCurrency(order.shippingFee)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tổng thanh toán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(formatCurrency(order.totalPrice), style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          // Badge trạng thái
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: getStatusColor(order.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: getStatusColor(order.status).withOpacity(0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              getStatusText(order.status).toUpperCase(),
              style: TextStyle(color: getStatusColor(order.status), fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. ACTION BAR ---
  Widget? _buildBottomActionBar(String status) {
    // Ẩn nếu đơn đã hoàn tất/hủy
    if (['completed', 'delivered', 'cancelled'].contains(status)) return null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))]
      ),
      child: Row(
        children: [
          // Nút Hủy (Trái)
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateStatus('cancelled'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red), 
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Hủy đơn", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          // Nút Hành động chính (Phải)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (status == 'pending') _updateStatus('shipping');
                else if (status == 'shipping') _updateStatus('completed');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange, 
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                (status == 'pending') ? "Xác nhận đơn" : (status == 'shipping' ? "Đã giao hàng" : "Cập nhật"),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}