import { Router } from "express";
import auth from "../middleware/auth.js";
import orderController from "../controllers/orderController.js";
const orderRoutes = Router();
const authOrderRoutes = Router();
authOrderRoutes.use(auth);
/**
 * @swagger
 * tags:
 *   - name: Orders
 *     description: Quản lý đơn hàng
 */

/**
 * @swagger
 * /orders/order:
 *   post:
 *     summary: Tạo đơn hàng mới (Checkout)
 *     tags:
 *       - Orders
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - fullName
 *               - phone
 *               - address
 *             properties:
 *               fullName:
 *                 type: string
 *                 description: Họ tên người nhận
 *                 example: Nguyễn Văn A
 *               phone:
 *                 type: string
 *                 description: Số điện thoại người nhận
 *                 example: "0901234567"
 *               address:
 *                 type: string
 *                 description: Địa chỉ giao hàng
 *                 example: 123 Đường Nguyễn Huệ, Quận 1, TP.HCM
 *               note:
 *                 type: string
 *                 description: Ghi chú thêm (không bắt buộc)
 *                 example: Giao hàng vào giờ hành chính
 *     responses:
 *       201:
 *         description: Đặt hàng thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Đặt hàng thành công
 *                 order_id:
 *                   type: integer
 *                   description: ID của đơn hàng vừa tạo
 *                   example: 15
 *       400:
 *         description: Thiếu thông tin giao hàng (Tên, SĐT, Địa chỉ)
 *       401:
 *         description: Chưa đăng nhập (Token thiếu hoặc hết hạn)
 *       500:
 *         description: Lỗi Server (Hết hàng tồn kho, lỗi DB...)
 */
authOrderRoutes.post('/order',orderController.createOrder);


orderRoutes.use('/',authOrderRoutes);
export default orderRoutes;

