import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Widget/custom_button.dart';
import 'thanhtoanok_screen.dart';
import '../Model/cartModel.dart';
import '../Controller/create_order_controller.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalMoney;

  const CheckoutScreen({
    super.key, 
    required this.cartItems, 
    required this.totalMoney
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CreateOrderController _orderController = CreateOrderController();

  // Dữ liệu người dùng
  String receiverName = "Liêm"; 
  String phoneNumber = "0366146741";
  String address = "Chưa có địa chỉ"; 
  String note = "";

  // Trạng thái
  bool _isEWallet = false;
  bool _isCOD = false;
  bool _isLoading = false;

  // Giảm giá
  String _appliedCode = "";
  int _discount = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedInfo();
  }

  // --- 1. HÀM LOAD & SAVE DỮ LIỆU TỰ ĐỘNG ---
  Future<void> _loadSavedInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.containsKey('saved_name')) receiverName = prefs.getString('saved_name')!;
      if (prefs.containsKey('saved_phone')) phoneNumber = prefs.getString('saved_phone')!;
      if (prefs.containsKey('saved_address')) address = prefs.getString('saved_address')!;
    });
  }

  Future<void> _saveInfo(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // --- 2. HÀM HIỆN POPUP SỬA (FIX LỖI BÀN PHÍM) ---
  void _showEditSheet({required String title, required List<Widget> fields, required VoidCallback onSave}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép full màn hình
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        // Đẩy nội dung lên khi bàn phím hiện
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 15),
              ...fields,
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.all(16)),
                  onPressed: () { onSave(); Navigator.pop(context); }, 
                  child: const Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(num price) => "${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ";
  void _showNotify(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    double finalPrice = widget.totalMoney - _discount;
    if (finalPrice < 0) finalPrice = 0;

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
                  const Expanded(child: Center(child: Text("Thanh toán", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
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
                      // --- PHẦN THÔNG TIN (SỬA ĐƯỢC) ---
                      _buildSectionHeader("Thông tin nhận hàng"),
                      const SizedBox(height: 10),
                      
                      // Dòng 1: Tên và SĐT
                      _buildClickableRow(
                        icon: Icons.person_outline,
                        title: "$receiverName | $phoneNumber",
                        subTitle: "Bấm để sửa thông tin liên hệ",
                        onTap: () {
                          TextEditingController n = TextEditingController(text: receiverName);
                          TextEditingController p = TextEditingController(text: phoneNumber);
                          _showEditSheet(title: "Sửa liên hệ", fields: [
                            TextField(controller: n, decoration: const InputDecoration(labelText: "Họ tên", border: OutlineInputBorder())),
                            const SizedBox(height: 10),
                            TextField(controller: p, decoration: const InputDecoration(labelText: "Số điện thoại", border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                          ], onSave: () {
                            setState(() { receiverName = n.text; phoneNumber = p.text; });
                            _saveInfo('saved_name', n.text);
                            _saveInfo('saved_phone', p.text);
                          });
                        }
                      ),
                      
                      const SizedBox(height: 10),

                      // Dòng 2: Địa chỉ
                      _buildClickableRow(
                        icon: Icons.location_on_outlined,
                        title: address,
                        subTitle: "Bấm để nhập địa chỉ giao hàng",
                        isHighLight: address == "Chưa có địa chỉ",
                        onTap: () {
                          TextEditingController a = TextEditingController(text: address == "Chưa có địa chỉ" ? "" : address);
                          _showEditSheet(title: "Nhập địa chỉ", fields: [
                            TextField(controller: a, decoration: const InputDecoration(labelText: "Số nhà, đường, phường/xã...", border: OutlineInputBorder()), maxLines: 3),
                          ], onSave: () {
                            if(a.text.isNotEmpty) {
                              setState(() => address = a.text);
                              _saveInfo('saved_address', a.text);
                            }
                          });
                        }
                      ),

                      const SizedBox(height: 25),

                      // --- DANH SÁCH SẢN PHẨM ---
                      _buildSectionHeader("Sản phẩm (${widget.cartItems.length})"),
                      const SizedBox(height: 10),
                      ...widget.cartItems.map((item) => _buildProductCard(item)),

                      // Ghi chú
                       const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Ghi chú cho Shop...",
                          prefixIcon: const Icon(Icons.note_alt_outlined),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)
                        ),
                        onChanged: (val) => note = val,
                      ),

                      const SizedBox(height: 25),
                      
                      // --- PHƯƠNG THỨC THANH TOÁN ---
                      _buildSectionHeader("Phương thức thanh toán"),
                      _buildPaymentOption("Thanh toán khi nhận hàng (COD)", _isCOD, (val) => setState(() { _isCOD = val!; if(val) _isEWallet = false; })),
                      _buildPaymentOption("Ví điện tử / Chuyển khoản", _isEWallet, (val) => setState(() { _isEWallet = val!; if(val) _isCOD = false; })),

                      const SizedBox(height: 30),

                      // --- TỔNG TIỀN & NÚT ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tổng thanh toán", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_formatPrice(finalPrice), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      CustomButton(
                        text: _isLoading ? "Đang xử lý..." : "ĐẶT HÀNG", 
                        onPressed: _isLoading ? () {} : () async {
                           if (address == "Chưa có địa chỉ" || address.isEmpty) { _showNotify("Vui lòng nhập địa chỉ!"); return; }
                           if (!_isCOD && !_isEWallet) { _showNotify("Vui lòng chọn phương thức thanh toán!"); return; }
                           
                           setState(() => _isLoading = true);
                           bool success = await _orderController.createOrder(
                              fullName: receiverName, phone: phoneNumber, address: address, note: note,
                              totalPrice: finalPrice, paymentMethod: _isCOD ? "COD" : "E_WALLET", cartItems: widget.cartItems
                           );
                           setState(() => _isLoading = false);

                           if (success) {
                             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ThanhToanOkScreen()));
                           } else {
                             _showNotify("Lỗi đặt hàng. Vui lòng thử lại!");
                           }
                        }
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

  // Widget hiển thị tiêu đề mục
  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  // Widget hiển thị dòng thông tin bấm được
  Widget _buildClickableRow({required IconData icon, required String title, required String subTitle, required VoidCallback onTap, bool isHighLight = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isHighLight ? Colors.orange.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isHighLight ? Colors.orange : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: isHighLight ? Colors.orange : Colors.grey[600], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isHighLight ? Colors.orange[800] : Colors.black87)),
                  Text(subTitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.edit, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Widget checkbox thanh toán
  Widget _buildPaymentOption(String title, bool value, Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: value ? Colors.orange : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
        color: value ? Colors.orange.withOpacity(0.05) : null
      ),
      child: CheckboxListTile(
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: value ? FontWeight.bold : FontWeight.normal)),
        value: value,
        activeColor: Colors.orange,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        onChanged: onChanged,
      ),
    );
  }

  // Widget hiển thị sản phẩm
  Widget _buildProductCard(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(item.imageUrl ?? "", width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(width: 60, height: 60, color: Colors.grey[200])),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.productName ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("${item.quantity} x ${_formatPrice(item.price ?? 0)}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ]),
          ),
          Text(_formatPrice((item.price ?? 0) * (item.quantity ?? 1)), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}