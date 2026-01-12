import { execute } from "../config/db.js";
import baseUrl from '../baseUrl.js';


export default class productModel{
    static async allproduct(){
        try{
            const [row] = await execute("SELECT * FROM products");
            return row;
        }catch(error){
            throw new Error("Database query failed: " + error.message);
        }
    }
    static async findProductById(id){
        try{
            const queryProduct = `
                SELECT p.*, b.name as brand_name 
                FROM products p
                LEFT JOIN brands b ON p.brand_id = b.id
                WHERE p.id = ?
            `;
            const [productRows] = await execute(queryProduct, [id]);
            
            if (productRows.length === 0) return null;
            const product = productRows[0];

            // Bước 2: Lấy các phiên bản (Màu sắc, bộ nhớ, giá)
            const queryVariants = `SELECT *, CONCAT(?, "/uploads/", pv.image_url) as image FROM product_variants WHERE product_id = ?`;
            const [variants] = await execute(queryVariants, [baseUrl, id]);

            // Gộp lại
            product.variants = variants; 
            return product;
        }catch(error){
            throw new Error("Lỗi lấy chi tiết sản phẩm (id): " + error.message);
        }
    }
    static async findProductByName(keyword) {
        try {
            // 1. Tách từ khóa thành mảng các từ (ví dụ: "Samsung s24" -> ["Samsung", "s24"])
            const words = keyword.trim().split(/\s+/);

            // 2. Khởi tạo câu SQL cơ bản
            // Lưu ý: WHERE 1=1 là mẹo để dễ dàng nối chuỗi AND phía sau
            let sql = `
                SELECT 
                    p.id, 
                    p.name, 
                    pv.price, 
                    p.screen_size, 
                    p.camera,
                    CONCAT(?,'/uploads/', pv.image_url) as image,
                    pv.ram,
                    pv.color
                FROM products p
                JOIN product_variants pv ON p.id = pv.product_id
                WHERE 1=1
            `;

            const params = [baseUrl]; // Tham số đầu tiên cho CONCAT

            // 3. Vòng lặp: Với mỗi từ khóa, thêm một điều kiện AND ... LIKE
            words.forEach(word => {
                sql += " AND p.name LIKE ?";
                params.push(`%${word}%`); // Thêm % vào trước và sau mỗi từ
            });

            // Nếu muốn Group By để tránh trùng lặp sản phẩm (nếu 1 sp có nhiều biến thể)
            sql += " GROUP BY p.id";

            // 4. Thực thi
            const [rows] = await execute(sql, params);
            return rows;

        } catch (error) {
            throw new Error("Lỗi tìm kiếm sản phẩm: " + error.message);
        }
    }

    static async findProductVariantById(product_variant_id){
        try{
            const [product_variants] = await execute(`
                    SELECT *, CONCAT(?, "/uploads/", pv.image_url) as image FROM product_variants pv WHERE p.id = ?
                `,[baseUrl,product_variant_id]);

            if(product_variants.length === 0) {
                throw new Error('Không tìm thấy sản phẩm này');
            }

            return product_variants[0] ?? null;
        }
        catch(error){
            throw new Error('Lỗi Lấy biến thể sản phẩm bằng id: ' + error.message)
        }
    }

    static async findProductVariantByProductID(product_id){
        try{
            const [rows] = await execute('SELECT p.brand_id, p.name, p.description, p.screen_size, p.cpu, p.camera, p.battery, pv.product_id, pv.color, pv.ram, pv.storage, pv.price, pv.stock_quantity, CONCAT(?, "/uploads/", pv.image_url) as image FROM products p, product_variants pv WHERE p.id = pv.product_id AND p.id = ?',[baseUrl,product_id]);
            if(rows.length === 0) throw new Error('Không tìm thấy product_id');

            return rows;
        }
        catch(error){
            throw new Error('Lỗi lấy biến thể sản phẩm bằng id sản phẩm: ' + error.message);
        }
    }

    static async getProductVariants(){
        try{
            // Sửa lại: CONCAT(?, '/uploads/', pv.image_url)
            const [product_variant] = await execute(
                'SELECT pv.id, p.brand_id, p.name, p.screen_size, p.camera, pv.storage, pv.product_id, pv.color, pv.ram, pv.price, pv.stock_quantity, CONCAT(?, "/uploads/", pv.image_url) as image FROM products p, product_variants pv WHERE p.id = pv.product_id', 
                [baseUrl] // Biến này sẽ điền vào dấu ? đầu tiên
            );
            if(product_variant.length === 0) return [];
            return product_variant;
        }catch(error){
            throw new Error("Lỗi lấy danh sách biến thể sản phẩm: " + error.message);
        }
    }
}