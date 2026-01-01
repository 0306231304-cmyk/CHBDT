import { Router } from "express";
import productController from "../controllers/productController.js";

const productRoute = Router();

productRoute.get('/',productController.products);
productRoute.get('/search',productController.searchProduct);
productRoute.get('/:id', productController.detailProduct);

export default productRoute;