import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Widget/custom_button.dart';
import 'thanhtoanok_screen.dart';
import '../Model/cartModel.dart';
import '../Controller/create_order_controller.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalMoney;
  final bool is_buy_now;

  const CheckoutScreen({
    super.key, 
    required this.cartItems, 
    required this.totalMoney,
    required this.is_buy_now
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CreateOrderController _orderController = CreateOrderController();

  // Dữ liệu người dùng
  String receiverName = "Người dùng"; 
  String phoneNumber = "";
  String address = "Chưa nhập địa chỉ";
  String city = "TP. Hồ Chí Minh"; // Mặc định
  String note = "";

  // Trạng thái thanh toán
  bool _isEWallet = false;
  bool _isCOD = false;
  bool _isLoading = false;

  // Logic Mã giảm giá
  String _couponCode = "";
  double _discountAmount = 0;

  // --- DANH SÁCH TỈNH THÀNH (Bạn có thể thêm đủ 63 tỉnh) ---
  final List<String> _provinces = [
    "Hà Nội", "TP.HCM", "Đà Nẵng", "Hải Phòng", "Cần Thơ",
    "An Giang", "Bà Rịa - Vũng Tàu", "Bắc Giang", "Bắc Kạn", "Bạc Liêu",
    "Bắc Ninh", "Bến Tre", "Bình Định", "Bình Dương", "Bình Phước",
    "Bình Thuận", "Cà Mau", "Cao Bằng", "Đắk Lắk", "Đắk Nông",
    "Điện Biên", "Đồng Nai", "Đồng Tháp", "Gia Lai", "Hà Giang",
    "Hà Nam", "Hà Tĩnh", "Hải Dương", "Hậu Giang", "Hòa Bình",
    "Hưng Yên", "Khánh Hòa", "Kiên Giang", "Kon Tum", "Lai Châu",
    "Lâm Đồng", "Lạng Sơn", "Lào Cai", "Long An", "Nam Định",
    "Nghệ An", "Ninh Bình", "Ninh Thuận", "Phú Thọ", "Quảng Bình",
    "Quảng Nam", "Quảng Ngãi", "Quảng Ninh", "Quảng Trị", "Sóc Trăng",
    "Sơn La", "Tây Ninh", "Thái Bình", "Thái Nguyên", "Thanh Hóa",
    "Thừa Thiên Huế", "Tiền Giang", "Trà Vinh", "Tuyên Quang", "Vĩnh Long",
    "Vĩnh Phúc", "Yên Bái"
  ];

  @override
  void initState() {
    super.initState();
    // Sort tên tỉnh theo bảng chữ cái cho dễ tìm
    _provinces.sort((a, b) => a.compareTo(b));
    _loadSavedInfo();
  }

  Future<void> _loadSavedInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.containsKey('saved_name')) receiverName = prefs.getString('saved_name')!;
      if (prefs.containsKey('saved_phone')) phoneNumber = prefs.getString('saved_phone')!;
      if (prefs.containsKey('saved_address')) address = prefs.getString('saved_address')!;
      
      // Load thành phố, nếu không có trong danh sách thì lấy mặc định
      String savedCity = prefs.getString('saved_city') ?? "TP.HCM";
      if (_provinces.contains(savedCity)) {
        city = savedCity;
      }
    });
  }

  Future<void> _saveInfo(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
  // Popup Mã giảm giá
  void _onApplyCoupon() {
    TextEditingController couponController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nhập mã giảm giá"),
        content: TextField(
          controller: couponController,
          decoration: const InputDecoration(hintText: "VD: SALE50", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              String code = couponController.text.trim().toUpperCase();
              if (code == "SALE50") {
                setState(() { _couponCode = "SALE50"; _discountAmount = 50000; });
                _showNotify("Áp dụng SALE50 thành công");
              } else if (code == "FREESHIP") {
                 setState(() { _couponCode = "FREESHIP"; _discountAmount = 30000; });
                _showNotify("Áp dụng FREESHIP thành công");
              } else {
                _showNotify("Mã không hợp lệ!");
                return;
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Áp dụng", style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  // Popup Sửa thông tin chung
  void _showEditSheet({required String title, required List<Widget> fields, required VoidCallback onSave}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
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
    double finalPrice = widget.totalMoney - _discountAmount;
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
                      _buildSectionHeader("Thông tin nhận hàng"),
                      const SizedBox(height: 10),
                      
                      // 1. Tên & SĐT
                      _buildClickableRow(
                        icon: Icons.person_outline,
                        title: "$receiverName | $phoneNumber",
                        subTitle: "Bấm để sửa liên hệ",
                        onTap: () {
                          TextEditingController n = TextEditingController(text: receiverName);
                          TextEditingController p = TextEditingController(text: phoneNumber);
                          _showEditSheet(title: "Sửa liên hệ", fields: [
                            TextField(controller: n, decoration: const InputDecoration(labelText: "Họ tên", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
                            const SizedBox(height: 15),
                            TextField(controller: p, decoration: const InputDecoration(labelText: "Số điện thoại", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
                          ], onSave: () {
                            setState(() { receiverName = n.text; phoneNumber = p.text; });
                            _saveInfo('saved_name', n.text);
                            _saveInfo('saved_phone', p.text);
                          });
                        }
                      ),
                      const SizedBox(height: 10),

                      // 2. Địa chỉ & Chọn Thành phố (Dropdown)
                      _buildClickableRow(
                        icon: Icons.location_on_outlined,
                        title: "$address, $city",
                        subTitle: "Bấm để nhập địa chỉ",
                        isHighLight: address == "Chưa nhập địa chỉ",
                        onTap: () {
                          TextEditingController a = TextEditingController(text: address == "Chưa nhập địa chỉ" ? "" : address);
                          
                          // Biến tạm để lưu thành phố đang chọn trong popup
                          String tempSelectedCity = city; 

                          // Mở popup
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                            builder: (BuildContext context) {
                              return StatefulBuilder( // Dùng StatefulBuilder để update dropdown ngay trong popup
                                builder: (context, setStatePopup) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text("Địa chỉ giao hàng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                          const SizedBox(height: 20),
                                          
                                          // --- DROPDOWN CHỌN TỈNH THÀNH ---
                                          DropdownButtonFormField<String>(
                                            value: tempSelectedCity,
                                            decoration: const InputDecoration(
                                              labelText: "Tỉnh / Thành phố",
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons.location_city),
                                            ),
                                            isExpanded: true, // Để text dài không bị lỗi
                                            menuMaxHeight: 300, // Chiều cao danh sách xổ xuống
                                            items: _provinces.map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (newValue) {
                                              setStatePopup(() { // Update giao diện trong popup
                                                tempSelectedCity = newValue!;
                                              });
                                            },
                                          ),
                                          // ---------------------------------
                                          
                                          const SizedBox(height: 15),
                                          TextField(
                                            controller: a, 
                                            decoration: const InputDecoration(labelText: "Số nhà, Đường, Phường...", border: OutlineInputBorder()), 
                                            maxLines: 2
                                          ),
                                          const SizedBox(height: 20),
                                          
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.all(16)),
                                              onPressed: () { 
                                                // Lưu lại
                                                if(a.text.isNotEmpty) {
                                                  setState(() { 
                                                    address = a.text; 
                                                    city = tempSelectedCity; // Cập nhật city chính thức
                                                  });
                                                  _saveInfo('saved_address', a.text);
                                                  _saveInfo('saved_city', tempSelectedCity);
                                                }
                                                Navigator.pop(context); 
                                              }, 
                                              child: const Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              );
                            }
                          );
                        }
                      ),

                      const SizedBox(height: 25),

                      // 3. Sản phẩm
                      _buildSectionHeader("Sản phẩm"),
                      const SizedBox(height: 10),
                      ...widget.cartItems.map((item) => _buildProductCard(item)),

                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Ghi chú...",
                          prefixIcon: const Icon(Icons.note_alt_outlined),
                          filled: true, fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)
                        ),
                        onChanged: (val) => note = val,
                      ),

                      const SizedBox(height: 20),

                      // 4. Mã giảm giá
                      InkWell(
                        onTap: _onApplyCoupon,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(border: Border.all(color: Colors.orange.shade200), borderRadius: BorderRadius.circular(10), color: Colors.orange.shade50),
                          child: Row(
                            children: [
                              const Icon(Icons.confirmation_number_outlined, color: Colors.orange),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _couponCode.isEmpty ? "Chọn mã giảm giá" : "Mã: $_couponCode (-${_formatPrice(_discountAmount)})",
                                  style: TextStyle(color: _couponCode.isEmpty ? Colors.black54 : Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),
                      
                      // 5. Thanh toán
                      _buildSectionHeader("Thanh toán"),
                      _buildPaymentOption("COD (Tiền mặt)", _isCOD, (val) => setState(() { _isCOD = val!; if(val) _isEWallet = false; })),
                      _buildPaymentOption("Ví điện tử / Chuyển khoản", _isEWallet, (val) => setState(() { _isEWallet = val!; if(val) _isCOD = false; })),

                      const SizedBox(height: 30),

                      // 6. Tổng tiền
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tổng thanh toán", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_formatPrice(finalPrice), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      CustomButton(
                        text: _isLoading ? "ĐANG XỬ LÝ..." : "ĐẶT HÀNG", 
                        onPressed: _isLoading ? () {} : () async {
                           if (address == "Chưa nhập địa chỉ" || address.isEmpty) { _showNotify("Vui lòng nhập địa chỉ!"); return; }
                           if (!_isCOD && !_isEWallet) { _showNotify("Vui lòng chọn phương thức thanh toán!"); return; }
                           
                           setState(() => _isLoading = true);
                           
                           if(city != 'TP.HCM' && city != 'Hà Nội' && city != 'Đà Nẵng'){
                            city = 'Khác';
                           }

                           bool success = await _orderController.createOrder(
                              fullName: receiverName, 
                              phone: phoneNumber, 
                              address: address, 
                              city: city, // Gửi thành phố đã chọn
                              couponCode: _couponCode,
                              note: note,
                              totalPrice: finalPrice, 
                              isBuyNow: widget.is_buy_now,
                              paymentMethod: _isCOD ? "COD" : "E_WALLET", 
                              cartItems: widget.cartItems
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

  Widget _buildSectionHeader(String title) => Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));

  Widget _buildClickableRow({required IconData icon, required String title, required String subTitle, required VoidCallback onTap, bool isHighLight = false}) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(12),
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
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isHighLight ? Colors.orange[800] : Colors.black87)),
              Text(subTitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ])),
            const Icon(Icons.edit, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, bool value, Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(border: Border.all(color: value ? Colors.orange : Colors.grey.shade200), borderRadius: BorderRadius.circular(10), color: value ? Colors.orange.withOpacity(0.05) : null),
      child: CheckboxListTile(title: Text(title, style: TextStyle(fontSize: 14, fontWeight: value ? FontWeight.bold : FontWeight.normal)), value: value, activeColor: Colors.orange, contentPadding: const EdgeInsets.symmetric(horizontal: 8), onChanged: onChanged),
    );
  }

  Widget _buildProductCard(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.imageUrl ?? "", width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(width: 60, height: 60, color: Colors.grey[200]))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.productName ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)), Text("${item.quantity} x ${_formatPrice(item.price ?? 0)}", style: const TextStyle(color: Colors.grey, fontSize: 13))])),
        Text(_formatPrice((item.price ?? 0) * (item.quantity ?? 1)), style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }
}