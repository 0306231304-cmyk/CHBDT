import { Router } from "express";
const adminRoutes = Router();
import userController from "../controllers/userController.js";
import auth from "../middleware/auth.js";
import admin from "../middleware/admin.js";
import orderController from "../controllers/orderController.js";
/**
 * @swagger
 * tags:
 *   name: Admin
 *   description: API quản trị hệ thống
 */

const adminAuthRoutes = Router();
adminAuthRoutes.use(auth,admin);
/**
 * @swagger
 * /admin/login:
 *   post:
 *     summary: Đăng nhập tài khoản admin
 *     tags: [Admin]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 example: admin@gmail.com
 *               password:
 *                 type: string
 *                 example: Admin@123
 *     responses:
 *       200:
 *         description: Đăng nhập thành công, trả về JWT
 *       400:
 *         description: Thiếu email hoặc mật khẩu
 *       401:
 *         description: Không phải admin hoặc sai thông tin đăng nhập
 */
adminRoutes.post('/login', userController.adminLogin);
/**
 * @swagger
 * /admin/logout:
 *   post:
 *     summary: Đăng xuất admin
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Đăng xuất thành công
 *       400:
 *         description: Token không hợp lệ
 *       401:
 *         description: Chưa xác thực
 */
adminAuthRoutes.post('/logout', userController.logout);
/**
 * @swagger
 * /admin/users:
 *   get:
 *     summary: Lấy danh sách tất cả người dùng
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lấy danh sách người dùng thành công
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
 *                   example: Lấy danh sách thành công
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                         example: 1
 *                       Email:
 *                         type: string
 *                         example: user@gmail.com
 *                       Fullname:
 *                         type: string
 *                         example: Nguyễn Văn A
 *                       PhoneNumber:
 *                         type: string
 *                         example: "0123456789"
 *                       Address:
 *                         type: string
 *                         example: Hà Nội
 *       401:
 *         description: Không có quyền admin
 *       500:
 *         description: Lỗi server
 */
adminAuthRoutes.get('/users',userController.getAllUsers);

/**
 * @swagger
 * /admin/approve-order/{orderId}:
 *   patch:
 *     summary: Admin thay đổi trạng thái đơn hàng
 *     description: Admin cập nhật trạng thái đơn hàng (approved, cancelled, ...)
 *     tags:
 *       - Admin Orders
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: orderId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của đơn hàng cần duyệt
 *         example: 1
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - curStatus
 *             properties:
 *               status:
 *                 type: string
 *                 description: Trạng thái mới của đơn hàng
 *                 enum: ['pending','processing','shipping','delivered','cancelled']
 *                 example: processing
 *     responses:
 *       200:
 *         description: Duyệt đơn hàng thành công
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
 *                   example: Duyệt đơn hàng thành công
 *       400:
 *         description: Thiếu orderId hoặc trạng thái đơn hàng
 *       401:
 *         description: Chưa đăng nhập hoặc token không hợp lệ
 *       409:
 *         description: Đơn hàng đã bị hủy trước đó
 *       500:
 *         description: Lỗi server khi duyệt đơn hàng
 */
adminAuthRoutes.patch('/approve-order/:id',orderController.approveOrder);

adminRoutes.use('/',adminAuthRoutes);
export default adminRoutes;