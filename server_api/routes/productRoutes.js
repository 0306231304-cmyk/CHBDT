import { Router } from "express";
import productController from "../controllers/productController.js";

const productRoute = Router();

productRoute.get('/products',productController.products);
productRoute.get('/search',productController.searchProduct);

export default productRoute;