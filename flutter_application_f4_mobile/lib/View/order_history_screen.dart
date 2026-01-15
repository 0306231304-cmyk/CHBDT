import 'package:flutter/material.dart';
import 'package:flutter_application_f4_mobile/Model/cartModel.dart';
import 'package:flutter_application_f4_mobile/Model/product_model.dart';
import 'package:flutter_application_f4_mobile/View/checkout_screen.dart';
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
  List<ProductVariant?> _allVariants = [];
  List<CartItem> orderDetail = [];

  // Các tab bộ lọc trạng thái
  final List<String> _filters = ["Tất cả", "Chờ xác nhận", "Đang giao", "Đã giao thành công", "Đã hủy"];
  String _selectedFilter = "Tất cả";

  String _sortType = 'newest';
  bool isLoadingButtonCancel = false;
  bool isLoadingOrderAgain = false;
  
  // Future để quản lý trạng thái tải dữ liệu đơn hàng
  late Future<Order?> _orderDetailFuture;


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

  String formatDate(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            tooltip: "Sắp xếp đơn hàng",
            onSelected: (value) {
              setState(() {
                _sortType = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'newest',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text("Mới nhất trước"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'oldest',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Text("Cũ nhất trước"),
                  ],
                ),
              ),
            ],
          ),
        ],
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

                displayedOrders.sort((a, b) {
                  // Parse chuỗi ngày tháng sang DateTime để so sánh
                  DateTime? dateA = DateTime.tryParse(a.createdAt);
                  DateTime? dateB = DateTime.tryParse(b.createdAt);

                  // Xử lý trường hợp ngày lỗi (cho về năm 1970)
                  dateA ??= DateTime(1970);
                  dateB ??= DateTime(1970);

                  if (_sortType == 'newest') {
                    return dateB.compareTo(dateA); // Giảm dần (Mới nhất lên đầu)
                  } else {
                    return dateA.compareTo(dateB); // Tăng dần (Cũ nhất lên đầu)
                  }
                });

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Ngày tạo đơn: ${formatDate(order.createdAt)}"),
                  ],
                ),
              ),
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
            ],
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
                        onPressed: isLoadingButtonCancel
                            ? null
                            : () async {
                                setState(() {
                                  isLoadingButtonCancel = true;
                                });

                                bool succeeded = await OrderController().cancelOrder(order.id);

                                if (!mounted) return;

                                if (succeeded) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Hủy đơn hàng thành công"),
                                      backgroundColor: Colors.greenAccent,
                                    ),
                                  );

                                  // --- THÊM DÒNG NÀY ĐỂ LOAD LẠI DỮ LIỆU ---
                                  setState(() {
                                    // 1. Tắt loading của nút
                                    isLoadingButtonCancel = false;
                                    
                                    // 2. Gọi lại API để FutureBuilder tự động build lại danh sách mới
                                    _ordersFuture = _orderController.getOrderHistory(); 
                                  });
                                  // ------------------------------------------
                                  
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Hủy đơn thất bại"),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  setState(() {
                                    isLoadingButtonCancel = false;
                                  });
                                }
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
                        // 1. Kiểm tra danh sách sản phẩm
                        if (order.items == null || order.items!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Không tìm thấy thông tin sản phẩm")),
                          );
                          return;
                        }

                        List<CartItem> buyAgainList = [];

                        for (var orderItem in order.items!) {
                          ProductVariant? variant;
                          
                          // 2. Tìm biến thể an toàn hơn (tránh lỗi nếu _allVariants có phần tử null)
                          try {
                            if (_allVariants.isNotEmpty) {
                              // Lọc bỏ các phần tử null trước khi tìm
                              final safeList = _allVariants.whereType<ProductVariant>().toList();
                              
                              variant = safeList.firstWhere(
                                (v) => v.id == orderItem.productId,
                                // Nếu không tìm thấy thì trả về null (thay vì crash app)
                                orElse: () => ProductVariant(id: 0, price: 0) // Dummy object để check null sau
                              );
                              
                              // Nếu là dummy object (id=0) thì gán lại null
                              if (variant.id == 0) variant = null;
                            }
                          } catch (e) {
                            variant = null;
                          }

                          buyAgainList.add(CartItem(
                            productVariantId: orderItem.productId,
                            productName: variant?.name ?? orderItem.productName,
                            quantity: orderItem.quantity,
                            // Giá: Nếu variant null hoặc giá null -> lấy giá cũ. Ép kiểu an toàn.
                            price: (variant?.price ?? orderItem.price).toDouble(),
                            imageUrl: variant?.imageUrl ?? "",
                            color: variant?.color ?? "",
                            ram: variant?.ram ?? "",
                            storage: variant?.storage ?? "",
                          ));
                        }

                        // 3. [SỬA LỖI CHÍNH Ở ĐÂY]
                        // Thay vì dùng "item.price!" (gây lỗi nếu null), hãy dùng "item.price ?? 0"
                        double totalMoney = buyAgainList.fold(0, (sum, item) {
                          double price = item.price ?? 0;
                          int qty = item.quantity ?? 0;
                          return sum + (price * qty);
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                              cartItems: buyAgainList,
                              totalMoney: totalMoney,
                              is_buy_now: true,
                            ),
                          ),
                        );
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