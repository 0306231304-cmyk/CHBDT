import { Router } from "express";
import couponController from "../controllers/couponController.js";

const couponRoute = Router();
/**
 * @swagger
 * /coupons:
 *   get:
 *     summary: Lấy danh sách mã giảm giá
 *     description: API trả về danh sách tất cả các mã giảm giá đang hoạt động (is_active = 1).
 *     tags: [Coupons]
 *     responses:
 *       200:
 *         description: Lấy dữ liệu thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 succeeded:
 *                   type: boolean
 *                   example: true
 *                 coupons:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                         example: 1
 *                       code:
 *                         type: string
 *                         description: "Mã code người dùng nhập (VD: SALE50)"
 *                         example: "SUMMER2024"
 *                       discount_value:
 *                         type: number
 *                         description: Số tiền giảm giá
 *                         example: 50000
 *                       start_date:
 *                         type: string
 *                         format: date-time
 *                         example: "2024-01-01T00:00:00.000Z"
 *                       end_date:
 *                         type: string
 *                         format: date-time
 *                         example: "2024-12-31T23:59:59.000Z"
 *                       quantity:
 *                         type: integer
 *                         description: Số lượng mã còn lại
 *                         example: 100
 *                       is_active:
 *                         type: integer
 *                         description: 1 là đang hoạt động
 *                         example: 1
 *       500:
 *         description: Lỗi Server
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
 *                   example: "Lỗi lấy danh sách khuyến mãi"
 */
couponRoute.get('/', couponController.getAllCoupon);

couponRoute.get('/:coupon_id',couponController.getCouponByID);

export default couponRoute;