import { execute } from "../config/db.js";

export default class reviewsModel {
    
    static async getReviewsByProductId(product_id) {
        try {
            const [rows] = await execute(`
                SELECT reviews.rating, reviews.comment, reviews.created_at, users.fullname 
                FROM reviews 
                JOIN users ON reviews.user_id = users.id 
                WHERE product_id = ?
                ORDER BY reviews.created_at DESC
            `, [product_id]);

            if (rows.length === 0) {
                return {
                    totalRating: 0,
                    avgRating: 0,
                    rows: []
                };
            }

            // Tính toán rating
            let totalRating = 0;
            rows.forEach((r) => {
                totalRating += r.rating;
            });
            const avgRating = parseFloat((totalRating / rows.length).toFixed(1));

            return {
                totalRating,
                avgRating,
                rows
            };
        } catch (error) {
            throw new Error("Lỗi lấy đánh giá sản phẩm: " + error.message);
        }
    }

    static async addReview(review, product_id, user_id) {
        try {
            // 1. Tìm đơn hàng gần nhất mà user đã mua sản phẩm này (và đã giao thành công)
            const queryCheck = `
                SELECT o.id as found_order_id
                FROM orders o
                JOIN order_items oi ON o.id = oi.order_id
                JOIN product_variants pv ON oi.product_variant_id = pv.id
                WHERE 
                    o.user_id = ?              -- Của user này
                    AND pv.product_id = ?      -- Có chứa sản phẩm này (bất kỳ màu/dung lượng nào)
                    AND o.status = 'delivered' -- Đã giao hàng
                    AND NOT EXISTS (           -- Đảm bảo user chưa từng đánh giá sản phẩm này trước đây
                        SELECT 1 FROM reviews r 
                        WHERE r.user_id = o.user_id 
                        AND r.product_id = pv.product_id
                    )
                ORDER BY o.created_at DESC     -- Lấy đơn mới nhất nếu mua nhiều lần
                LIMIT 1;
            `;

            const [checkRows] = await execute(queryCheck, [user_id, product_id]);

            // 2. Nếu tìm thấy đơn hàng hợp lệ
            if (checkRows.length > 0) {
                const orderId = checkRows[0].found_order_id; // Lấy ID đơn hàng tìm được

                const [result] = await execute(
                    'INSERT INTO `reviews` (`user_id`, `product_id`, `order_id`, `rating`, `comment`, `created_at`) VALUES (?, ?, ?, ?, ?, NOW())',
                    [user_id, product_id, orderId, review.rating, review.comment]
                );

                return result.affectedRows > 0 ? result.insertId : null;
            } else {
                throw new Error('Bạn không thể đánh giá (Chưa mua, chưa nhận hàng hoặc đã đánh giá sản phẩm này rồi)');
            }
        } catch (error) {
            throw new Error('Lỗi thêm đánh giá: ' + error.message);
        }
    }
}