import 'package:flutter/material.dart';
import '../../Resources/app_colors.dart';
import 'Widget/custom_button.dart';
import 'thanhtoanok_screen.dart';
import '../Model/order_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late OrderModel myOrder;
  bool _isEWallet = false;
  bool _isCOD = false;

  // Logic Mã giảm giá
  String _appliedCode = "";
  int _discount = 0;
  final int _promoLimit = 10;
  final int _promoUsed = 8; // Giả định đã dùng 8/10 suất

  @override
  void initState() {
    super.initState();
    myOrder = OrderModel(
      receiverName: "Liêm",
      phoneNumber: "0366146741",
      address: "No 46, Awolowo Road, Ikoyi, Lagos Island",
      note: "",
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
    );
  }

  String _formatPrice(int price) =>
      "${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ";

  // --- HÀM SỬA THÔNG TIN ---
  void _showEditSheet({required String title, required List<Widget> fields, required VoidCallback onSave}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ...fields,
            const SizedBox(height: 20),
            CustomButton(text: "Xác nhận", onPressed: () { onSave(); Navigator.pop(context); }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- LOGIC MÃ GIẢM GIÁ ---
  void _checkPromoCode(String code) {
    DateTime now = DateTime.now(); // Hiện tại là 06/01/2026
    if (code.trim().toUpperCase() == "GIAM500K") {
      if (now.year != 2026) {
        _showNotify("Mã chỉ hiệu lực trong năm 2026");
      } else if (_promoUsed >= _promoLimit) {
        _showNotify("Mã đã hết lượt dùng (Giới hạn 10 người)");
      } else {
        setState(() { _appliedCode = "GIAM500K"; _discount = 500000; });
        _showNotify("Áp dụng thành công! Giảm 500.000đ");
      }
    } else {
      _showNotify("Mã không hợp lệ");
    }
  }

  void _showNotify(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    int finalPrice = myOrder.totalAmount - _discount;

    return Scaffold(
      backgroundColor: const Color(0xFFFF8A00),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
                  const Expanded(child: Center(child: Text("Thông tin đơn hàng", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Người nhận
                      _buildInfoRow(
                        "Người nhận: ${myOrder.receiverName}\nSĐT: ${myOrder.phoneNumber}", 
                        null, Icons.edit, () {
                          TextEditingController n = TextEditingController(text: myOrder.receiverName);
                          TextEditingController p = TextEditingController(text: myOrder.phoneNumber);
                          _showEditSheet(title: "Sửa người nhận", fields: [
                            TextField(controller: n, decoration: const InputDecoration(labelText: "Tên")),
                            TextField(controller: p, decoration: const InputDecoration(labelText: "SĐT"), keyboardType: TextInputType.phone),
                          ], onSave: () => setState(() { myOrder.receiverName = n.text; myOrder.phoneNumber = p.text; }));
                        }
                      ),
                      const SizedBox(height: 20),
                      // Địa chỉ
                      _buildInfoRow(
                        "Địa chỉ", myOrder.address, Icons.edit, () {
                          TextEditingController a = TextEditingController(text: myOrder.address);
                          _showEditSheet(title: "Sửa địa chỉ", fields: [
                            TextField(controller: a, decoration: const InputDecoration(labelText: "Địa chỉ mới"), maxLines: 2),
                          ], onSave: () => setState(() => myOrder.address = a.text));
                        }, 
                        leadingIcon: Icons.location_on
                      ),
                      const SizedBox(height: 25),
                      // Sản phẩm
                      _buildProductCard(),
                      // Ghi chú (Đã sửa để hoạt động)
                      _buildNoteSection(),
                      // Mã giảm giá
                      _buildPromoSection(),
                      const SizedBox(height: 20),
                      const Text("Phương thức thanh toán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      _buildPayCheck("Ví điện tử", _isEWallet, (v) => setState(() { _isEWallet = v!; if(v) _isCOD = false; })),
                      _buildPayCheck("Thanh toán khi nhận hàng", _isCOD, (v) => setState(() { _isCOD = v!; if(v) _isEWallet = false; })),
                      const SizedBox(height: 40),
                      // Tổng tiền
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tổng tiền", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(_formatPrice(finalPrice).replaceAll('đ', ''), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 30),
                      CustomButton(text: "Thanh toán", onPressed: () {
                        if (_isEWallet || _isCOD) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ThanhToanOkScreen()));
                        } else {
                          _showNotify("Vui lòng chọn phương thức thanh toán!");
                        }
                      }),
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

  Widget _buildInfoRow(String title, String? sub, IconData icon, VoidCallback onTap, {IconData? leadingIcon}) {
    return Row(
      children: [
        if (leadingIcon != null) ...[
          CircleAvatar(radius: 18, backgroundColor: const Color(0xFFE3F2FD), child: Icon(leadingIcon, color: const Color(0xFF2196F3), size: 20)),
          const SizedBox(width: 12),
        ],
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          if (sub != null) Text(sub, style: const TextStyle(fontWeight: FontWeight.w500)),
        ])),
        IconButton(icon: Icon(icon, size: 20), onPressed: onTap),
      ],
    );
  }

  Widget _buildProductCard() {
    var item = myOrder.items[0];
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(15)),
      child: Row(children: [
        Image.asset(item.image, width: 70, height: 70),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Row(children: [Text(item.variant ?? ""), const Icon(Icons.keyboard_arrow_down)]),
          Align(alignment: Alignment.bottomRight, child: Text(_formatPrice(item.price), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        ])),
      ]),
    );
  }

  Widget _buildNoteSection() {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          TextEditingController n = TextEditingController(text: myOrder.note);
          _showEditSheet(title: "Ghi chú đơn hàng", fields: [
            TextField(controller: n, decoration: const InputDecoration(hintText: "Nhập lưu ý..."), maxLines: 2),
          ], onSave: () => setState(() => myOrder.note = n.text));
        },
        icon: const Icon(Icons.assignment_outlined, color: Colors.black),
        label: Text(myOrder.note!.isEmpty ? "Ghi chú:" : "Ghi chú: ${myOrder.note}", style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildPromoSection() {
    return InkWell(
      onTap: () {
        TextEditingController c = TextEditingController();
        showDialog(context: context, builder: (context) => AlertDialog(
          title: const Text("Nhập mã GIAM500K"),
          content: TextField(controller: c, decoration: const InputDecoration(hintText: "Mã giảm giá")),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")), TextButton(onPressed: () { _checkPromoCode(c.text); Navigator.pop(context); }, child: const Text("Áp dụng"))],
        ));
      },
      child: Row(children: [
        const Text("Sử dụng mã giảm giá", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 8),
        const Icon(Icons.copy_all, size: 20),
        const Spacer(),
        if (_appliedCode.isNotEmpty) Text(_appliedCode, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildPayCheck(String t, bool v, Function(bool?) on) {
    return Row(children: [Checkbox(value: v, onChanged: on, activeColor: Colors.orange), Text(t, style: const TextStyle(fontSize: 16))]);
  }
}