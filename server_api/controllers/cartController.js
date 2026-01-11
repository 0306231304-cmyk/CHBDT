import cartModel from "../models/cartModel.js";

export default class cartController{
    static async addToCart(req, res) {
        try {
            const userId = req.userid; // Lấy từ Token
            const { variant_id } = req.body;

            if (!variant_id) return res.status(400).json({ message: "Thiếu thông tin" });
            console.log("DEBUG: variant_id = ",variant_id);
            await cartModel.addToCart(userId, variant_id);

            return res.status(200).json({ succeeded: true, message: "Đã thêm vào giỏ" });
        } catch (error) {
            console.log("DEBUG: Lỗi addToCart: ", error.message);
            return res.status(500).json({ succeeded: false, message: error.message });
        }
    }

    // Xem giỏ hàng
    static async viewCart(req, res) {
        console.log("-----------------------------------------");
        console.log("DEBUG: Đã vào controller viewCart");
        console.log("DEBUG: User ID từ Token là:", req.userid);
        try {
            const userId = req.userid;
            console.log("DEBUG: Bắt đầu gọi cartModel.getCartDetails...");
            const items = await cartModel.getCartDetails(userId);
            
            // Tính tổng tiền giỏ hàng luôn cho tiện Frontend
            let totalMoney = 0;
            items.forEach(item => {
                totalMoney += item.price * item.quantity;
            });

            return res.status(200).json({
                succeeded: true,
                data: items,
                total_money: totalMoney
            });
        } catch (error) {
            console.error("DEBUG: Lỗi xảy ra:", error);
            return res.status(500).json({ succeeded: false, error: error.message });
        }
    }

    // Xóa sản phẩm
    static async remove(req, res) {
        try {
            const userId = req.userid;
            const { variant_id } = req.body; // Gửi variant_id cần xóa lên
            
            await cartModel.removeItem(userId, variant_id);
            return res.status(200).json({ succeeded: true, message: "Đã xóa sản phẩm" });
        } catch (error) {
            return res.status(500).json({ succeeded: false, error: error.message });
        }
    }
    
    // Cập nhật số lượng (Frontend gửi số lượng mới lên, ví dụ user bấm nút + hoặc -)
    static async update(req, res) {
        try {
            const userId = req.userid;
            const { variant_id, quantity } = req.body;
            
            await cartModel.updateQuantity(userId, variant_id, parseInt(quantity));
            return res.status(200).json({ succeeded: true, message: "Đã cập nhật số lượng" });
        } catch (error) {
            return res.status(500).json({ succeeded: false, error: error.message });
        }
    }

    static async mergeCart(req,res){
        try{
            const user_id = req.userid;
            console.log("DEBUG: user_id = ", user_id);
            const {product_variant_id, quantity} = req.body;

            if(!product_variant_id || !quantity) return res.status(400).json({
                succeeded: false,
                message: "Thiếu mã biến thể hoặc số lượng"
            });

            await cartModel.mergeCart(user_id,product_variant_id,quantity);
            
            return res.status(200).json({
                succeeded: true,
            });
        }
        catch(error){
            return res.status(500).json({
                succeeded: false,
                message: "Lỗi gộp giỏ hàng: " + error.message
            });
        }
    }
}