import baseUrl from "../baseUrl.js";
import { execute } from "../config/db.js";

export default class categoriesModel{
    static async getAllCategories(){
        try{
            const [categories] = await execute('SELECT b.id, b.name, CONCAT(? ,"/uploads/",b.image_url) as image_url FROM brands b',[baseUrl]);
            if(categories.length === 0) return [];

            return categories;
        }
        catch(error){
            throw new Error("Lỗi lấy brands: " + error.message);
        }
    }
}