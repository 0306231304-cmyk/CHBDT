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
 *               - city
 *             properties:
 *               fullName:
 *                 type: string
 *                 example: "Nguyễn Văn A"
 *               phone:
 *                 type: string
 *                 example: "0901234567"
 *               address:
 *                 type: string
 *                 description: Số nhà, tên đường
 *                 example: "123 Đường ABC"
 *               city:
 *                 type: string
 *                 description: Tên tỉnh/thành phố để tính phí ship
 *                 example: "TP.HCM || Hà Nội || Khác"
 *               note:
 *                 type: string
 *                 example: "Giao giờ hành chính"
 *               coupon_code:
 *                 type: string
 *                 description: Mã giảm giá (nếu có)
 *                 example: "GIAM20"
 *     responses:
 *       201:
 *         description: Đặt hàng thành công
 *       400:
 *         description: Thiếu thông tin hoặc mã giảm giá không hợp lệ/hết hạn
 *       500:
 *         description: Lỗi hết hàng hoặc lỗi server
 */
authOrderRoutes.post('/order', orderController.createOrder);

/**
 * @swagger
 * /orders/order-history:
 *   get:
 *     summary: Lấy lịch sử mua hàng của người dùng
 *     tags:
 *       - Orders
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lấy danh sách đơn hàng thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 succeeded:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Lấy danh sách đơn hàng thành công"
 *                 orders:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                         example: 15
 *                       total_price:
 *                         type: number
 *                         example: 25000000
 *                       status:
 *                         type: string
 *                         example: "pending"
 *                       created_at:
 *                         type: string
 *                         format: date-time
 *       401:
 *         description: Chưa đăng nhập
 *       500:
 *         description: Lỗi server
 */

authOrderRoutes.get('/order-history',orderController.getOrders);

/**
 * @swagger
 * /orders/{orderID}:
 *   get:
 *     summary: Lấy chi tiết đơn hàng theo ID
 *     tags:
 *       - Orders
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: orderID
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID của đơn hàng cần xem chi tiết
 *         example: 15
 *     responses:
 *       200:
 *         description: Lấy chi tiết đơn hàng thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 succeeded:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Lấy chi tiết hóa đơn thành công"
 *                 order:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                       example: 15
 *                     user_id:
 *                       type: integer
 *                       example: 2
 *                     status:
 *                       type: string
 *                       example: "shipping"
 *                     items:
 *                       type: array
 *                       description: Danh sách sản phẩm trong đơn hàng
 *                       items:
 *                         type: object
 *                         properties:
 *                           product_name:
 *                             type: string
 *                             example: "iPhone 15 Pro Max"
 *                           quantity:
 *                             type: integer
 *                             example: 1
 *                           price:
 *                             type: number
 *                             example: 34000000
 *       400:
 *         description: Thiếu ID đơn hàng hoặc ID không hợp lệ
 *       401:
 *         description: Chưa đăng nhập
 *       404:
 *         description: Không tìm thấy đơn hàng
 *       500:
 *         description: Lỗi server
 */
authOrderRoutes.get('/:orderID',orderController.getOrderDetail);


orderRoutes.use('/',authOrderRoutes);
export default orderRoutes;

