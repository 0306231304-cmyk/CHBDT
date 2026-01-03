import { Router } from "express";
import productController from "../controllers/productController.js";
/**
 * @swagger
 * tags:
 *   name: Products
 *   description: API sản phẩm
 */
const productRoute = Router();
/**
 * @swagger
 * /products:
 *   get:
 *     summary: Lấy danh sách tất cả sản phẩm
 *     tags: [Products]
 *     responses:
 *       200:
 *         description: Lấy danh sách sản phẩm thành công
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
 *                       name:
 *                         type: string
 *                         example: iPhone 15
 *                       price:
 *                         type: number
 *                         example: 25000000
 *       500:
 *         description: Lỗi server
 */
productRoute.get('/',productController.products);
/**
 * @swagger
 * /products/search:
 *   get:
 *     summary: Tìm kiếm sản phẩm theo tên
 *     tags: [Products]
 *     parameters:
 *       - in: query
 *         name: q
 *         required: true
 *         schema:
 *           type: string
 *         example: iphone
 *         description: Từ khóa tìm kiếm sản phẩm
 *     responses:
 *       200:
 *         description: Tìm kiếm thành công
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
 *                   example: 2
 *                 product:
 *                   type: array
 *                   items:
 *                     type: object
 *       400:
 *         description: Không nhập từ khóa tìm kiếm
 *       404:
 *         description: Sản phẩm không tồn tại
 *       500:
 *         description: Lỗi server
 */
productRoute.get('/search',productController.searchProduct);
/**
 * @swagger
 * /products/{id}:
 *   get:
 *     summary: Lấy chi tiết sản phẩm theo ID
 *     tags: [Products]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *     responses:
 *       200:
 *         description: Lấy chi tiết sản phẩm thành công
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
 *                   example: Lấy chi tiết sản phẩm thành công
 *                 product:
 *                   type: object
 *       400:
 *         description: ID sản phẩm không hợp lệ
 *       404:
 *         description: Sản phẩm không tồn tại
 *       500:
 *         description: Lỗi server
 */
productRoute.get('/:id', productController.detailProduct);

export default productRoute;