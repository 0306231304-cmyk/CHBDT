import couponModel from "../models/couponModel.js";

export default class couponController{
    static async getAllCoupon(req,res){
        try{
            const coupon = await couponModel.getAllCoupon();

            return res.status(200).json({
                succeeded: true,
                coupons: coupon
            });
        }
        catch (error){
            return res.status(500).json({
                succeeded: false,
                message: error.message
            });
        }
    }
}