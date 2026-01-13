import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../resources/app_colors.dart';
import '../../Controller/order_controller.dart';
import '../../Controller/product_controller.dart';
import '../../Model/Order.dart';
import '../../Model/product_model.dart';
import 'admin_order_detail_screen.dart';
import '../login_screen.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  final OrderController _orderController = OrderController();
  late Future<List<Order>> _ordersFuture;
  
  final List<String> _tabs = ["All", "Chờ xử lý", "Chờ lấy hàng", "Lịch sử"];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = _orderController.getAllOrdersAdmin();
    });
  }

  String formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Quản trị đơn hàng",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryOrange,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.white),
            onPressed: () {
               Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // --- TAB BAR ---
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 16), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_tabs.length, (index) {
                  bool isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.deepOrange : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
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
                  return const Center(child: Text("Không có đơn hàng nào"));
                }

                List<Order> allOrders = snapshot.data!;
                List<Order> filteredOrders = [];

                if (_selectedIndex == 0) {
                  filteredOrders = allOrders;
                } else if (_selectedIndex == 1) {
                  filteredOrders = allOrders.where((o) => o.status == 'pending').toList();
                } else if (_selectedIndex == 2) {
                  filteredOrders = allOrders.where((o) => o.status == 'processing' || o.status == 'shipping').toList();
                } else {
                  filteredOrders = allOrders.where((o) => o.status == 'delivered' || o.status == 'cancelled').toList();
                }

                if (filteredOrders.isEmpty) {
                   return const Center(child: Text("Không có đơn hàng trong mục này"));
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(filteredOrders[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    String displayStatus;
    Color badgeColor;
    Color badgeTextColor;

    // ... (Giữ nguyên phần switch case xử lý trạng thái như cũ) ...
    switch (order.status) {
      case 'pending':
        displayStatus = "Chờ xử lý";
        badgeColor = const Color(0xFFE3F2FD);
        badgeTextColor = Colors.blue;
        break;
      case 'processing':
        displayStatus = "Đang chuẩn bị";
        badgeColor = const Color(0xFFEEE5FF);
        badgeTextColor = Colors.deepPurple;
        break;
      case 'shipping':
        displayStatus = "Đang giao";
        badgeColor = const Color(0xFFFFF3E0);
        badgeTextColor = Colors.orange;
        break;
      case 'delivered':
      case 'completed':
        displayStatus = "Thành công";
        badgeColor = const Color(0xFFE8F5E9);
        badgeTextColor = Colors.green;
        break;
      case 'cancelled':
        displayStatus = "Đã hủy";
        badgeColor = const Color(0xFFFFEBEE);
        badgeTextColor = Colors.red;
        break;
      default:
        displayStatus = order.status;
        badgeColor = Colors.grey.shade200;
        badgeTextColor = Colors.black;
    }

    // --- TÍNH TỔNG SỐ LƯỢNG SẢN PHẨM ---
    int totalQuantity = 0;
    if (order.items != null) {
      for (var item in order.items!) {
        totalQuantity += item.quantity;
      }
    }

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminOrderDetailScreen(order: order),
          ),
        );
        if (result == true) {
          _loadOrders(); 
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            // Row 1: ID & Trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("#${order.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
                  child: Text(displayStatus, style: TextStyle(color: badgeTextColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 12),
            
            // Row 2: Khách hàng
            _buildInfoRow("Khách hàng", order.fullName ?? "Khách lẻ", isBold: true),
            
            // Row 3: Sản phẩm
            if (order.items != null && order.items!.isNotEmpty) ...[
              const Divider(height: 12),
              FutureBuilder<Product?>(
                future: ProductController.getProductById(order.items![0].productId),
                builder: (context, snapshot) {
                  String productText = "Đang tải...";
                  if (snapshot.hasData && snapshot.data != null) {
                    productText = snapshot.data!.name;
                    if (order.items!.length > 1) {
                      productText += " (+${order.items!.length - 1} SP khác)";
                    }
                  } else if (snapshot.hasError) {
                    productText = "Sản phẩm #${order.items![0].productId}";
                  }
                  return _buildInfoRow("Sản phẩm", productText, isBold: false);
                },
              ),
            ] else ...[
               const Divider(height: 12),
               FutureBuilder<Order?>(
                 // Gọi API lấy chi tiết đơn hàng để có danh sách items
                 future: _orderController.getOrderDetail(order.id), 
                 builder: (context, snapshot) {
                   String content = "Đang tải...";
                   
                   if (snapshot.connectionState == ConnectionState.done) {
                     if (snapshot.hasData && snapshot.data != null) {
                       // Có dữ liệu -> Tính tổng số lượng
                       int realQty = 0;
                       final items = snapshot.data!.items ?? [];
                       for (var item in items) {
                         realQty += item.quantity;
                       }
                       content = "$realQty sản phẩm";
                     } else {
                       content = "Xem chi tiết";
                     }
                   }
                   
                   return _buildInfoRow("Sản phẩm", content);
                 },
               ),
            ],

            const Divider(height: 12),
            
            // Row 4: Tổng tiền
            _buildInfoRow("Tổng tiền", formatCurrency(order.totalPrice), color: Colors.orange, isBold: true),
            
            const Divider(height: 12),
            
            // Row 5: Ngày đặt
            _buildInfoRow("Ngày đặt", formatDate(order.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color color = Colors.black87, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        // Sử dụng Expanded và TextOverflow để tên sản phẩm dài không bị vỡ giao diện
        Expanded(
          child: Text(
            value, 
            textAlign: TextAlign.end,
            style: TextStyle(
              color: color, 
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}