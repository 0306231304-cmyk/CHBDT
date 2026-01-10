import 'package:flutter/material.dart';
import '../../Resources/app_colors.dart';

class OrderProductItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final String status;
  final VoidCallback? onBuyAgain;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;

  const OrderProductItem({
    super.key,
    required this.item,
    required this.status,
    this.onBuyAgain,
    this.onCancel,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ảnh sản phẩm (Bên trái)
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.phone_iphone, color: Colors.grey, size: 35),
            ),
            const SizedBox(width: 12),

            // 2. Nội dung (Bên phải)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HÀNG 1: Tên sản phẩm (Trái)
                  Text(
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),

                  // HÀNG 2: Màu sắc (Trái) --- Số lượng (Phải)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Màu ${item['color'] ?? 'đen'}", 
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      ),
                      Text(
                        "x${item['qty']}",
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // HÀNG 3: Giá tiền (Phải)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      item['price'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // --- Hàng nút bấm ---
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (status == "Chờ xác nhận") ...[
              _buildActionButton(
                text: "Hủy", 
                color: Colors.red, 
                isOutlined: true,
                onTap: onCancel ?? () {},
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                text: "Mua lại", 
                color: AppColors.primaryOrange, 
                isOutlined: false,
                onTap: onBuyAgain ?? () {},
              ),
            ],
            if (status == "Đã hoàn thành") ...[
              _buildActionButton(
                text: "Xem đánh giá", 
                color: Colors.grey, 
                isOutlined: true,
                onTap: onReview ?? () {},
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                text: "Mua lại", 
                color: AppColors.primaryOrange, 
                isOutlined: false,
                onTap: onBuyAgain ?? () {},
              ),
            ],
            if (status == "Đã hủy") ...[
              _buildActionButton(
                text: "Mua lại", 
                color: AppColors.primaryOrange, 
                isOutlined: false,
                onTap: onBuyAgain ?? () {},
              ),
            ],
          ],
        )
      ],
    );
  }

  // Widget con tạo nút bấm
  Widget _buildActionButton({
    required String text, 
    required Color color, 
    required bool isOutlined,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 32,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(text, style: TextStyle(color: color, fontSize: 13)),
            )
          : ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                elevation: 0,
              ),
              child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
    );
  }
}