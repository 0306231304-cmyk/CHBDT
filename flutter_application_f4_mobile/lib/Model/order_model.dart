class OrderItem {
  final String id;
  final String name;
  final String? variant;
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
}

class OrderModel {
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