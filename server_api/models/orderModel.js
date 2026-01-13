import { beginTransaction, commitTransaction, rollbackTransaction, execute } from "../config/db.js";
import couponModel from "./couponModel.js";

export default class orderModel{
    // Helper: Lấy phí ship từ DB
    static async getShippingFee(city) {
        // Tìm chính xác hoặc tương đối
        const [rows] = await execute('SELECT shipping_fee FROM shipping_rates WHERE province LIKE ?', [`%${city}%`]);
        if (rows.length > 0) return parseFloat(rows[0].shipping_fee);
        
        // Nếu không tìm thấy, lấy giá mặc định (Khác)
        const [defaultRow] = await execute("SELECT shipping_fee FROM shipping_rates WHERE province = 'Khác'");
        return defaultRow.length > 0 ? parseFloat(defaultRow[0].shipping_fee) : 30000;
    }

    /*static async checkout(userId, shippingData, couponCode, payment_method) {
        const conn = await beginTransaction(); // Bắt đầu Transaction

        try {
            // =================================================
            // BƯỚC 1: Lấy dữ liệu GIỎ HÀNG từ bảng CARTS
            // =================================================
            // Sửa lỗi: Lấy đúng cột stock_quantity
            const [cartItems] = await conn.query(
                `SELECT c.product_variant_id, c.quantity, pv.price, pv.stock_quantity 
                 FROM carts c
                 JOIN product_variants pv ON c.product_variant_id = pv.id
                 WHERE c.user_id = ? FOR UPDATE`, // FOR UPDATE để khóa dòng lại, tránh người khác mua tranh
                [userId]
            );

            if (cartItems.length === 0) throw new Error("Giỏ hàng trống!");

            // =================================================
            // BƯỚC 2: Tính tổng tiền hàng & Check tồn kho
            // =================================================
            let provisionalTotal = 0; 

            for (const item of cartItems) {
                if (item.quantity > item.stock_quantity) {
                    throw new Error(`Sản phẩm (ID: ${item.product_variant_id}) không đủ hàng (chỉ còn ${item.stock_quantity})`);
                }
                provisionalTotal += parseFloat(item.price) * item.quantity;
            }

            // =================================================
            // BƯỚC 3: Tính phí Ship & Coupon (Tính lại từ đầu để bảo mật)
            // =================================================
            
            // 3.1 Phí Ship
            const shippingFee = await this.getShippingFee(shippingData.city);

            // 3.2 Coupon
            let discountAmount = 0;
            let couponId = null;

            if (couponCode) {
                const coupon = await couponModel.getCouponByCode(couponCode);
                
                // Validate kỹ các điều kiện coupon
                if (!coupon) throw new Error("Mã giảm giá không tồn tại");
                if (!coupon.is_active) throw new Error("Mã giảm giá đang bị khóa");
                if (coupon.usage_limit > 0 && coupon.used_count >= coupon.usage_limit) throw new Error("Mã giảm giá đã hết lượt dùng");
                
                const now = new Date();
                if (coupon.end_date && new Date(coupon.end_date) < now) throw new Error("Mã giảm giá đã hết hạn");
                if (provisionalTotal < parseFloat(coupon.min_order_value)) throw new Error(`Đơn hàng phải từ ${coupon.min_order_value} mới dùng được mã này`);

                // Tính tiền giảm
                if (coupon.discount_type === 'fixed') {
                    discountAmount = parseFloat(coupon.discount_value);
                } else {
                    discountAmount = provisionalTotal * (parseFloat(coupon.discount_value) / 100);
                    // Check trần giảm giá (max_discount_amount)
                    if (coupon.max_discount_amount && discountAmount > parseFloat(coupon.max_discount_amount)) {
                        discountAmount = parseFloat(coupon.max_discount_amount);
                    }
                }

                await conn.query(`
                UPDATE coupons SET coupons.used_count = coupons.used_count + 1 WHERE coupons.code = ?
                `,[couponCode]);

                couponId = coupon.id;
            }

            // 3.3 Tổng cuối
            let finalTotal = provisionalTotal + shippingFee - discountAmount;
            if (finalTotal < 0) finalTotal = 0;

            // =================================================
            // BƯỚC 4: Insert vào DB
            // =================================================
            
            // 4.1 Tạo Order
            const [orderResult] = await conn.query(
                `INSERT INTO orders (user_id, full_name, phone_number, shipping_address, city, note, total_money, shipping_fee, coupon_id, status, created_at, PTTT) 
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', NOW()), ?`,
                [
                    userId, 
                    shippingData.fullName, 
                    shippingData.phone, 
                    shippingData.address, 
                    shippingData.city,
                    shippingData.note, 
                    finalTotal,
                    shippingFee,
                    couponId,
                    payment_method
                ]
            );
            const newOrderId = orderResult.insertId;

            // 4.2 Tạo Order Items & Trừ Kho
            for (const item of cartItems) {
                // Lưu chi tiết đơn
                await conn.query(
                    `INSERT INTO order_items (order_id, product_variant_id, quantity, price) VALUES (?, ?, ?, ?)`,
                    [newOrderId, item.product_variant_id, item.quantity, item.price]
                );

                // Trừ kho ngay lập tức
                await conn.query(
                    `UPDATE product_variants SET stock_quantity = stock_quantity - ? WHERE id = ?`,
                    [item.quantity, item.product_variant_id]
                );

                await conn.query(`
                    UPDATE products SET sold_count = sold_count + ? WHERE (
                    SELECT pv.product_id
                    FROM product_variants pv
                    WHERE pv.id = ?
                    )
                `,[item.quantity, item.product_variant_id]);
            }

            // 4.3 Tăng lượt dùng Coupon (nếu có)
            if (couponId) {
                await conn.query(`UPDATE coupons SET used_count = used_count + 1 WHERE id = ?`, [couponId]);
            }

            // 4.4 Xóa giỏ hàng (Sửa lỗi: Xóa theo userId)
            await conn.query("DELETE FROM carts WHERE user_id = ?", [userId]);

            // =================================================
            // HOÀN TẤT
            // =================================================
            await commitTransaction(conn);
            return newOrderId;

        } catch (error) {
            await rollbackTransaction(conn);
            throw error; 
        }
    }*/

