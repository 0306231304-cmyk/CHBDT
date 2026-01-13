import 'package:flutter/material.dart';

// Khung thẻ dùng cho danh sách đơn hàng (Order History / Admin List)
class OrderListCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const OrderListCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Khung thẻ dùng cho chi tiết đơn hàng (Order Detail)
class OrderCardSection extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const OrderCardSection({
    super.key,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// Dòng thông tin: Label (xám) - Value (đen/đậm)
class OrderInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;
  final bool alignTop; // Căn lề trên (dùng cho nội dung dài nhiều dòng)

  const OrderInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
    this.alignTop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: alignTop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? Colors.black,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dòng Icon + Text (dùng cho Địa chỉ, Ngày đặt)
class OrderIconTextRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const OrderIconTextRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}

// Header thông tin khách hàng (Avatar + Tên + SĐT)
class OrderCustomerInfoRow extends StatelessWidget {
  final String fullName;
  final String phoneNumber;

  const OrderCustomerInfoRow({
    super.key,
    required this.fullName,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
              ),
              if (phoneNumber.isNotEmpty)
                Text(phoneNumber, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }
}

// Nút bấm nhỏ (Dùng cho danh sách đơn hàng: Hủy, Mua lại, Xác nhận)
class OrderSmallButton extends StatelessWidget {
  final String text;
  final Color color; // Màu nền
  final Color textColor;
  final bool isOutlined; // True: Viền màu, False: Nền màu
  final VoidCallback onPressed;

  const OrderSmallButton({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.isOutlined,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : color,
          side: isOutlined ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const StadiumBorder(), // Bo tròn 2 đầu
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 13),
        ),
      ),
    );
  }
}