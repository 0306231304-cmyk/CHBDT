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

    static async addUsedCount(code){
        try{
            const [result] = await execute(`
                UPDATE coupons SET coupons.used_count = coupons.used_count + 1 WHERE coupons.code = ?
            `,[code]);

            if(!result.affectedRows > 0)
                throw new Error('Lỗi thêm Used_Count(addUsedCount)');
        }
        catch(error){
            throw new Error('Lỗi thêm Used_Count(addUsedCount): ' + error.message);
        }
    }

    static async getAllCoupon(){
        try{
            const [coupons] = await execute('SELECT * FROM coupons WHERE is_active = 1');
            if(coupons.length === 0) return[];
            return coupons;
        }
        catch(error){
            throw new Error('Lỗi lấy danh sách khuyến mãi: ' + error.message);
        }
    }

    static async getCouponByID(coupon_id){
        try{
            console.log("DEBUG(getCouponByID): " + coupon_id);
            const [coupon] = await execute("SELECT * FROM coupons WHERE id = ?",[coupon_id]);

            if(coupon.length === 0) return {};

            return coupon[0];
        }
        catch(error){
            throw new Error("Lỗi tìm (getCouponByID): " + error.message);
        }
    }
}