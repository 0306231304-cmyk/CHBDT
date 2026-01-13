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
 * /order:
 *   post:
 *     summary: Tạo đơn hàng mới (Checkout)
 *     description: API xử lý đặt hàng. Hỗ trợ cả "Mua ngay" và "Thanh toán giỏ hàng". Tính toán giá tiền và kho hàng được thực hiện phía server để bảo mật.
 *     tags: [Orders]
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
 *               - payment_method
 *               - order_details
 *               - is_buy_now
 *             properties:
 *               fullName:
 *                 type: string
 *                 example: "Nguyễn Văn A"
 *               phone:
 *                 type: string
 *                 example: "0901234567"
 *               address:
 *                 type: string
 *                 description: Địa chỉ cụ thể (số nhà, đường)
 *                 example: "123 Lê Lợi"
 *               city:
 *                 type: string
 *                 example: "Hồ Chí Minh"
 *               note:
 *                 type: string
 *                 example: "Giao hàng giờ hành chính"
 *               coupon_code:
 *                 type: string
 *                 description: Mã giảm giá (nếu có)
 *                 example: "SUMMER2024"
 *               payment_method:
 *                 type: string
 *                 enum:
 *                   - COD
 *                   - VNPAY
 *                   - MOMO
 *                 example: "COD"
 *               is_buy_now:
 *                 type: boolean
 *                 description: "true: Mua ngay (không xóa giỏ hàng cũ) | false: Thanh toán từ giỏ hàng (sẽ xóa giỏ hàng sau khi đặt)"
 *                 example: false
 *               order_details:
 *                 type: array
 *                 description: Danh sách sản phẩm muốn mua
 *                 items:
 *                   type: object
 *                   required:
 *                     - product_variant_id
 *                     - quantity
 *                   properties:
 *                     product_variant_id:
 *                       type: integer
 *                       example: 10
 *                     quantity:
 *                       type: integer
 *                       example: 2
 *     responses:
 *       201:
 *         description: Đặt hàng thành công
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
 *                   example: "Đặt hàng thành công"
 *                 order_id:
 *                   type: integer
 *                   example: 152
 *       400:
 *         description: Thiếu thông tin hoặc dữ liệu không hợp lệ
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 succeeded:
 *                   type: boolean
 *                   example: false
 *                 message:
 *                   type: string
 *                   example: "Thiếu thông tin giao hàng"
 *       401:
 *         description: Chưa đăng nhập (Không có Token)
 *       500:
 *         description: Lỗi Server (Hết hàng, lỗi mã giảm giá...)
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 succeeded:
 *                   type: boolean
 *                   example: false
 *                 message:
 *                   type: string
 *                   example: "Sản phẩm (ID: 10) không đủ hàng (chỉ còn 1)"
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

/**
 * @swagger
 * /orders/cancel/{order_id}:
 *   delete:
 *     summary: Hủy đơn hàng
 *     description: Hủy đơn hàng dựa trên ID, hoàn lại số lượng tồn kho (stock) và giảm số lượng đã bán (sold_count).
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: order_id
 *         required: true
 *         description: ID của đơn hàng cần hủy
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Hủy đơn hàng thành công
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
 *                   example: "Hủy đơn hàng thành công"
 *       400:
 *         description: Thiếu thông tin đầu vào (ID đơn hàng)
 *       500:
 *         description: Lỗi máy chủ nội bộ hoặc lỗi Transaction
 */

authOrderRoutes.delete('/cancel/:order_id', orderController.cancelOrder);


orderRoutes.use('/',authOrderRoutes);
export default orderRoutes;