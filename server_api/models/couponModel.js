import { execute } from "../config/db.js";

export default class couponModel{
    static async getCouponByCode(code){
        try{
            const [rows] = await execute('SELECT * FROM coupons WHERE code LIKE ? AND is_active = 1',[code]);
            if(rows.length === 0) return null;
            else{
                return rows[0];
            }
        }
        catch(error){
            throw new Error('Lỗi lấy coupon: ' + error.message);
        }
    }
    static async inActiveCoupon(code){
        try{
            const coupon = await this.getCouponByCode(code);
            if(coupon.is_active === 1){
               const [result] = await execute('UPDATE coupons SET is_active = 0 WHERE id = ?',[coupon.id]); 
            }else{
                return;
            }
        }
        catch(error){
            throw new Error('Lỗi inActive Coupon: '+error.message);
        }
    }
}