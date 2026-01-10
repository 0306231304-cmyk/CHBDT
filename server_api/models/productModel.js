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

    static async findProductVariantById(product_variant_id){
        try{
            const [product_variants] = await execute(`
                    SELECT * FROM product_variants p WHERE p.id = ?
                `,[product_variant_id]);

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
            const [rows] = await execute('SELECT p.brand_id, p.name, p.description, p.screen_size, p.cpu, p.camera, p.battery, pv.product_id, pv.color, pv.ram, pv.storage, pv.price, pv.stock_quantity, pv.image_url FROM products p, product_variants pv WHERE p.id = pv.product_id AND p.id = ?',[product_id]);
            if(rows.length === 0) throw new Error('Không tìm thấy product_id');

            return rows;
        }
        catch(error){
            throw new Error('Lỗi lấy biến thể sản phẩm bằng id sản phẩm: ' + error.message);
        }
    }

    static async getProductVariants(){
        try{
            const [product_variant] = await execute('SELECT pv.id, p.brand_id, p.name, p.screen_size, p.camera, pv.storage, pv.product_id, pv.color, pv.ram, pv.price, pv.stock_quantity, pv.image_url FROM products p, product_variants pv WHERE p.id = pv.product_id');
            if(product_variant.length === 0) return [];
            return product_variant;
        }catch(error){
            throw new Error("Lỗi lấy danh sách biến thể sản phẩm: " + error.message);
        }
    }
}