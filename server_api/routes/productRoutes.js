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

export default productRoute;