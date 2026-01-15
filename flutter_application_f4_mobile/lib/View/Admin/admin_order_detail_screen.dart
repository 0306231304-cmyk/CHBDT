import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../resources/app_colors.dart';
import '../../Model/Order.dart';
import '../../Controller/order_controller.dart';
import '../../Controller/product_controller.dart';
import '../Widget/order_widgets.dart';
import 'package:flutter_application_f4_mobile/Controller/couponController.dart';
import 'package:flutter_application_f4_mobile/Model/couponModel.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final Order order;
  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final OrderController _orderController = OrderController();
  
  // Future để quản lý trạng thái tải dữ liệu đơn hàng
  late Future<Order?> _orderFuture;
  
  // Danh sách biến thể sản phẩm dùng để tra cứu tên và ảnh
  List<dynamic> _allVariants = [];

  @override
  void initState() {
    super.initState();
    // Gọi API lấy chi tiết đơn hàng ngay khi màn hình mở
    _orderFuture = _orderController.getOrderDetail(widget.order.id);
    
    // Tải danh sách sản phẩm chạy ngầm
    _loadProducts();
  }

  // Hàm tải danh sách sản phẩm từ server
  void _loadProducts() async {
    try {
      final list = await ProductController.getAllProductVariants();
      if (mounted) {
        setState(() {
          _allVariants = list;
        });
      }
    } catch (e) {
      print("Lỗi tải danh sách sản phẩm: $e");
    }
  }

  // --- 1. CÁC HÀM HỖ TRỢ ---

  // Định dạng số tiền sang VNĐ
  String formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  // Định dạng ngày tháng
  String formatDate(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  // Cấu hình màu sắc và chữ hiển thị cho trạng thái đơn hàng
  Map<String, dynamic> getStatusConfig(String status) {
    switch (status.toLowerCase().trim()) {
      case 'delivered': 
        return {'text': "Đã giao thành công", 'color': Colors.green};
      case 'cancelled': 
        return {'text': "Đã hủy", 'color': Colors.red};
      case 'shipping': 
        return {'text': "Đang giao", 'color': Colors.orange};
      case 'pending': 
        return {'text': "Chờ xử lý", 'color': Colors.blue};
      case 'processing': 
        return {'text': "Đang chuẩn bị", 'color': Colors.deepPurple};
      default: 
        return {'text': status, 'color': Colors.grey};
    }
  }

  // Tìm tên, ảnh và thuộc tính chi tiết của sản phẩm dựa vào ID
  Map<String, String?> _getProductInfo(int id, String defaultName) {
    String name = defaultName;
    String? img;
    String? variantsInfo;

    if (_allVariants.isNotEmpty) {
      for (var v in _allVariants) {
        final variant = v as dynamic; 
        
        if (variant.id.toString() == id.toString()) {
          name = variant.name ?? name;
          img = variant.imageUrl;
          List<String> details = [];
          if (variant.color != null && variant.color!.isNotEmpty) {
            details.add(variant.color!);
          }
          if (variant.storage != null && variant.storage!.isNotEmpty) {
            details.add(variant.storage!);
          }
          
          if (details.isNotEmpty) {
            variantsInfo = details.join(" - ");
          }
          break;
        }
      }
    }
    return {'name': name, 'img': img, 'variant': variantsInfo};
  }

  // Xử lý khi bấm nút cập nhật trạng thái (duyệt đơn/hủy đơn)
  void _updateStatus(String status) async {
    await _orderController.updateOrderStatus(widget.order.id, status);
    
    if (!mounted) return;
    
    final statusText = getStatusConfig(status)['text'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đã cập nhật: $statusText"))
    );

    // Tải lại dữ liệu trang để hiển thị trạng thái mới
    setState(() {
      _orderFuture = _orderController.getOrderDetail(widget.order.id);
    });
  }

  // --- 2. GIAO DIỆN ---
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Order?>(
      future: _orderFuture,
      builder: (context, snapshot) {
        // Hiển thị vòng xoay khi đang tải dữ liệu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: _buildAppBar(), 
            body: const Center(child: CircularProgressIndicator())
          );
        }
        
        final order = snapshot.data ?? widget.order;
        final items = order.items ?? [];
        
        // Tính tổng tiền hàng
        int total = items.fold(0, (sum, i) => sum + (i.price * i.quantity));
        if (total == 0) total = order.totalPrice - order.shippingFee;

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: _buildAppBar(),
          
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Thẻ 1: Thông tin khách hàng và ngày đặt
                OrderCardSection(
                  children: [
                    OrderCustomerInfoRow(
                      fullName: order.fullName ?? "Khách lẻ",
                      phoneNumber: order.phoneNumber ?? "",
                    ),
                    const Divider(height: 24),
                    OrderIconTextRow(
                      icon: Icons.location_on_outlined, 
                      text: order.address ?? "Chưa có địa chỉ"
                    ),
                    const SizedBox(height: 8),
                    OrderIconTextRow(
                      icon: Icons.access_time, 
                      text: formatDate(order.createdAt)
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Thẻ 2: Danh sách sản phẩm trong đơn
                OrderCardSection(
                  children: [
                    Text("Sản phẩm (${items.length})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(height: 24),
                    
                    if (items.isEmpty) 
                      const Center(child: Text("Không có sản phẩm")),
                    
                    ...items.map((i) => _buildProductItem(i)),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Thẻ 3: Thông tin thanh toán và trạng thái đơn
                OrderCardSection(
                  children: [
                    OrderInfoRow(
                      label: "Tạm tính", 
                      value: formatCurrency(total)
                    ),
                    OrderInfoRow(
                      label: "Phí ship", 
                      value: formatCurrency(order.shippingFee)
                    ),
                    const Divider(height: 24),
                    
                    OrderInfoRow(
                      label: "Tổng cộng", 
                      value: formatCurrency(order.totalPrice),
                      isBold: true,
                      valueColor: AppColors.primaryOrange,
                    ),
                    
                    const SizedBox(height: 16),
                    _buildStatusBadge(order.status),
                  ],
                ),
                
                const SizedBox(height: 80), // Khoảng trống cho BottomBar
              ],
            ),
          ),
          
          // Thanh công cụ dưới cùng (Hủy/Duyệt đơn)
          bottomNavigationBar: _buildBottomBar(order.status),
        );
      },
    );
  }

  // --- 3. CÁC WIDGET CON ---

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("Đơn hàng #${widget.order.id}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      backgroundColor: AppColors.primaryOrange,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white), 
        onPressed: () => Navigator.pop(context, true) // Trả về true để reload trang danh sách
      ),
    );
  }

  // Widget hiển thị từng sản phẩm trong danh sách
  Widget _buildProductItem(OrderItem item) {
    final info = _getProductInfo(item.productId, item.productName);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh sản phẩm
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.hardEdge,
            child: (info['img'] != null && info['img']!.isNotEmpty)
                ? Image.network(info['img']!, fit: BoxFit.cover)
                : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          
          // Thông tin chi tiết
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên sản phẩm
                Text(
                  info['name']!,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis
                ),
                
                // Màu sắc & Dung lượng
                if (info['variant'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        info['variant']!,
                        style: TextStyle(color: Colors.blue.shade800, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                const SizedBox(height: 4),

                // Số lượng
                Text("Số lượng: ${item.quantity}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          
          // Giá tiền
          Text(
            formatCurrency(item.price),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
          ),
        ],
      ),
    );
  }

  // Nhãn hiển thị trạng thái đơn hàng
  Widget _buildStatusBadge(String status) {
    final config = getStatusConfig(status);
    return Container(
      width: double.infinity, 
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: config['color'].withOpacity(0.1), 
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: config['color'].withOpacity(0.3))
      ),
      alignment: Alignment.center,
      child: Text(
        config['text'].toUpperCase(), 
        style: TextStyle(color: config['color'], fontWeight: FontWeight.bold)
      ),
    );
  }

  // Thanh thao tác dưới cùng (chỉ hiện khi đơn chưa hoàn thành/hủy)
  Widget? _buildBottomBar(String rawStatus) {
    String status = rawStatus.toLowerCase().trim();
    
    // Ẩn nút nếu đơn hàng đã hoàn tất hoặc đã hủy
    if (['delivered', 'cancelled'].contains(status)) return null;
    
    return Container(
      padding: const EdgeInsets.all(16), 
      decoration: const BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
      ),
      child: Row(
        children: [
          // Nút hủy đơn
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateStatus('cancelled'), 
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red), 
                padding: const EdgeInsets.symmetric(vertical: 14)
              ), 
              child: const Text("Hủy đơn", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
            )
          ),
          const SizedBox(width: 16),
          
          // Nút cập nhật trạng thái tiếp theo
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (status == 'pending') {
                  _updateStatus('shipping');
                } else if (status == 'shipping') {
                  _updateStatus('delivered');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange, 
                padding: const EdgeInsets.symmetric(vertical: 14)
              ),
              child: Text(
                status == 'pending' ? "Xác nhận đơn" : "Đã giao hàng", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            )
          ),
        ]
      ),
    );
  }
}