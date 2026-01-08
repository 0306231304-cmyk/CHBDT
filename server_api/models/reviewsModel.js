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

    static async addReview(review, product_id, order_id, user_id) {
        try {
            const queryCheck = `
                SELECT COUNT(*) as can_review
                FROM orders o
                JOIN order_items oi ON o.id = oi.order_id
                JOIN product_variants pv ON oi.product_variant_id = pv.id
                WHERE 
                    o.user_id = ?              -- Đúng người mua
                    AND o.id = ?               -- Đúng đơn hàng
                    AND pv.product_id = ?      -- Đúng sản phẩm
                    AND o.status = 'delivered' -- Đơn hàng đã giao thành công
                    AND NOT EXISTS (           -- Chưa từng đánh giá đơn này
                        SELECT 1 FROM reviews r 
                        WHERE r.user_id = o.user_id 
                        AND r.product_id = pv.product_id 
                        AND r.order_id = o.id
                    );
            `;

            const [checkRows] = await execute(queryCheck, [user_id, order_id, product_id]);

            if (checkRows[0].can_review > 0) {
                
                const [result] = await execute(
                    'INSERT INTO `reviews` (`user_id`, `product_id`, `order_id`, `rating`, `comment`) VALUES (?, ?, ?, ?, ?)',
                    [user_id, product_id, order_id, review.rating, review.comment]
                );

                return result.affectedRows > 0 ? result.insertId : null;
            } else {
                throw new Error('Bạn không thể đánh giá (Chưa mua, chưa nhận hàng, sai sản phẩm hoặc đã đánh giá rồi)');
            }
        } catch (error) {
            throw new Error('Lỗi thêm đánh giá (reviewsModel): ' + error.message);
        }
    }
}