import app from "../index.js";
import orderModel from "../models/orderModel.js";
import userModel from "../models/userModel.js";

export default class orderController{
    static async createOrder(req, res) {
        try {
            const userId = req.userid; // Lấy từ Token
            if(!userId) return res.status(401).json({succeeded: false, message: "Chưa đăng nhập"});
            const { fullName, phone, address, note } = req.body;

            // Validate dữ liệu
            if (!fullName || !phone || !address) {
                return res.status(400).json({succeeded: false, message: "Thiếu thông tin giao hàng (tên, sđt, địa chỉ)" });
            }

            const shippingData = { fullName, phone, address, note };

            // Gọi Model
            const orderId = await orderModel.checkout(userId, shippingData);

            return res.status(201).json({
                succeeded: true,
                message: "Đặt hàng thành công",
                order_id: orderId
            });

        } catch (error) {
            console.error("Checkout Error:", error);
            return res.status(500).json({succeeded: false, message: error.message });
        }
    }

    static async approveOrder(req,res){
        try{
            const userId = req.userid;
            if(!userId) return res.status(401).json({succeeded: false, message: "Chưa đăng nhập"});
            const orderID = req.params.id;
            if(!orderID) return res.status(400).json({succeeded: false, message: "Thiếu order_ID"});
            const {curStatus} = req.body;
            if(!curStatus) return res.status(400).json({succeeded: false, message: "Thiếu trạng thái đơn hàng"});
            const status = await orderModel.approveOrders(orderID,curStatus);
            if(status === 'cancelled') return res.status(409).json({succeeded: false, message: "Đơn hàng đã bị hủy trước đó"});
            if(!status) return res.status(500).json({succeeded: false, message: "Không thể thay đổi trạng thái đơn hàng do lỗi server"});

            return res.status(200).json({
                succeeded: true,
                message:"Thay đổi trạng thái đơn hàng thành công"
            });
        }
        catch(error){
            return res.status(500).json({
                succeeded: false,
                message: "Lỗi thay đổi trạng thái đơn hàng: "+error.message
            });
        }
    }
}