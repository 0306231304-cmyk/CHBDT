import { Router } from "express";
import cartController from "../controllers/cartController.js";
import auth from "../middleware/auth.js";

const cartRoutes = Router();

cartRoutes.use(auth); 

cartRoutes.get('/', cartController.viewCart);
cartRoutes.post('/add', cartController.addToCart);
cartRoutes.put('/update', cartController.update);
cartRoutes.delete('/remove', cartController.remove);

export default cartRoutes;