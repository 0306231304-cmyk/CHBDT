import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final List<String> _tabs = ["Tất cả", "Chờ xác nhận", "Đã hoàn thành", "Đã hủy"];
  int _selectedIndex = 0;

  // --- 1. DỮ LIỆU GIẢ ---
  final List<Map<String, dynamic>> _allOrders = [
    {
      "id": "#OD001",
      "status": "Đã hoàn thành",
      "total": "35.000.000đ",
      "items": [
        {
          "name": "iPhone 13",
          "price": "10.000.000đ",
          "qty": 1,
        },
        {
          "name": "MacBook Air M1",
          "price": "25.000.000đ",
          "qty": 1,
        }
      ]
    },
    {
      "id": "#OD002",
      "status": "Chờ xác nhận",
      "total": "40.500.000đ",
      "items": [
        {
          "name": "iPhone 15 Pro Max",
          "price": "30.000.000đ",
          "qty": 1,
        },
        {
          "name": "Ốp lưng MagSafe",
          "price": "10.500.000đ",
          "qty": 1,
        }
      ]
    },
    {
      "id": "#OD003",
      "status": "Đã hủy",
      "total": "25.000.000đ",
      "items": [
        {
          "name": "Samsung S24 Ultra",
          "price": "25.000.000đ",
          "qty": 1,
        }
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredOrders = _selectedIndex == 0
        ? _allOrders
        : _allOrders.where((order) => order['status'] == _tabs[_selectedIndex]).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: const [
              Icon(Icons.search, color: Colors.grey),
              SizedBox(width: 8),
              Text("Search", style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
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
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 8),
                  ...List.generate(_tabs.length, (index) {
                    bool isSelected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryOrange : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black54,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          // --- DANH SÁCH ĐƠN HÀNG ---
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(child: Text("Không có đơn hàng nào"))
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

  // Widget hiển thị thẻ đơn hàng (Xử lý vòng lặp items)
  Widget _buildOrderCard(Map<String, dynamic> order) {
    Color statusColor;
    String status = order['status'];
    List<dynamic> items = order['items']; // Lấy danh sách sản phẩm

    switch (status) {
      case "Đã hoàn thành": statusColor = Colors.green; break;
      case "Chờ xác nhận": statusColor = Colors.blue; break;
      case "Đã hủy": statusColor = Colors.red; break;
      default: statusColor = AppColors.primaryOrange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 1. Trạng thái
          Text(
            status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Divider(),

          // 2. VÒNG LẶP HIỂN THỊ CÁC SẢN PHẨM TRONG ĐƠN
          ...items.map((item) {
            return Column(
              children: [
                _buildSingleProductRow(item),
                // Nếu không phải món cuối cùng thì thêm đường kẻ mờ
                if (item != items.last) 
                  Divider(color: Colors.grey.shade100, height: 20),
              ],
            );
          }).toList(),

          const SizedBox(height: 10),

          // 3. Tổng tiền
          RichText(
            text: TextSpan(
              text: "Tổng số tiền: ",
              style: const TextStyle(color: Colors.black54),
              children: [
                TextSpan(
                  text: order['total'],
                  style: const TextStyle(color: AppColors.primaryOrange, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. Nút bấm
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (status == "Chờ xác nhận") ...[
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Hủy", style: TextStyle(color: Colors.red)),
                ),
              ],
              if (status == "Đã hoàn thành") ...[
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Xem đánh giá", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text("Mua lại", style: TextStyle(color: Colors.white)),
                ),
              ],
              if (status == "Đã hủy") ...[
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text("Mua lại", style: TextStyle(color: Colors.white)),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }

  // Hàm tách riêng để vẽ 1 dòng sản phẩm cho gọn
  Widget _buildSingleProductRow(Map<String, dynamic> item) {
    return Row(
      children: [
        // Ảnh
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.phone_iphone, size: 40, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        // Thông tin
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("x${item['qty']}", style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Text(item['price'], style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}