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
            const [row] = await execute("SELECT * FROM products WHERE id = ? LIMIT 1",[id]);
            return row[0] ?? null;
        }catch(error){
            throw new Error("Database query failed: " + error.message);
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