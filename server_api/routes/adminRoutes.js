import { Router } from "express";
const adminRoutes = Router();
import userController from "../controllers/userController.js";
import auth from "../middleware/auth.js";
import admin from "../middleware/admin.js";

const adminAuthRoutes = Router();
adminAuthRoutes.use(auth,admin);

//Auth
adminRoutes.post('/login', userController.adminLogin);
adminAuthRoutes.post('/logout', userController.logout);
adminAuthRoutes.get('/users',userController.getAllUsers);

adminRoutes.use('/',adminAuthRoutes);
export default adminRoutes;