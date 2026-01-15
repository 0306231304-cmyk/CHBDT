import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../resources/app_colors.dart';
import '../../Controller/order_controller.dart';
import '../../Controller/product_controller.dart';
import '../../Model/Order.dart';
import 'Widget/order_widgets.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderController _orderController = OrderController();
  
  // Future để quản lý trạng thái tải dữ liệu đơn hàng
  late Future<Order?> _orderDetailFuture;
  
  // Danh sách biến thể sản phẩm dùng để tra cứu tên và ảnh
  List<dynamic> _allVariants = []; 

  @override
  void initState() {
    super.initState();
    // Gọi API lấy chi tiết đơn hàng ngay khi màn hình mở
    _orderDetailFuture = _orderController.getOrderDetail(widget.orderId);
    
    // Tải danh sách sản phẩm chạy ngầm
    _loadProductList();
  }

  // Hàm tải danh sách sản phẩm từ server
  void _loadProductList() async {
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
    switch (status.toLowerCase()) {
      case 'pending': 
        return {'text': "Chờ xử lý", 'color': Colors.blue};
      case 'processing': 
        return {'text': "Đang chuẩn bị", 'color': Colors.deepPurple};
      case 'shipping': 
        return {'text': "Đang giao", 'color': Colors.orange};
      case 'delivered': 
        return {'text': "Đã giao thành công", 'color': Colors.green};
      case 'cancelled': 
        return {'text': "Đã hủy", 'color': Colors.red};
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

  // --- 2. GIAO DIỆN ---
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

          // Tính tổng tiền hàng
          int productTotal = items.fold(0, (sum, item) => sum + (item.price * item.quantity));
          if (productTotal == 0) productTotal = order.totalPrice - order.shippingFee;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildOrderInfoCard(order),
                const SizedBox(height: 16),
                _buildAddressCard(order),
                const SizedBox(height: 16),
                _buildProductListCard(items),
                const SizedBox(height: 16),
                _buildPaymentCard(order, productTotal),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- 3. CÁC WIDGET CON ---

  // Hiển thị thông tin mã đơn, trạng thái, ngày đặt
  Widget _buildOrderInfoCard(Order order) {
    final statusConfig = getStatusConfig(order.status);
    
    return OrderCardSection(
      children: [
        OrderInfoRow(label: "Mã đơn hàng", value: "#${order.id}", isBold: true),
        const Divider(height: 24, thickness: 0.5),
        OrderInfoRow(
          label: "Trạng thái", 
          value: statusConfig['text'], 
          valueColor: statusConfig['color'],
          isBold: true
        ),
        if (order.createdAt.isNotEmpty) 
          OrderInfoRow(label: "Ngày đặt", value: formatDate(order.createdAt)),
      ],
    );
  }

  // Hiển thị địa chỉ nhận hàng
  Widget _buildAddressCard(Order order) {
    if (order.fullName == null) return const SizedBox.shrink();
    
    return OrderCardSection(
      children: [
        const Text("Địa chỉ nhận hàng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(
          "${order.fullName} | ${order.phoneNumber ?? ''}", 
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)
        ),
        const SizedBox(height: 4),
        Text(
          order.address ?? "Không có địa chỉ", 
          style: const TextStyle(color: Colors.grey)
        ),
      ],
    );
  }

  // Hiển thị danh sách sản phẩm
  Widget _buildProductListCard(List<OrderItem> items) {
    return OrderCardSection(
      children: [
        const Text("Sản phẩm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Divider(height: 24, thickness: 0.5),
        
        if (items.isEmpty) 
           const Center(child: Text("Đang tải hoặc không có sản phẩm", style: TextStyle(color: Colors.grey))),

        ...items.map((item) => _buildProductItem(item)).toList(),
      ],
    );
  }

  // Widget hiển thị từng sản phẩm trong danh sách
  Widget _buildProductItem(OrderItem item) {
    // Gọi hàm helper để lấy thông tin tên/ảnh thật
    final info = _getProductInfo(item.productId, item.productName);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Ảnh sản phẩm
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300), 
            ),
            clipBehavior: Clip.hardEdge,
            child: info['img'] != null 
                ? Image.network(info['img']!, fit: BoxFit.cover) 
                : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          
          // Tên sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(
                  info['name']!, 
                  style: const TextStyle(fontWeight: FontWeight.w600), 
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

                // Số lượng
                const SizedBox(height: 4),
                Text("Số lượng: ${item.quantity}", style: const TextStyle(color: Colors.grey)),
              ]
            )
          ),
          
          // Giá tiền sản phẩm
          Text(
            formatCurrency(item.price), 
            style: const TextStyle(fontWeight: FontWeight.bold)
          ),
        ]
      ),
    );
  }

  // Hiển thị thông tin thanh toán cuối cùng
  Widget _buildPaymentCard(Order order, int productTotal) {
    return OrderCardSection(
      children: [
        OrderInfoRow(label: "Tổng tiền", value: formatCurrency(productTotal)),
        OrderInfoRow(label: "Phí vận chuyển", value: formatCurrency(order.shippingFee)),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Tổng thanh toán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              formatCurrency(order.totalPrice),
              style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }
}