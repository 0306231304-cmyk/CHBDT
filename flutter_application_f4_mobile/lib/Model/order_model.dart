// 1. Model cho từng sản phẩm trong đơn hàng (Khớp với Order list trong Figma)
class OrderItem {
  final String id;
  final String name;
  final String? variant; // Ví dụ: Màu tím oải hương
  final int price;
  int quantity;
  final String image;
  int get totalPrice => price * quantity;

  OrderItem({
    required this.id,
    required this.name,
    this.variant,
    required this.price,
    required this.quantity,
    required this.image,
  });

  // Chuyển đổi dữ liệu từ Json nếu sau này bạn dùng API
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      variant: json['variant'],
      price: json['price'],
      quantity: json['quantity'],
      image: json['image'],
    );
  }
}

// 2. Model chính cho Đơn hàng (Khớp với màn hình Thông tin đơn hàng)
class OrderModel {
  // Thông tin người nhận
  final String receiverName; // Người nhận: Liêm
  final String phoneNumber;  // SĐT: 0366146741
  final String address;      // No 46, Awolowo Road....

  // Danh sách sản phẩm
  final List<OrderItem> items;

  // Các tùy chọn bổ sung (Yêu cầu đặt biệt)
  final String? note;           // Ghi chú
  final bool isTransferData;    // Chuyển dữ liệu
  final bool isExportInvoice;   // Xuất hóa đơn
  final bool isOtherRequest;    // Khác
  
  final String? promoCode;      // Mã giảm giá
  final int totalAmount;        // Tổng tiền

  OrderModel({
    required this.receiverName,
    required this.phoneNumber,
    required this.address,
    required this.items,
    this.note,
    this.isTransferData = false,
    this.isExportInvoice = false,
    this.isOtherRequest = false,
    this.promoCode,
    required this.totalAmount,
  });
}