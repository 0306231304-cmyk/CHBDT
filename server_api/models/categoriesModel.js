import { execute } from "../config/db.js";

export default class categoriesModel{
    static async getAllCategories(){
        try{
            const [categories] = await execute('SELECT * FROM brands');
            if(categories.length === 0) return [];

            return categories;
        }
        catch(error){
            throw new Error("Lỗi lấy brands: " + error.message);
        }
    }
}