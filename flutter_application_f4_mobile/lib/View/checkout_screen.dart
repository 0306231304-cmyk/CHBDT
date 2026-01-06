import 'package:flutter/material.dart';
import '../../Resources/app_colors.dart';
import 'Widget/custom_button.dart';
import 'thanhtoanok_screen.dart';
import '../Model/order_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Khởi tạo OrderModel (Đảm bảo file order_model.dart đã bỏ 'final' cho các trường này)
  late OrderModel myOrder;
  bool _isEWallet = false;
  bool _isCOD = false;

  @override
  void initState() {
    super.initState();
    myOrder = OrderModel(
      receiverName: "Liêm",
      phoneNumber: "0366146741",
      address: "No 46, Awolowo Road....",
      items: [
        OrderItem(
          id: "ip17",
          name: "Điện thoại IPhone 17 256GB",
          variant: "Màu tím oải hương",
          price: 27740000,
          quantity: 1,
          image: "assets/images/anh9.png",
        ),
      ],
      totalAmount: 27740000,
      note: "Giao hàng giờ hành chính",
    );
  }

  // --- HÀM ĐỊNH DẠNG GIÁ TIỀN ---
  String _formatPrice(int price) {
    return "${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ";
  }

  // --- HÀM HIỂN THỊ BẢNG NHẬP LIỆU (BOTTOM SHEET) ---
  void _showEditSheet({
    required String title,
    required List<TextEditingController> controllers,
    required List<String> labels,
    required VoidCallback onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            ...List.generate(controllers.length, (index) => TextField(
              controller: controllers[index],
              decoration: InputDecoration(labelText: labels[index]),
            )),
            const SizedBox(height: 20),
            CustomButton(
              text: "Lưu",
              onPressed: () {
                onSave();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Biến kiểm tra điều kiện để bật/tắt nút thanh toán
    bool canPay = _isEWallet || _isCOD;

    return Scaffold(
      backgroundColor: AppColors.backgroundOrange,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Thông tin người nhận
                      _buildSectionTitle("Thông tin người nhận"),
                      _buildInfoTile(
                        title: "Người nhận: ${myOrder.receiverName}",
                        subtitle: "SĐT: ${myOrder.phoneNumber}",
                        onEdit: () {
                          TextEditingController nameCtrl = TextEditingController(text: myOrder.receiverName);
                          TextEditingController phoneCtrl = TextEditingController(text: myOrder.phoneNumber);
                          _showEditSheet(
                            title: "Sửa thông tin",
                            controllers: [nameCtrl, phoneCtrl],
                            labels: ["Tên người nhận", "Số điện thoại"],
                            onSave: () => setState(() {
                              myOrder.receiverName = nameCtrl.text;
                              myOrder.phoneNumber = phoneCtrl.text;
                            }),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // 2. Địa chỉ
                      _buildInfoTile(
                        title: "Địa chỉ",
                        subtitle: myOrder.address,
                        icon: Icons.location_on,
                        onEdit: () {
                          TextEditingController addrCtrl = TextEditingController(text: myOrder.address);
                          _showEditSheet(
                            title: "Sửa địa chỉ",
                            controllers: [addrCtrl],
                            labels: ["Địa chỉ mới"],
                            onSave: () => setState(() => myOrder.address = addrCtrl.text),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // 3. Sản phẩm
                      _buildProductItem(myOrder.items[0]),
                      const SizedBox(height: 16),

                      // Ghi chú
                      InkWell(
                        onTap: () {
                          TextEditingController noteCtrl = TextEditingController(text: myOrder.note);
                          _showEditSheet(
                            title: "Ghi chú đơn hàng",
                            controllers: [noteCtrl],
                            labels: ["Nhập ghi chú"],
                            onSave: () => setState(() => myOrder.note = noteCtrl.text),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Ghi chú: ${myOrder.note ?? ""}", style: const TextStyle(color: Colors.grey)),
                            const SizedBox(width: 4),
                            const Icon(Icons.assignment_outlined, size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 4. Phương thức thanh toán
                      const Text("Phương thức thanh toán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      _buildCheckboxTile("Ví điện tử", _isEWallet, (val) {
                        setState(() {
                          _isEWallet = val!;
                          if (_isEWallet) _isCOD = false;
                        });
                      }),
                      _buildCheckboxTile("Thanh toán khi nhận hàng (COD)", _isCOD, (val) {
                        setState(() {
                          _isCOD = val!;
                          if (_isCOD) _isEWallet = false;
                        });
                      }),
                      const SizedBox(height: 30),

                      // 5. Tổng tiền
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tổng tiền", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(_formatPrice(myOrder.totalAmount), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 6. Nút Thanh toán (Đã sửa lỗi Argument Type)
                      CustomButton(
                        text: "Thanh toán",
                        onPressed: () {
                          if (canPay) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ThanhToanOkScreen()));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Vui lòng chọn phương thức thanh toán!")),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS PHỤ ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
          ),
          const Text("Thông tin đơn hàng", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
  }

  Widget _buildInfoTile({required String title, required String subtitle, IconData? icon, required VoidCallback onEdit}) {
    return InkWell(
      onTap: onEdit,
      child: Row(
        children: [
          if (icon != null) ...[
            CircleAvatar(radius: 18, backgroundColor: const Color(0xFFF0F2F5), child: Icon(icon, color: Colors.black, size: 18)),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.edit, size: 20, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF5F6F8), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(item.image, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.phone_iphone, size: 40)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                if (item.variant != null) Text(item.variant!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Align(alignment: Alignment.centerRight, child: Text(_formatPrice(item.price), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(String title, bool value, Function(bool?) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(value: value, onChanged: onChanged, activeColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}