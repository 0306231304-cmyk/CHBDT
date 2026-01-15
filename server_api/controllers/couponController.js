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

    static async getCouponByID(req,res){
        try{
            const {coupon_id} = req.params;

            if(!coupon_id) return res.status(400).json({
                succeeded: false,
                message: "Thiếu mã khuyến mãi"
            });

            const coupon = await couponModel.getCouponByID(coupon_id);

            return res.status(200).json({
                succeeded: true,
                coupon: coupon
            });
        }
        catch(error){
            return res.status(500).json({
                succeeded: false,
                message: error.message
            });
        }
    }
}