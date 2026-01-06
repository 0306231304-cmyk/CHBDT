class OrderItem {
  final String id;
  final String name;
  final String? variant;
  final int price;
  int quantity; // Cho phép sửa để tăng giảm số lượng
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
}

// 2. Model chính cho Đơn hàng
class OrderModel {
  // BỎ 'final' ở 4 dòng này để có thể cập nhật dữ liệu khi bấm nút Sửa
  String receiverName; 
  String phoneNumber;  
  String address;      
  String? note;        

  final List<OrderItem> items;
  bool isTransferData;
  bool isExportInvoice;
  bool isOtherRequest;
  String? promoCode;
  int totalAmount;

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