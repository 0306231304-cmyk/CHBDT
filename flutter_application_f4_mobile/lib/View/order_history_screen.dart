import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../resources/app_colors.dart';
import '../../Controller/order_controller.dart';
import '../../Controller/product_controller.dart';
import '../../Model/Order.dart';
import 'order_detail_screen.dart';
import 'Widget/order_widgets.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderController _orderController = OrderController();
  
  // Future chứa danh sách đơn hàng
  late Future<List<Order>> _ordersFuture;
  
  // Danh sách biến thể sản phẩm dùng để tra cứu tên và ảnh
  List<dynamic> _allVariants = [];

  // Các tab bộ lọc trạng thái
  final List<String> _filters = ["Tất cả", "Chờ xác nhận", "Đang giao", "Đã giao thành công", "Đã hủy"];
  String _selectedFilter = "Tất cả";

  @override
  void initState() {
    super.initState();
    // Gọi API lấy danh sách đơn hàng ngay khi màn hình mở
    _ordersFuture = _orderController.getOrderHistory();

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

    // Định dạng tiền tệ
  String formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  // Cấu hình màu sắc và chữ hiển thị cho trạng thái đơn hàng
  Map<String, dynamic> getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return {'text': 'Chờ xác nhận', 'color': Colors.blue};
      case 'processing':
        return {'text': 'Đang chuẩn bị', 'color': Colors.deepPurple};
      case 'shipping':
        return {'text': 'Đang giao', 'color': Colors.orange};
      case 'delivered':
        return {'text': 'Đã giao thành công', 'color': Colors.green};
      case 'cancelled':
        return {'text': 'Đã hủy', 'color': Colors.red};
      default:
        return {'text': status, 'color': Colors.grey};
    }
  }


  // --- 2. GIAO DIỆN ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Lịch sử đơn hàng",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
          // Thanh lọc trạng thái (Tab bar)
          _buildFilterBar(),
          
          // Danh sách đơn hàng
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                // Đang tải
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // Không có dữ liệu
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Bạn chưa có đơn hàng nào"));
                }

                final allOrders = snapshot.data!;
                List<Order> displayedOrders;

                // Lọc đơn hàng theo tab đang chọn
                if (_selectedFilter == "Tất cả") {
                  displayedOrders = allOrders;
                } else {
                  displayedOrders = allOrders.where((order) {
                    final config = getStatusConfig(order.status);
                    return config['text'] == _selectedFilter;
                  }).toList();
                }

                // Nếu tab hiện tại không có đơn nào
                if (displayedOrders.isEmpty) {
                  return Center(child: Text("Không có đơn hàng ở mục '$_selectedFilter'"));
                }

                // Hiển thị danh sách kết quả
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _ordersFuture = _orderController.getOrderHistory();
                    });
                    _loadProductList(); // Tải lại sản phẩm khi refresh
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: displayedOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(displayedOrders[index]);
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

  // --- 3. CÁC WIDGET CON ---

  // Widget thanh lọc trạng thái ngang
  Widget _buildFilterBar() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _filters.map((filter) {
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
          }).toList(),
        ),
      ),
    );
  }

  // Widget hiển thị 1 thẻ đơn hàng
  Widget _buildOrderCard(Order order) {
    final statusConfig = getStatusConfig(order.status);

    return OrderListCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
        );
      },
      child: Column(
        children: [
          // Header: Trạng thái
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  statusConfig['text'],
                  style: TextStyle(
                    color: statusConfig['color'],
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // Body: Danh sách sản phẩm
          Column(
            children: [
              // Logic hiển thị sản phẩm:
              // Nếu đã có items -> Hiển thị ngay
              if (order.items != null && order.items!.isNotEmpty)
                ...order.items!.map((item) => _buildProductItem(item)).toList()
              else
                // Nếu chưa có items -> Gọi API chi tiết (Lazy Loading)
                FutureBuilder<Order?>(
                  future: _orderController.getOrderDetail(order.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.items != null) {
                      return Column(
                        children: snapshot.data!.items!.map((item) => _buildProductItem(item)).toList(),
                      );
                    }
                    // Trạng thái chờ
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Đang tải thông tin sản phẩm...", style: TextStyle(color: Colors.grey)),
                    );
                  },
                ),
            ],
          ),

          // Footer: Tổng tiền và nút bấm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 12),
                
                // Tổng tiền
                OrderInfoRow(
                  label: "Tổng số tiền:", 
                  value: formatCurrency(order.totalPrice),
                  isBold: true,
                  valueColor: AppColors.primaryOrange,
                ),
                
                const SizedBox(height: 12),
                
                // Các nút hành động
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Nút Hủy (Chỉ hiện khi chưa xử lý)
                    if (order.status == 'pending')
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: OrderSmallButton(
                          text: "Hủy",
                          color: Colors.white,
                          textColor: Colors.black54,
                          isOutlined: true,
                          onPressed: () {
                            // TODO: Thêm logic hủy đơn ở đây
                          },
                        ),
                      ),
                    
                    // Nút Mua lại (Luôn hiện)
                    OrderSmallButton(
                      text: "Mua lại",
                      color: AppColors.primaryOrange,
                      textColor: Colors.white,
                      isOutlined: false,
                      onPressed: () {
                        // TODO: Thêm logic mua lại
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị thông tin 1 sản phẩm
  Widget _buildProductItem(OrderItem item) {
    String name = item.productName; // Tên mặc định
    String? imgUrl;

    // Tìm tên và ảnh trong cache
    if (_allVariants.isNotEmpty) {
      for (var variant in _allVariants) {
        final v = variant as dynamic;
        if (v.id.toString() == item.productId.toString()) {
          name = v.name ?? name;
          imgUrl = v.imageUrl;
          break; // Tìm thấy thì dừng vòng lặp
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh sản phẩm
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: (imgUrl != null && imgUrl.isNotEmpty)
                ? Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, color: Colors.grey),
                  )
                : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          
          // Tên và số lượng
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text("x${item.quantity}", style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          
          // Giá tiền
          Text(
            formatCurrency(item.price),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}