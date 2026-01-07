import cartModel from "../models/cartModel.js";
import couponModel from "../models/couponModel.js";
import orderModel from "../models/orderModel.js";

export default class orderController{
    static async createOrder(req, res) {
        try {
            const userId = req.userid; 
            if (!userId) return res.status(401).json({ succeeded: false, message: "Chưa đăng nhập" });

            // 1. Nhận dữ liệu (Chỉ nhận mã coupon, KHÔNG nhận giá tiền từ client gửi lên)
            const { fullName, phone, address, city, note, coupon_code } = req.body;

            // Validate dữ liệu
            if (!fullName || !phone || !address || !city) {
                return res.status(400).json({ succeeded: false, message: "Thiếu thông tin giao hàng (tên, sđt, địa chỉ, thành phố)" });
            }

            const shippingData = { fullName, phone, address, city, note };

            // 2. Đẩy toàn bộ trách nhiệm tính tiền xuống Model (An toàn tuyệt đối)
            const orderId = await orderModel.checkout(userId, shippingData, coupon_code);

            return res.status(201).json({
                succeeded: true,
                message: "Đặt hàng thành công",
                order_id: orderId
            });

        } catch (error) {
            console.error("Checkout Error:", error);
            // Trả về lỗi 400 hoặc 500 tùy tình huống
            return res.status(500).json({ succeeded: false, message: error.message });
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

    static async getOrderDetail(req,res){
        try{
            const id = req.userid;
            const {orderID} = req.params;
            if(!id) return res.status(400).json({succeeded: false, message:"Bạn chưa đăng nhập"});
            if(!orderID)return res.status(400).json({succeeded: false, message: 'Thiếu ID đơn hàng'});

            const order = await orderModel.getOrderDetail(orderID);

            return res.status(200).json({succeeded: true, message:"Lấy chi tiết hóa đơn thành công",
                order: order
            });

        }
        catch(error){
            return res.status(500).json({
                succeeded: false,
                message:"Lỗi lấy chi tiết hóa đơn: "+ error.message
            });
        }
    }
    static async getOrders(req,res){
        try{
            const user_id = req.userid;
            const orders = await orderModel.getListOrderByUserID(user_id);
            return res.status(200).json({succeeded: true, message: "Lấy danh sách đơn hàng thành công", orders: orders});
        }
        catch(error){
            return res.status(500).json({succeeded: false, message: "Lỗi lấy lịch sử đơn hàng của người dùng: " + error.message});
        }
    }
}