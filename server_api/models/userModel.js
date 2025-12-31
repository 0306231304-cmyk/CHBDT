import { execute } from "../config/db.js";
export default class userModel{
    //Get all users
    static async all(inculdeDeleted = false){
        try{
            const [rows] = inculdeDeleted?
            await execute("SELECT * FROM users"):
            await execute("SELECT * FROM users WHERE deleted_at IS NULL");
            return rows[0]??null;
        }
        catch (error){
            throw new Error("Database query failed: " + error.message);
        }
    }
    //Find user by ID
    static async findById(id,inculdeDeleted= false){
        try{
            const [rows] = inculdeDeleted?
            await execute("SELECT * FROM users WHERE id = ? LIMIT 1",[id]):
            await execute("SELECT * FROM users WHERE id = ? AND deleted_at IS NULL LIMIT 1",[id]);
            return rows[0]??null;
        }
        catch (error){
            throw new Error("Database query failed: " + error.message);
        }
    }
    //Find user by username
    static async findByUsername(Email, inculdeDeleted = false){
        try{
            const [rows] = inculdeDeleted?
            await execute("SELECT * FROM users WHERE email = ? LIMIT 1",[Email]):
            await execute("SELECT * FROM users WHERE email = ? AND deleted_at IS NULL LIMIT 1",[Email]);
            return rows[0]??null;
        }
        catch (error){
            throw new Error("Database query failed: " + error.message);
        }
    }
    static async create({Fullname = '', hashedPassword,Email, Address = '', PhoneNumber = '', is_admin = false}){
        try{
            const [result] = await execute('INSERT INTO `users`(`fullname`, `email`, `password`, `phone_number`, `address`, `is_admin`) VALUES (?,?,?,?,?,?)',
                [Fullname,Email,hashedPassword,PhoneNumber,Address,is_admin?1:0]
            );
            return result.affectedRows > 0 ? result.insertId : null;
        }catch(error){
            throw new Error("Database query failed: " + error.message);
        }
    }
    static async revokeToken(token, expiresAt){
        try{
            const [result] = await execute('INSERT INTO revoked_tokens (token, expires_at) VALUES(?,?)',[token,expiresAt]);
            return result.affectedRows > 0;
        }
        catch(error){
            throw new Error("Database query failed: " + error.message);
        }
    }
    static async isTokenRevoked(token){
        try{
            const [rows] = await execute('SELECT id FROM revoked_tokens WHERE token = ? LIMIT 1',[token]);
            return rows.length > 0;
        }catch(error){
            throw new Error("Database query failed: " + error.message);
        }
    }
}