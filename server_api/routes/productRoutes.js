import { Router } from "express";
import productController from "../controllers/productController.js";
import reviewsController from "../controllers/reviewsController.js";
import auth from "../middleware/auth.js";
/**
 * @swagger
 * tags:
 *   name: Products
 *   description: API sản phẩm
 */
const productRoute = Router();
const authProductRoute = Router();
authProductRoute.use(auth);
/**
 * @swagger
 * /products:
 *   get:
 *     summary: Lấy danh sách tất cả sản phẩm
 *     tags:
 *       - Products
 *     responses:
 *       200:
 *         description: Thành công
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
 *                 products:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       name:
 *                         type: string
 *                       image_url:
 *                         type: string
 */
productRoute.get('/',productController.products);
/**
 * @swagger
 * /products/search:
 *   get:
 *     summary: Tìm kiếm sản phẩm theo tên
 *     tags:
 *       - Products
 *     parameters:
 *       - in: query
 *         name: q
 *         required: true
 *         schema:
 *           type: string
 *         description: Từ khóa tìm kiếm
 *         example: "iPhone"
 *     responses:
 *       200:
 *         description: Tìm thấy sản phẩm
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 succeeded:
 *                   type: boolean
 *                   example: true
 *                 count:
 *                   type: integer
 *                 products:
 *                   type: array
 *                   items:
 *                     type: object
 *       400:
 *         description: Chưa nhập từ khóa
 *       404:
 *         description: Không tìm thấy sản phẩm nào
 */

productRoute.get('/search',productController.searchProduct);


/**
 * @swagger
 * /products/reviews/{product_id}:
 *   get:
 *     summary: Lấy danh sách đánh giá của sản phẩm
 *     tags:
 *       - Reviews
 *     parameters:
 *       - in: path
 *         name: product_id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID của sản phẩm cần xem đánh giá
 *         example: 1
 *     responses:
 *       200:
 *         description: Lấy danh sách đánh giá thành công
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
 *                   example: Lấy đánh giá sản phẩm thành công
 *                 reviews:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                         example: 10
 *                       user_id:
 *                         type: integer
 *                         example: 5
 *                       rating:
 *                         type: integer
 *                         description: Số sao đánh giá (1-5)
 *                         example: 5
 *                       comment:
 *                         type: string
 *                         example: Sản phẩm dùng rất tốt, giao hàng nhanh.
 *                       created_at:
 *                         type: string
 *                         format: date-time
 *                         example: 2024-01-08T10:00:00Z
 *       400:
 *         description: Thiếu ID sản phẩm hoặc ID không hợp lệ
 *       404:
 *         description: Không tìm thấy sản phẩm
 *       500:
 *         description: Lỗi server
 */
productRoute.get('/reviews/:product_id',reviewsController.getReviewProduct);

/**
 * @swagger
 * /products/{id}:
 *   get:
 *     summary: Xem chi tiết một sản phẩm (bao gồm các biến thể màu/RAM)
 *     tags:
 *       - Products
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID của sản phẩm
 *     responses:
 *       200:
 *         description: Lấy chi tiết thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 succeeded:
 *                   type: boolean
 *                   example: true
 *                 product:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                     name:
 *                       type: string
 *                     variants:
 *                       type: array
 *                       description: Danh sách các phiên bản (màu, bộ nhớ)
 *                       items:
 *                         type: object
 *       404:
 *         description: Sản phẩm không tồn tại
 */
productRoute.get('/:id', productController.detailProduct);

authProductRoute.post('/add-review', reviewsController.addReview);

productRoute.use('/', authProductRoute);

export default productRoute;