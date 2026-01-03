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
 *     summary: Xem giỏ hàng
 *     tags: [Cart]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lấy danh sách sản phẩm trong giỏ hàng thành công
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
 *                       id:
 *                         type: integer
 *                         example: 1
 *                       variant_id:
 *                         type: integer
 *                         example: 5
 *                       product_name:
 *                         type: string
 *                         example: "Áo thun nam"
 *                       color:
 *                         type: string
 *                         example: "Đen"
 *                       size:
 *                         type: string
 *                         example: "M"
 *                       price:
 *                         type: number
 *                         format: float
 *                         example: 199000
 *                       quantity:
 *                         type: integer
 *                         example: 2
 *                       image:
 *                         type: string
 *                         example: "image_url.jpg"
 *                 total_money:
 *                   type: number
 *                   format: float
 *                   example: 398000
 *       401:
 *         description: Chưa đăng nhập hoặc token không hợp lệ
 *       500:
 *         description: Lỗi server
 */
cartRoutes.get('/', cartController.viewCart);

/**
 * @swagger
 * /cart/add:
 *   post:
 *     summary: Thêm sản phẩm vào giỏ hàng
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
 *                 example: 1
 *     responses:
 *       200:
 *         description: Thêm vào giỏ hàng thành công
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
 *                   example: "Đã thêm vào giỏ"
 *       400:
 *         description: Thiếu thông tin variant_id hoặc quantity
 *       401:
 *         description: Chưa đăng nhập hoặc token không hợp lệ
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