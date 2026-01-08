import reviewsModel from "../models/reviewsModel.js";

export default class reviewsController{
    static async getReviewProduct(req,res){
        try{
            const {product_id} = req.params;
            if(!product_id) return res.status(400).json({succeeded: false, message: "Thiếu id sản phẩm"});
            const review = await reviewsModel.getReviewsByProductId(product_id);

            return res.status(200).json({
                succeeded: true,
                message: "Lấy đánh giá sản phẩm thành công",
                reviews: review
            });
        }
        catch(error){
            return res.status(500).json({
                succeeded: false,
                message: "Lỗi lấy đánh giá sản phẩm: " + error.message
            });
        }
    }

    static async addReview(req,res){
        try{
            const user_id = req.userid;
            const {product_id, order_id, rating, comment} = req.body;

            if(!user_id) return res.status(401).json({succeeded: false, message: "Chưa đăng nhập"});
            if(!product_id || !order_id || !rating || !comment) return res.status(400).json({succeeded: false, message: "Không được bỏ trống các trường"});

            const result = await reviewsModel.addReview({rating: rating, comment: comment}, product_id, order_id, user_id);

            return res.status(200).json({succeeded: true, message: "Thêm đánh giá thành công", id: result});
        }
        catch(error){
            return res.status(500).json({
                succeeded: false,
                message: "Lỗi thêm đánh giá: " + error.message
            });
        }
    }
}