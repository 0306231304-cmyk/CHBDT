import { execute } from "../config/db.js";
export default class userModel{
    //Get all users
    static async all(inculdeDeleted = false){
        try{
            const [rows] = inculdeDeleted?
            await execute("SELECT * FROM customers"):
            await execute("SELECT * FROM customers WHERE DeletedAt IS NULL");
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
            await execute("SELECT * FROM customers WHERE CustomerID = ? LIMIT 1",[id]):
            await execute("SELECT * FROM customers WHERE CustomerID = ? AND DeletedAt IS NULL LIMIT 1",[id]);
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
            await execute("SELECT * FROM customers WHERE Email = ? LIMIT 1",[Email]):
            await execute("SELECT * FROM customers WHERE Email = ? AND DeletedAt IS NULL LIMIT 1",[Email]);
            return rows[0]??null;
        }
        catch (error){
            throw new Error("Database query failed: " + error.message);
        }
    }
    static async create({Fullname = '', hashedPassword,Email, Address = '', PhoneNumber = '', is_admin = false}){
        try{
            const [result] = await execute('INSERT INTO `customers`(`FullName`, `PhoneNumber`, `Email`, `Address`, `is_admin`, `Password`) VALUES (?,?,?,?,?,?)',
                [Fullname,PhoneNumber,Email,Address,is_admin?1:0,hashedPassword]
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