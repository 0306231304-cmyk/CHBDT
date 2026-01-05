import orderModel from "../models/orderModel";

export default class orderController{
    static async createOrder(req, res) {
        try {
            const userId = req.user.id; // Lấy từ Token
            const { fullName, phone, address, note } = req.body;

            // Validate dữ liệu
            if (!fullName || !phone || !address) {
                return res.status(400).json({ message: "Thiếu thông tin giao hàng (tên, sđt, địa chỉ)" });
            }

            const shippingData = { fullName, phone, address, note };

            // Gọi Model
            const orderId = await OrderModel.checkout(userId, shippingData);

            return res.status(201).json({
                message: "Đặt hàng thành công",
                order_id: orderId
            });

        } catch (error) {
            console.error("Checkout Error:", error);
            return res.status(500).json({ message: error.message });
        }
    }
}