        /**
     * @param {number} userId 
     * @param {object} shippingData {fullName, phone, address, city, note}
     * @param {string} couponCode 
     * @param {string} payment_method 
     * @param {Array} orderItems Danh sách sản phẩm [{product_variant_id: 1, quantity: 2}]
     * @param {boolean} is_buy_now true: Mua ngay (không xóa giỏ hàng), false: Thanh toán từ giỏ (xóa giỏ hàng)
     */
    static async checkout(userId, shippingData, couponCode, payment_method, orderItems, is_buy_now = false) {
        const conn = await beginTransaction(); // Bắt đầu Transaction

        try {
            // =================================================
            // BƯỚC 1: Lấy dữ liệu sản phẩm & Check giá, tồn kho thực tế từ DB
            // =================================================
            
            // --- [CODE CŨ] Lấy từ bảng Carts ---
            /*
            const [cartItems] = await conn.query(
                `SELECT c.product_variant_id, c.quantity, pv.price, pv.stock_quantity 
                 FROM carts c
                 JOIN product_variants pv ON c.product_variant_id = pv.id
                 WHERE c.user_id = ? FOR UPDATE`, 
                [userId]
            );
            if (cartItems.length === 0) throw new Error("Giỏ hàng trống!");
            */

            // --- [CODE MỚI] Xử lý mảng orderItems truyền vào ---
            if (!orderItems || orderItems.length === 0) throw new Error("Danh sách sản phẩm trống!");

            // Lấy danh sách ID để query DB
            const variantIds = orderItems.map(item => item.product_variant_id);
            
            // Query DB để lấy giá và tồn kho thực tế (Bảo mật: Không tin tưởng giá từ Frontend gửi lên)
            const [dbVariants] = await conn.query(
                `SELECT id, price, stock_quantity, product_id 
                 FROM product_variants 
                 WHERE id IN (?) FOR UPDATE`, 
                [variantIds]
            );

            if (dbVariants.length !== orderItems.length) {
                throw new Error("Một số sản phẩm không tồn tại hoặc đã bị xóa!");
            }

            // Map lại dữ liệu: Kết hợp số lượng khách mua (từ Frontend) + Giá/Kho (từ DB)
            const processItems = dbVariants.map(dbItem => {
                const requestedItem = orderItems.find(item => item.product_variant_id === dbItem.id);
                return {
                    product_variant_id: dbItem.id,
                    price: dbItem.price,           // Lấy giá từ DB
                    stock_quantity: dbItem.stock_quantity, // Lấy tồn kho từ DB
                    quantity: requestedItem.quantity // Lấy số lượng khách đặt
                };
            });

            // =================================================
            // BƯỚC 2: Tính tổng tiền hàng & Check tồn kho
            // =================================================
            let provisionalTotal = 0; 

            // Sửa vòng lặp dùng processItems thay vì cartItems
            for (const item of processItems) {
                if (item.quantity > item.stock_quantity) {
                    throw new Error(`Sản phẩm (ID: ${item.product_variant_id}) không đủ hàng (chỉ còn ${item.stock_quantity})`);
                }
                provisionalTotal += parseFloat(item.price) * item.quantity;
            }

            // =================================================
            // BƯỚC 3: Tính phí Ship & Coupon (GIỮ NGUYÊN)
            // =================================================
            
            // 3.1 Phí Ship
            const shippingFee = await this.getShippingFee(shippingData.city);

            // 3.2 Coupon
            let discountAmount = 0;
            let couponId = null;

            if (couponCode) {
                const coupon = await couponModel.getCouponByCode(couponCode);
                
                // Validate kỹ các điều kiện coupon
                if (!coupon) throw new Error("Mã giảm giá không tồn tại");
                if (!coupon.is_active) throw new Error("Mã giảm giá đang bị khóa");
                if (coupon.usage_limit > 0 && coupon.used_count >= coupon.usage_limit) throw new Error("Mã giảm giá đã hết lượt dùng");
                
                const now = new Date();
                if (coupon.end_date && new Date(coupon.end_date) < now) throw new Error("Mã giảm giá đã hết hạn");
                if (provisionalTotal < parseFloat(coupon.min_order_value)) throw new Error(`Đơn hàng phải từ ${coupon.min_order_value} mới dùng được mã này`);

                // Tính tiền giảm
                if (coupon.discount_type === 'fixed') {
                    discountAmount = parseFloat(coupon.discount_value);
                } else {
                    discountAmount = provisionalTotal * (parseFloat(coupon.discount_value) / 100);
                    // Check trần giảm giá (max_discount_amount)
                    if (coupon.max_discount_amount && discountAmount > parseFloat(coupon.max_discount_amount)) {
                        discountAmount = parseFloat(coupon.max_discount_amount);
                    }
                }

                await conn.query(`
                UPDATE coupons SET coupons.used_count = coupons.used_count + 1 WHERE coupons.code = ?
                `,[couponCode]);

                couponId = coupon.id;
            }

            // 3.3 Tổng cuối
            let finalTotal = provisionalTotal + shippingFee - discountAmount;
            if (finalTotal < 0) finalTotal = 0;

            // =================================================
            // BƯỚC 4: Insert vào DB
            // =================================================
            
            // 4.1 Tạo Order
            const [orderResult] = await conn.query(
                `INSERT INTO orders (user_id, full_name, phone_number, shipping_address, city, note, total_money, shipping_fee, coupon_id, status, created_at, PTTT) 
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', NOW(), ?)`,
                [
                    userId, 
                    shippingData.fullName, 
                    shippingData.phone, 
                    shippingData.address, 
                    shippingData.city,
                    shippingData.note, 
                    finalTotal,
                    shippingFee,
                    couponId,
                    payment_method
                ]
            );
            const newOrderId = orderResult.insertId;

            // 4.2 Tạo Order Items & Trừ Kho
            // Sửa vòng lặp dùng processItems
            for (const item of processItems) {
                // Lưu chi tiết đơn
                await conn.query(
                    `INSERT INTO order_items (order_id, product_variant_id, quantity, price) VALUES (?, ?, ?, ?)`,
                    [newOrderId, item.product_variant_id, item.quantity, item.price]
                );

                // Trừ kho ngay lập tức
                await conn.query(
                    `UPDATE product_variants SET stock_quantity = stock_quantity - ? WHERE id = ?`,
                    [item.quantity, item.product_variant_id]
                );

                await conn.query(`
                    UPDATE products SET sold_count = sold_count + ? WHERE (
                    SELECT pv.product_id
                    FROM product_variants pv
                    WHERE pv.id = ?
                    )
                `,[item.quantity, item.product_variant_id]);
            }

            // 4.3 Tăng lượt dùng Coupon (nếu có)
            if (couponId) {
                await conn.query(`UPDATE coupons SET used_count = used_count + 1 WHERE id = ?`, [couponId]);
            }

            // 4.4 Xóa giỏ hàng (LOGIC MỚI)
            // Chỉ xóa giỏ hàng nếu đơn hàng này được tạo từ Giỏ hàng (is_buy_now = false)
            if (!is_buy_now) {
                await conn.query("DELETE FROM carts WHERE user_id = ?", [userId]);
            } 
            // Nếu is_buy_now = true (Mua ngay) -> Không đụng gì đến giỏ hàng của khách

            // =================================================
            // HOÀN TẤT
            // =================================================
            await commitTransaction(conn);
            return newOrderId;

        } catch (error) {
            await rollbackTransaction(conn);
            throw error; 
        }
    }



