import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../resources/app_colors.dart';
import '../../Controller/order_controller.dart';
import '../../Model/Order.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId; // Nhận ID từ màn hình danh sách
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  // --- 1. KHAI BÁO BIẾN ---
  final OrderController _orderController = OrderController();
  late Future<Order?> _orderDetailFuture;

  // --- 2. KHỞI TẠO ---
  @override
  void initState() {
    super.initState();
    _orderDetailFuture = _orderController.getOrderDetail(widget.orderId); // Gọi API lấy chi tiết đơn hàng theo ID
  }

  // --- 3. HÀM HỖ TRỢ ---
  String formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  // Widget con để hiển thị 1 dòng thông tin
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

  // --- 4. GIAO DIỆN ---
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
      
      // FutureBuilder: Quản lý trạng thái tải dữ liệu
      body: FutureBuilder<Order?>(
        future: _orderDetailFuture,
        builder: (context, snapshot) {
          // Trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Trạng thái không có dữ liệu hoặc lỗi
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Không tìm thấy thông tin đơn hàng"));
          }

          // Trạng thái thành công -> Hiển thị dữ liệu
          final order = snapshot.data!;
          final items = order.items ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // --- KHỐI 1: THÔNG TIN CHUNG ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      _buildInfoRow("Mã đơn hàng", "#${order.id}"),
                      const SizedBox(height: 10),
                      _buildInfoRow("Trạng thái", order.status, isStatus: true),
                      // TODO: Có thể thêm ngày đặt hàng ở đây nếu API trả về
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- KHỐI 2: DANH SÁCH SẢN PHẨM ---
                const Text("Sản phẩm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                
                // Duyệt qua từng sản phẩm để hiển thị
                ...items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      // ⚠️ QUAN TRỌNG: Hiện tại API chưa trả về ảnh sản phẩm trong chi tiết đơn
                      // TODO: Thay thế bằng NetworkImage(item.image) khi Backend cập nhật
                      Container(
                        width: 50, height: 50,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.shopping_bag, color: Colors.grey),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Tên và số lượng
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
                      
                      // Giá tiền
                      Text(formatCurrency(item.price), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
                
                const SizedBox(height: 16),
                
                // --- KHỐI 3: TỔNG THANH TOÁN ---
                Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text("Tổng thanh toán", style: TextStyle(fontWeight: FontWeight.bold)),
                       
                       // ⚠️ LOGIC DỰ PHÒNG: 
                       // Một số API chi tiết đơn hàng bị thiếu trường 'total_price' ở cấp root.
                       // Nếu totalPrice = 0, ta tự động tính tổng bằng cách cộng dồn các item.
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
}