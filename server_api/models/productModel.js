import { execute } from "../config/db.js";

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
            const queryVariants = `SELECT * FROM product_variants WHERE product_id = ?`;
            const [variants] = await execute(queryVariants, [id]);

            // Gộp lại
            product.variants = variants; 
            return product;
        }catch(error){
            throw new Error("Lỗi lấy chi tiết sản phẩm (id): " + error.message);
        }
    }
    static async findProductByName(name){
        try{
            const [row] = await execute("SELECT * FROM products WHERE name LIKE ?",[`%${name}%`]);
            return row;
        }catch(error){
            throw new Error("Database query failed: " + error.message);
        }
    }
}