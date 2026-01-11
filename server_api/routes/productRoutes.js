import { Router } from "express";
import productController from "../controllers/productController.js";
import reviewsController from "../controllers/reviewsController.js";
import auth from "../middleware/auth.js";
import favoriteController from "../controllers/favoriteController.js";
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
 *                   example: Lấy danh sách sản phẩm thành công
 *                 products:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                         example: 1
 *                       brand_id:
 *                         type: integer
 *                         example: 1
 *                       name:
 *                         type: string
 *                         example: iPhone 15 Pro Max
 *                       description:
 *                         type: string
 *                         example: Điện thoại cao cấp nhất của Apple năm 2023 với khung Titan.
 *                       screen_size:
 *                         type: string
 *                         example: 6.7 inch
 *                       cpu:
 *                         type: string
 *                         example: Apple A17 Pro
 *                       camera:
 *                         type: string
 *                         example: 48MP + 12MP + 12MP
 *                       battery:
 *                         type: string
 *                         example: 4422 mAh
 *                       image_url:
 *                         type: string
 *                         example: https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-15-pro-max_3.jpg
 *                       sold_count:
 *                         type: integer
 *                         example: 10
 *                       created_at:
 *                         type: string
 *                         format: date-time
 *                         example: 2025-12-31T15:40:50.000Z
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
 * /products/product-variants/get-all:
 *   get:
 *     summary: Lấy danh sách tất cả biến thể sản phẩm
 *     description: Trả về danh sách biến thể kèm thông tin chung (tên, hãng, cấu hình...) và link ảnh đầy đủ.
 *     tags:
 *       - Products
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
 *                 product_variants:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                         example: 10
 *                       brand_id:
 *                         type: integer
 *                         example: 1
 *                       name:
 *                         type: string
 *                         example: iPhone 15 Pro Max
 *                       screen_size:
 *                         type: string
 *                         example: 6.7 inch
 *                       camera:
 *                         type: string
 *                         example: 48MP
 *                       storage:
 *                         type: string
 *                         example: 256GB
 *                       product_id:
 *                         type: integer
 *                         example: 5
 *                       color:
 *                         type: string
 *                         example: Titan Tự nhiên
 *                       ram:
 *                         type: string
 *                         example: 8GB
 *                       price:
 *                         type: number
 *                         format: double
 *                         example: 28990000
 *                       stock_quantity:
 *                         type: integer
 *                         example: 50
 *                       image:
 *                         type: string
 *                         example: http://192.168.1.5:3000/uploads/iphone15.jpg
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
 *                   example: Lỗi lấy danh sách biến thể sản phẩm
 */
productRoute.get('/product-variants/get-all',productController.getAllProductVariant);
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
 * /products/product-variants/{product_id}:
 *   get:
 *     summary: Lấy danh sách các biến thể (Màu sắc, RAM, ROM) của một sản phẩm
 *     tags:
 *       - Products
 *     parameters:
 *       - in: path
 *         name: product_id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID của sản phẩm cha
 *         example: 1
 *     responses:
 *       200:
 *         description: Lấy danh sách biến thể thành công
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
 *                   example: Lấy danh sách biến thể sản phẩm thành công
 *                 product_variants:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                         example: 1
 *                       product_id:
 *                         type: integer
 *                         example: 1
 *                       color:
 *                         type: string
 *                         example: Titan Tự Nhiên
 *                       ram:
 *                         type: string
 *                         example: 8GB
 *                       storage:
 *                         type: string
 *                         example: 256GB
 *                       price:
 *                         type: number
 *                         format: double
 *                         example: 29990000
 *                       stock_quantity:
 *                         type: integer
 *                         example: 50
 *                       image_url:
 *                         type: string
 *                         example: https://cdn2.cellphones.com.vn/insecure/...
 *       400:
 *         description: Thiếu ID sản phẩm
 *       500:
 *         description: Lỗi server
 */
productRoute.get('/product-variants/:product_id',productController.getProductVariantByProductId);

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

/**
 * @swagger
 * /products/add-review:
 *   post:
 *     summary: Thêm đánh giá cho sản phẩm (Cần đăng nhập)
 *     tags:
 *       - Reviews
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - product_id
 *               - rating
 *               - comment
 *             properties:
 *               product_id:
 *                 type: integer
 *                 description: ID của sản phẩm cần đánh giá
 *                 example: 1
 *               rating:
 *                 type: integer
 *                 description: Số sao đánh giá (1-5)
 *                 example: 5
 *               comment:
 *                 type: string
 *                 description: Nội dung đánh giá
 *                 example: Sản phẩm tuyệt vời, giao hàng nhanh!
 *     responses:
 *       200:
 *         description: Đánh giá thành công
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
 *                   example: Thêm đánh giá thành công
 *       401:
 *         description: Chưa đăng nhập hoặc token hết hạn
 *       500:
 *         description: Lỗi server
 */

authProductRoute.post('/add-review', reviewsController.addReview);


/**
 * @swagger
 * /products/favorites/get-all:
 *   get:
 *     summary: Lấy danh sách sản phẩm yêu thích của người dùng (Cần đăng nhập)
 *     tags:
 *       - Favorites
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
 *                 message:
 *                   type: string
 *                   example: Lấy danh sách sản phẩm ưa thích thành công
 *                 favorites:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                         example: 10
 *                       user_id:
 *                         type: integer
 *                         example: 7
 *                       product_id:
 *                         type: integer
 *                         example: 2
 *                       created_at:
 *                         type: string
 *                         format: date-time
 *                         example: 2026-01-08T10:00:00Z
 *       401:
 *         description: Chưa đăng nhập
 *       500:
 *         description: Lỗi server
 */

authProductRoute.get('/favorites/get-all', favoriteController.getListFavoriteByUserID);


/**
 * @swagger
 * /products/favorites/add/{product_id}:
 *   post:
 *     summary: Thêm sản phẩm vào danh sách yêu thích (Cần đăng nhập)
 *     tags:
 *       - Favorites
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: product_id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID của sản phẩm muốn thêm
 *         example: 1
 *     responses:
 *       200:
 *         description: Thêm thành công
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
 *                   example: Thêm sản phẩm vào ưa thích thành công
 *                 id:
 *                   type: integer
 *                   description: ID của record trong bảng favorites
 *                   example: 15
 *       400:
 *         description: Chưa đăng nhập hoặc lỗi dữ liệu
 *       500:
 *         description: Lỗi server hoặc sản phẩm không tồn tại
 */

authProductRoute.post('/favorites/add/:product_variant_id',favoriteController.addFavorite);

/**
 * @swagger
 * /products/favorites/remove/{product_id}:
 *   delete:
 *     summary: Xóa sản phẩm khỏi danh sách yêu thích (Cần đăng nhập)
 *     tags:
 *       - Favorites
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: product_id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID của sản phẩm muốn xóa
 *         example: 1
 *     responses:
 *       200:
 *         description: Xóa thành công
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
 *                   example: Xóa sản phẩm khỏi danh sách ưa thích thành công
 *       400:
 *         description: Chưa đăng nhập
 *       500:
 *         description: Lỗi server hoặc không tìm thấy sản phẩm trong danh sách yêu thích
 */

authProductRoute.delete('/favorites/remove/:product_variant_id',favoriteController.removeFavorite);

productRoute.use('/', authProductRoute);

export default productRoute;