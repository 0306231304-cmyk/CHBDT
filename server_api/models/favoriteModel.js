import {execute} from '../config/db.js';


export default class favoriteModel{
    static async getFavoriteByUserID(user_id){
        try{
            const [favorites] = await execute('SELECT * FROM favorites WHERE user_id = ?',[user_id]);
            if(favorites.length === 0) return [];

            return favorites;
        }
        catch(error){
            throw new Error('Lỗi lấy sản phẩm ưa thích theo id người dùng (getFavoriteByUserID): ' + error.message);
        }
    }

    static async addFavorite(user_id, product_id){
        try{
            const [product] = await execute('SELECT * FROM products WHERE id = ?',[product_id]);
            if(product === 0){
                throw new Error('Không tìm thấy sản phẩm này');
            }

            const [result] = await execute('INSERT INTO `favorites`(`user_id`, `product_id`, `created_at`) VALUES(?,?,NOW())',[user_id,product_id]);

            return result.affectedRows > 0? result.insertId: null;
        }
        catch(error){
            throw new Error('Lỗi thêm sản phẩm yêu thích (addFavorite): ' + error.message);
        }
    }

    static async removeFavorite(favorite_id){
        try{
            const [favorite] = await execute('SELECT * FROM favorites WHERE id = ?',[favorite_id]);

            if(favorite === 0){
                throw new Error('Không tìm thấy sản phẩm ưa thích này');
            }

            const [result] = await execute('DELETE FROM favorites WHERE id = ?', [favorite_id]);

            return result.affectedRows > 0? result.insertId: null;
        }
        catch(error){
            
        }
    }
}