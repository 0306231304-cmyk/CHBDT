import { Router } from "express";
const userRoutes = Router();
import userController from "../controllers/userController.js";
import auth from "../middleware/auth.js";
/**
 * @swagger
 * tags:
 *   name: Users
 *   description: API người dùng & xác thực
 */
const authRoutes = Router();
authRoutes.use(auth);

/**
 * @swagger
 * /register:
 *   post:
 *     summary: Đăng ký tài khoản người dùng
 *     tags: [Users]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *               - fullName
 *               - phoneNumber
 *               - address
 *             properties:
 *               email:
 *                 type: string
 *                 example: user@gmail.com
 *               password:
 *                 type: string
 *                 example: Abc@1234
 *               fullName:
 *                 type: string
 *                 example: Nguyễn Văn A
 *               phoneNumber:
 *                 type: string
 *                 example: "0123456789"
 *               address:
 *                 type: string
 *                 example: Hà Nội
 *     responses:
 *       201:
 *         description: Đăng ký thành công
 *       400:
 *         description: Dữ liệu không hợp lệ
 *       409:
 *         description: Email đã tồn tại
 */
userRoutes.post('/register',userController.register);
/**
 * @swagger
 * /login:
 *   post:
 *     summary: Đăng nhập người dùng
 *     tags: [Users]
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
 *                 example: user@gmail.com
 *               password:
 *                 type: string
 *                 example: Abc@1234
 *     responses:
 *       200:
 *         description: Đăng nhập thành công, trả về JWT
 *       401:
 *         description: Sai email hoặc mật khẩu
 */
userRoutes.post('/login',userController.login);
/**
 * @swagger
 * /logout:
 *   post:
 *     summary: Đăng xuất người dùng
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Đăng xuất thành công
 *       400:
 *         description: Token không hợp lệ
 */
authRoutes.post('/logout',userController.logout);
/**
 * @swagger
 * /profile:
 *   get:
 *     summary: Lấy thông tin người dùng hiện tại
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Thành công
 *       401:
 *         description: Chưa đăng nhập
 *       404:
 *         description: Không tìm thấy người dùng
 */
authRoutes.get('/profile',userController.profile);
/**
 * @swagger
 * /updateprofile:
 *   put:
 *     summary: Cập nhật thông tin người dùng
 *     tags: [Users]
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
 *               - phoneNumber
 *               - address
 *             properties:
 *               fullName:
 *                 type: string
 *                 example: Nguyễn Văn B
 *               phoneNumber:
 *                 type: string
 *                 example: "0987654321"
 *               address:
 *                 type: string
 *                 example: TP.HCM
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 *       400:
 *         description: Thiếu thông tin
 *       401:
 *         description: Chưa đăng nhập
 */
authRoutes.put('/updateprofile',userController.updateUser);

userRoutes.use('/',authRoutes);
export default userRoutes;