    static async orderStatus(order_ID){
        try{
            const [result] = await execute('SELECT status FROM orders WHERE id = ? LIMIT 1',[order_ID]);
            return result[0] ?? null;
        }catch(error){
            throw new Error('Lỗi truy xuất trạn thái đơn hàng: '+ error.message);
        }
    }

    //Duyệt đơn hàng
    static async approveOrders(order_ID, status){
        try{
            const currentStatus = await this.orderStatus(order_ID);

            if(currentStatus === 'cancelled') return currentStatus;
            const [result] = await execute('UPDATE orders SET status = ? WHERE id = ?',[status,order_ID]);
            return result.affectedRows > 0? true: false;
        }
        catch(error){
            throw new Error('Lỗi duyệt đơn hàng: '+error.message);
        }
    }

    static async getOrderDetail(order_ID){
        try{
            const [orderDetail] = await execute(`
                SELECT order_items.id as order_itemsID, orders.*, order_items.product_variant_id, order_items.quantity, order_items.price 
                FROM orders, order_items 
                WHERE orders.id = order_items.order_id AND orders.id = ?`, [order_ID]);
            
            if(orderDetail.length === 0) return[];
            return orderDetail;
        }
        catch(error){
            throw new Error('Lỗi lấy chi tiết đơn hàng: ' + error.message);
        }
    }

