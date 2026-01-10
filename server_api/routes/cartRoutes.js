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
 *                         description: ID của biến thể sản phẩm (variant id)
 *                         example: 1
 *                       name:
 *                         type: string
 *                         description: Tên sản phẩm
 *                         example: "iPhone 15 Pro Max"
 *                       price:
 *                         type: string
 *                         description: Giá tiền (dạng chuỗi decimal)
 *                         example: "29990000.00"
 *                       image_url:
 *                         type: string
 *                         description: Link ảnh sản phẩm
 *                         example: "https://cdn2.cellphones.com.vn/..."
 *                       color:
 *                         type: string
 *                         description: Màu sản phẩm
 *                         example: "Tím"
 *                       ram:
 *                         type: string
 *                         description: RAM
 *                         example: "6GB"
 *                       storage:
 *                         type: string
 *                         description: Dung lượng máy
 *                         example: "128GB"
 *                       quantity:
 *                         type: int
 *                         description: Số lượng sản phẩm
 *                         example: 1 
 *                 total_money:
 *                   type: number
 *                   nullable: true
 *                   description: Tổng tiền tạm tính (có thể null)
 *                   example: 29990000.00
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

cartRoutes.post('/merge', cartController.mergeCart);

export default cartRoutes;