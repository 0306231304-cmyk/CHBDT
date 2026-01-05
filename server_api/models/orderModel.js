import { execute } from "../config/db.js";

export default class orderModel{
    static async checkout(userId, shippingData) {
        // 1. Khởi tạo transaction (Lấy kết nối riêng)
        const conn = await beginTransaction();

        try {
            // --- BƯỚC A: Lấy dữ liệu giỏ hàng & Check kho ---
            // Lưu ý: Dùng conn.query thay vì execute
            const [cartItems] = await conn.query(
                `SELECT ci.*, pv.price, pv.inventory, pv.product_id 
                 FROM cart_items ci
                 JOIN product_variants pv ON ci.product_variant_id = pv.id
                 WHERE ci.cart_id = (SELECT id FROM carts WHERE user_id = ?)`,
                [userId]
            );

            if (cartItems.length === 0) {
                throw new Error("Giỏ hàng trống!");
            }

            let totalPrice = 0;
            // Kiểm tra tồn kho và tính tổng tiền
            for (const item of cartItems) {
                if (item.quantity > item.inventory) {
                    throw new Error(`Sản phẩm (ID: ${item.product_variant_id}) không đủ hàng. Chỉ còn ${item.inventory}.`);
                }
                totalPrice += item.price * item.quantity;
            }

            // --- BƯỚC B: Tạo đơn hàng (INSERT orders) ---
            const [orderResult] = await conn.query(
                `INSERT INTO orders (user_id, full_name, phone_number, address, note, total_money, status, created_at)
                 VALUES (?, ?, ?, ?, ?, ?, 'pending', NOW())`,
                [userId, shippingData.fullName, shippingData.phone, shippingData.address, shippingData.note, totalPrice]
            );

            const newOrderId = orderResult.insertId;

            // --- BƯỚC C: Thêm chi tiết đơn & Trừ kho ---
            for (const item of cartItems) {
                // C.1 Insert chi tiết
                await conn.query(
                    `INSERT INTO order_details (order_id, product_variant_id, price, quantity, total_price)
                     VALUES (?, ?, ?, ?, ?)`,
                    [newOrderId, item.product_variant_id, item.price, item.quantity, item.price * item.quantity]
                );

                // C.2 Trừ kho (Dùng chính conn này để đảm bảo đồng bộ)
                await conn.query(
                    `UPDATE product_variants SET inventory = inventory - ? WHERE id = ?`,
                    [item.quantity, item.product_variant_id]
                );
            }

            // --- BƯỚC D: Xóa giỏ hàng cũ ---
            const cartId = cartItems[0].cart_id;
            await conn.query("DELETE FROM cart_items WHERE cart_id = ?", [cartId]);

            // 2. Mọi thứ OK -> Commit Transaction (Lưu thật & đóng kết nối)
            await commitTransaction(conn);

            return newOrderId;

        } catch (error) {
            // 3. Có lỗi -> Rollback (Hoàn tác & đóng kết nối)
            await rollbackTransaction(conn);
            throw error; // Ném lỗi ra để Controller bắt
        }
    }
}