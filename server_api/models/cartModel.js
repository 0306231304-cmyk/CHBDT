import { execute } from "../config/db.js";

export default class cartModel{
    static async updateQuantity(userId, variantId, quantity) {
        try{
            if(quantity <= 0){
                // Nếu số lượng <= 0 thì xóa luôn
                await this.removeItem(userId, variantId);
            } else {
                await execute(
                    "UPDATE carts SET quantity = ? WHERE user_id = ? AND product_variant_id = ?",
                    [quantity, userId, variantId]
                );
            }
        }
        catch(error){
            throw new Error('Lỗi cập nhật giỏ hàng: '+error.message);
        }
    }
    
    static async addToCart(userId, variantId, quantity) {
        try {
            const [checkItem] = await execute(
                "SELECT * FROM carts WHERE user_id = ? AND product_variant_id = ?", 
                [userId, variantId]
            );

            if (checkItem.length > 0) {
                // Đã có -> Chỉ cần cộng thêm số lượng
                const newQuantity = checkItem[0].quantity + quantity;
                await execute(
                    "UPDATE carts SET quantity = ? WHERE user_id = ? AND product_variant_id = ?",
                    [newQuantity, userId, variantId]
                );
            } else {
                // Chưa có -> Thêm dòng mới
                await execute(
                    "INSERT INTO carts (user_id, product_variant_id, quantity) VALUES (?, ?, ?)",
                    [userId, variantId, quantity]
                );
            }
            return true;
        } catch (error) {
            throw new Error("Lỗi thêm vào giỏ hàng: " + error.message);
        }
    }

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

        const [items] = await execute(`
            SELECT 
                product_variants.id as product_variant_id, 
                product_variants.price, 
                product_variants.image_url,
                product_variants.color,
                product_variants.ram,
                product_variants.storage,
                products.name,
                carts.quantity
            FROM 
                carts, product_variants, products 
            WHERE 
                carts.product_variant_id = product_variants.id 
                AND carts.user_id = 7 
                AND product_variants.product_id = products.id;
        `,[userId]);
        console.log('DEBUG: Kết quả tìm item: ', items);
        return items;
    }

    static async removeItem(userId, variantId) {
        await execute(
            "DELETE FROM carts WHERE user_id = ? AND product_variant_id = ?", 
            [userId, variantId]
        );
    }
    static async getTotalPrice(user_id){
        try{
            const cartDetail = await this.getCartDetails(user_id);
            var total = 0;
            cartDetail.forEach((product) => {
                total = total + (product.price * product.quantity)
            });
            return total;
        }
        catch(error){
            throw new Error('Lỗi tính tổng tiền giỏ hàng: ',error.message);
        }
    }
}