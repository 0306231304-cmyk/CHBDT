import productModel from '../models/productModel.js';

export default class productController{
    static async products(req,res){
        try{
            const products = await productModel.allproduct();

            return res.status(200).json({
                succeeded: true,
                message: "Lấy danh sách sản phẩm thành công",
                products: products
            });
        }catch(error){
            return res.status(500).json({
                succeeded: true,
                message: error.message
            })
        }
    }
    
    static async searchProduct(req,res){
        try{
            const {q} = req.query;
            if (!q || q.trim() === '') {
                return res.status(400).json({ 
                    succeeded: false, 
                    message: "Vui lòng nhập từ khóa tìm kiếm" 
                });
            }
            const product = await productModel.findProductByName(q);
            if(!product) return res.status(404).json({succeeded: false, message: "Sản phẩm không tồn tại"});
            return res.status(200).json({
                succeeded: true,
                count: product.length,
                product: product
            });
        }catch(error){
            return res.status(500).json({ 
                succeeded: false, 
                message: error.message 
            });
        }
    }

    static async detailProduct(req,res){
        try{
            const {id} = req.params;
            console.log("id: ",id);
            if(!id) return res.status(400).json({succeeded: false,message: "ID sản phẩm không được để trống"});
            const product = await productModel.findProductById(id);
            if(!product) return res.status(404).json({succeeded: false,message: "ID sản phẩm không tồn tại"});
            return res.status(200).json({succeeded: true,message: "Lấy chi tiết sản phẩm thành công", product: product});
        }
        catch(error){
            return res.status(500).json({succeeded: false,message: error.message});
        }
    }
}