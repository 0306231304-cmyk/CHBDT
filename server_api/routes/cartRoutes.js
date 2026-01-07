import { Router } from "express";
import cartController from "../controllers/cartController.js";
import auth from "../middleware/auth.js";

const cartRoutes = Router();

cartRoutes.use(auth);

/**
 * @swagger
 * tags:
 *   name: Cart
 *   description: Quản lý giỏ hàng
 */

/**
 * @swagger
 * /cart:
 *   get:
 *     summary: Xem giỏ hàng hiện tại
 *     tags:
 *       - Cart
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lấy danh sách thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 succeeded:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       product_variant_id:
 *                         type: integer
 *                         example: 10
 *                       product_name:
 *                         type: string
 *                         example: "iPhone 15 Pro Max"
 *                       color:
 *                         type: string
 *                         example: "Titan Tự nhiên"
 *                       ram:
 *                         type: string
 *                         example: "8GB"
 *                       storage:
 *                         type: string
 *                         example: "256GB"
 *                       price:
 *                         type: number
 *                         example: 29990000
 *                       quantity:
 *                         type: integer
 *                         example: 2
 *                       image_url:
 *                         type: string
 *                         example: "https://example.com/image.jpg"
 *                 total_money:
 *                   type: number
 *                   description: Tổng tiền tạm tính của cả giỏ
 *                   example: 59980000
 *       500:
 *         description: Lỗi server
 */
cartRoutes.get('/', cartController.viewCart);

/**
 * @swagger
 * /cart/add:
 *   post:
 *     summary: Thêm sản phẩm vào giỏ hàng
 *     tags:
 *       - Cart
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - variant_id
 *               - quantity
 *             properties:
 *               variant_id:
 *                 type: integer
 *                 description: ID của phiên bản sản phẩm (Product Variant ID)
 *                 example: 5
 *               quantity:
 *                 type: integer
 *                 description: Số lượng muốn mua
 *                 example: 1
 *     responses:
 *       200:
 *         description: Thêm thành công
 *       400:
 *         description: Thiếu thông tin
 *       500:
 *         description: Lỗi server
 */
cartRoutes.post('/add', cartController.addToCart);

/**
 * @swagger
 * /cart/update:
 *   put:
 *     summary: Cập nhật số lượng sản phẩm trong giỏ hàng
 *     tags: [Cart]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - variant_id
 *               - quantity
 *             properties:
 *               variant_id:
 *                 type: integer
 *                 example: 5
 *               quantity:
 *                 type: integer
 *                 example: 3
 *     responses:
 *       200:
 *         description: Cập nhật số lượng thành công
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
 *                   example: "Đã cập nhật số lượng"
 *       400:
 *         description: Thiếu thông tin variant_id hoặc quantity
 *       401:
 *         description: Chưa đăng nhập hoặc token không hợp lệ
 *       500:
 *         description: Lỗi server
 */
cartRoutes.put('/update', cartController.update);

/**
 * @swagger
 * /cart/remove:
 *   delete:
 *     summary: Xóa sản phẩm khỏi giỏ hàng
 *     tags: [Cart]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - variant_id
 *             properties:
 *               variant_id:
 *                 type: integer
 *                 example: 5
 *     responses:
 *       200:
 *         description: Xóa sản phẩm thành công
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
 *                   example: "Đã xóa sản phẩm"
 *       400:
 *         description: Thiếu variant_id
 *       401:
 *         description: Chưa đăng nhập hoặc token không hợp lệ
 *       500:
 *         description: Lỗi server
 */
cartRoutes.delete('/remove', cartController.remove);

export default cartRoutes;