import { Router } from "express";
import shippingController from "../controllers/shippingController.js";

const shippingRoute = Router();

shippingRoute.get('/', shippingController.getShippingFeeByCity);

export default shippingRoute;