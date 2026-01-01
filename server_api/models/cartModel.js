import { execute } from "../config/db.js";

export default class cartModel{
    static async createCartForUser(userId) {
        try {
            await execute("INSERT INTO carts (user_id) VALUES (?)", [userId]);
        } catch (error) {
            throw new Error("Lỗi tạo giỏ hàng: " + error.message);
        }
    }
    static async getCartId(userId) {
        try{
            const [result] = await execute("SELECT id FROM `carts` WHERE user_id = ?", [userId]);
            return result[0].id ?? null;
        }
        catch(error){
            throw new Error("Lỗi truy xuất id giỏ hàng: "+error.message);
        }
    }

    static async updateQuantity(userId, variantId, quantity) {
        const cartId = await this.getCartId(userId);
        if(quantity <= 0){
             // Nếu số lượng <= 0 thì xóa luôn
             await this.removeItem(userId, variantId);
        } else {
             await execute(
                "UPDATE cart_items SET quantity = ? WHERE cart_id = ? AND product_variant_id = ?",
                [quantity, cartId, variantId]
            );
        }
    }
    
    static async addToCart(userId, variantId, quantity) {
        try {
            const cartId = await this.getCartId(userId);
            console.log("DEBUG ADD CART:", { cartId, variantId, quantity });
            // Kiểm tra xem sản phẩm này đã có trong giỏ chưa
            const [checkItem] = await execute(
                "SELECT * FROM cart_items WHERE cart_id = ? AND product_variant_id = ?", 
                [cartId, variantId]
            );

            if (checkItem.length > 0) {
                // Đã có -> Chỉ cần cộng thêm số lượng
                const newQuantity = checkItem[0].quantity + quantity;
                await execute(
                    "UPDATE cart_items SET quantity = ? WHERE cart_id = ? AND product_variant_id = ?",
                    [newQuantity, cartId, variantId]
                );
            } else {
                // Chưa có -> Thêm dòng mới
                await execute(
                    "INSERT INTO cart_items (cart_id, product_variant_id, quantity) VALUES (?, ?, ?)",
                    [cartId, variantId, quantity]
                );
            }
            return true;
        } catch (error) {
            throw new Error("Lỗi thêm vào giỏ: " + error.message);
        }
    }

    // models/cartModel.js

    static async getCartDetails(userId) {
        // --- BƯỚC DEBUG: In ra xem Server đang nhận ID mấy ---
        console.log("DEBUG: Đang tìm giỏ hàng cho User ID:", userId); 

        const [cartRows] = await execute("SELECT id FROM carts WHERE user_id = ?", [userId]);
        
        // --- BƯỚC DEBUG: In ra kết quả tìm được ---
        console.log("DEBUG: Kết quả tìm cart:", cartRows);

        // KIỂM TRA AN TOÀN (Bắt buộc phải có)
        if (!cartRows || cartRows.length === 0) {
            // Nếu không tìm thấy giỏ, thay vì để crash, ta trả về mảng rỗng
            console.log("-> Không tìm thấy giỏ hàng nào!");
            return []; 
        }

        const cartId = cartRows[0].id; // Lúc này mới an toàn để lấy ID

        const query = `
            SELECT 
                ci.product_variant_id, 
                ci.quantity,
                p.name as product_name,
                pv.color, pv.ram, pv.storage, pv.price, pv.image_url
            FROM cart_items ci
            JOIN product_variants pv ON ci.product_variant_id = pv.id
            JOIN products p ON pv.product_id = p.id
            WHERE ci.cart_id = ?
        `;
        const [items] = await execute(query, [cartId]);
        console.log("DEBUG: Kết quả tìm items:", items);
        return items;
    }

    static async removeItem(userId, variantId) {
        const cartId = await this.getCartId(userId);
        await execute(
            "DELETE FROM cart_items WHERE cart_id = ? AND product_variant_id = ?", 
            [cartId, variantId]
        );
    }
}