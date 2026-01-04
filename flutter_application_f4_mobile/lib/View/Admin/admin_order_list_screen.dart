import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import 'admin_order_detail_screen.dart';
import '../login_screen.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  // 1. Danh sách Tabs trạng thái
  final List<String> _tabs = ["All", "Chờ xử lý", "Chờ lấy hàng", "Lịch sử"];
  int _selectedIndex = 0;

  // 2. Dữ liệu giả (Dummy Data)
  final List<Map<String, dynamic>> _allOrders = [
    {
      "id": "#CM9801",
      "customer": "Natali Craig",
      "products": ["iPhone 13 x2", "iPhone 17 x1"],
      "total": "47.740.000đ",
      "date": "25/12/2025",
      "status": "Chờ lấy hàng",
    },
    {
      "id": "#CM9802",
      "customer": "Drew Cano",
      "products": ["iPhone Air x1"],
      "total": "27.740.000đ",
      "date": "23/12/2025",
      "status": "Chờ xử lý",
    },
    {
      "id": "#CM9803",
      "customer": "Kate Morrison",
      "products": ["iPhone 13 x2"],
      "total": "47.740.000đ",
      "date": "22/12/2025",
      "status": "Thành công",
    },
    {
      "id": "#CM9804",
      "customer": "Andi Lane",
      "products": ["iPhone 17 x1"],
      "total": "27.740.000đ",
      "date": "20/12/2025",
      "status": "Đã hủy",
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredOrders = _selectedIndex == 0
    ? _allOrders // Tab All
    : _selectedIndex == 3 // Tab Lịch sử (index = 3)
        ? _allOrders.where((o) => o['status'] == "Thành công" || o['status'] == "Đã hủy").toList()
        : _allOrders.where((o) => o['status'] == _tabs[_selectedIndex]).toList(); // Các tab còn lại khớp tên
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // --- PHẦN HEADER ---
          Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            color: AppColors.backgroundOrange,
            child: Column(
              children: [
                // Dòng Tiêu đề + Nút tắt nguồn
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    const Text(
                      "Danh sách đơn hàng",
                      style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.power_settings_new, color: Colors.black),
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
                const SizedBox(height: 16),
                
                // Thanh tìm kiếm
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tab Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...List.generate(_tabs.length, (index) {
                        bool isSelected = _selectedIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.deepOrange : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _tabs[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- PHẦN DANH SÁCH ĐƠN HÀNG ---
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(child: Text("Không có đơn hàng nào", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(filteredOrders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget con: Thẻ đơn hàng
  Widget _buildOrderCard(Map<String, dynamic> order) {
    // Xử lý màu sắc Badge trạng thái
    Color badgeColor;
    Color badgeTextColor;
    String status = order['status'];

    switch (status) {
      case "Chờ lấy hàng":
        badgeColor = const Color(0xFFEEE5FF); // Tím nhạt
        badgeTextColor = Colors.purple;
        break;
      case "Chờ xử lý":
        badgeColor = const Color(0xFFE3F2FD); // Xanh dương nhạt
        badgeTextColor = Colors.blue;
        break;
      case "Thành công":
        badgeColor = const Color(0xFFE8F5E9); // Xanh lá nhạt
        badgeTextColor = Colors.green;
        break;
      default: // Đã hủy
        badgeColor = const Color(0xFFFFEBEE); // Đỏ nhạt
        badgeTextColor = Colors.red;
    }

    return GestureDetector(
      // Sự kiện: Bấm vào thẻ để chuyển sang trang Chi tiết
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminOrderDetailScreen(orderData: order),
          ),
        );
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
            // Dòng 1: Mã đơn + Badge trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: badgeTextColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 12),

            // Các dòng thông tin chi tiết
            _buildInfoRow("Khách hàng", order['customer'], isBold: true),
            const Divider(height: 12),
            
            // Hiển thị danh sách sản phẩm (xuống dòng nếu nhiều món)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sản phẩm", style: TextStyle(color: Colors.grey)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: (order['products'] as List<String>).map((prod) => 
                    Text(prod, style: const TextStyle(fontWeight: FontWeight.w500))
                  ).toList(),
                )
              ],
            ),
            const Divider(height: 12),

            _buildInfoRow("Tổng tiền", order['total'], color: Colors.orange, isBold: true),
            const Divider(height: 12),
            _buildInfoRow("Thời gian đặt", order['date']),
          ],
        ),
      ),
    );
  }

  // Helper vẽ 1 dòng: Label ----- Value
  Widget _buildInfoRow(String label, String value, {Color color = Colors.black87, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}