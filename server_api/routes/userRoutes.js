import { Router } from "express";
const userRoutes = Router();
import userController from "../controllers/userController.js";
import auth from "../middleware/auth.js";

const authRoutes = Router();
authRoutes.use(auth);

//Auth
userRoutes.post('/register',userController.register);
userRoutes.post('/login',userController.login);
authRoutes.post('/logout',userController.logout);
authRoutes.get('/profile',userController.profile);
authRoutes.put('/updateprofile',userController.updateUser);

userRoutes.use('/',authRoutes);
export default userRoutes;