    static async getListOrderByUserID(user_id){
        try{
            const [listOrder] = await execute(`
                SELECT *
                FROM orders
                WHERE user_id = ?    
            `, [user_id]);

            if(listOrder.length === 0) return [];
            return listOrder;
        }
        catch(error){
            throw new Error('Lỗi lấy danh sách đơn hàng theo ID người dùng: ' + error.message);
        }
    }

    static async getAllOrder(){
        try{
            const [orders] = await execute("SELECT * FROM orders");
            if(orders.length === 0) return [];

            return orders;
        }
        catch(error){
            throw new Error("Lỗi lấy danh sách hóa đơn: " + error.message);
        }
    }

    static async cancelOrder(order_id){
        const conn = await beginTransaction();
        try{
            const [order_items] = await conn.query('SELECT * FROM order_items WHERE order_items.order_id = ?',[order_id]);

            for(var item of order_items){
                await conn.query('UPDATE product_variants SET stock_quantity = stock_quantity + ? WHERE product_variants = ?',[item.quantity, item.product_variant_id]);
                await conn.query(`
                                    UPDATE products
                                    SET products.sold_count = products.sold_count - ?
                                    WHERE id IN (
                                        SELECT product_id
                                        FROM product_variants
                                        WHERE id = ?
                                    )`,[item.quantity, item.product_variant_id]
                                );
            }




            const [result] = await conn.query("UPDATE orders SET status = 'cancelled' WHERE id = 2");
        }
        catch(error){
            
        }
    }
}