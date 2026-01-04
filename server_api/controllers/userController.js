import {hash, compare} from 'bcrypt';
import jwt from 'jsonwebtoken';
import userModel from '../models/userModel.js';
import cartModel from '../models/cartModel.js';

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || "1h";
const PASSWORD_HASH_ROUNDS = parseInt(process.env.PASSWORD_HASH_ROUNDS) || 10;

export default class userController{
    static async generateToken(user){
        return jwt.sign(
            {id: user.id},
            JWT_SECRET,
            {expiresIn: JWT_EXPIRES_IN}
        );
    }
    static async login(req,res){
        const {email , password} = req.body;
        if(!email || !password) return res.status(400).json({succeeded: false, message: "Thiếu Email hoặc Mật khẩu"});

        const user = await userModel.findByUsername(email);
        console.log(user);
        if(!user) return res.status(401).json({succeeded: false, message: 'Không tìm thấy Email'});
        const isMatch = await compare(password, user.password);
        if(!isMatch) return res.status(401).json({succeeded: false, message: "Sai mật khẩu"});
        const token = await userController.generateToken(user);
        return res.status(200).json({succeeded: true, token: token})
    }

    static validatePassword(password){
        const passwordRules = {
            minlength: 8,
            maxLength: 100,
            requireUppercase: true,
            requireLowercase: true,
            requireNumber: true,
            requireSpecial: true
        };
        if(password.length < passwordRules.minlength || password.length > passwordRules.maxLength) return false;
        if(passwordRules.requireUppercase && !/[A-Z]/.test(password))return false;
        if(passwordRules.requireLowercase && !/[a-z]/.test(password))return false;
        if(passwordRules.requireNumber && !/[0-9]/.test(password)) return false;
        if(passwordRules.requireSpecial && !/[!@#$%^&*(),.?":{}|<>]/.test(password)) return false;
        return true;
    }
    static async register(req, res) {
        const { email, password, fullName, phoneNumber, address } = req.body;

        if (!email || !password || !fullName || !phoneNumber || !address) {
            return res.status(400).json({
                succeeded: false, 
                message: 'Không được bỏ trống các trường'
            });
        }

        const existingUser = await userModel.findByUsername(email);
        if (existingUser) {
            return res.status(409).json({
                succeeded: false, 
                message: 'Email đã tồn tại'
            });
        }

        if (!userController.validatePassword(password)) {
            return res.status(400).json({
                succeeded: false, 
                message: 'Mật khẩu yếu: 8-100 ký tự, phải bao gồm A-Z, a-z, 0-9, ký tự đặc biệt'
            });
        }

        const hashedPassword = await hash(password, PASSWORD_HASH_ROUNDS);

        const newId = await userModel.create({
            Fullname: fullName,
            Email: email, 
            hashedPassword: hashedPassword,
            Address: address,
            PhoneNumber: phoneNumber
        });

        if (!newId) throw new Error('User creation failed');
        await cartModel.createCartForUser(newId);
        return res.status(201).json({
            succeeded: true, 
            user: { id: newId, email }
        });
    }

    static async logout(req,res){
        const token = req.token;
        if(!token) return res.status(400).json({succeeded: false,message: 'No token provided'});
        const decoded = jwt.decode(token);
        const exp = decoded && decoded.exp ? new Date(decoded.exp * 1000): null;
        if(!exp) return res.status(400).json({succeeded: false,message: 'Invalid token'});
        const result = await userModel.revokeToken(token,exp);
        if(!result) throw new Error('Token revocation failed');
        return res.status(200).json({succeeded: true, message: 'Logged out'})
    }

    static async profile(req,res){
        const id = req.userid;
        if(!id) return res.status(401).json({succeeded: false ,message: "Unauthorized"});
        const user = await userModel.findById(id);
        if(!user) return res.status(404).json({succeeded: false, message: "User not found"});
        return res.status(200).json({succeeded: true, user: {...user,password: ''}});
    }

    static async adminLogin(req,res){
        const { email , password} = req.body;

        if(!email || !password) return res.status(400).json({succeeded: false, message: "Thiếu Email hoặc Mật khẩu"});

        const user = await userModel.findByUsername(email);
        console.log(user);
        if(!user) return res.status(401).json({succeeded: false, message: 'Không tìm thấy Email'});
        if(user.is_admin !== 1) return res.status(401).json({succeeded: false, message: 'Không phải admin'});
        const isMatch = await compare(password, user.password);
        if(!isMatch) return res.status(401).json({succeeded: false, message: "Sai mật khẩu"});
        const token = await userController.generateToken(user);
        return res.status(200).json({succeeded: true, token: token})
    }
    static async getAllUsers(req,res){
        try{
            const users = await userModel.all();

            const safeUsers = users.map(user=> {const {password, ... rest} = user; return rest});

            return res.status(200).json({
                succeeded: true,
                message: "Lấy danh sách thành công",
                data: safeUsers
            });
        }catch(error){
            return res.status(500).json({
                succeeded: false,
                message: error.message
            });
        }
    }
    
    static async updateUser(req,res){
        try{
            const id = req.userid;

            const {fullName,phoneNumber,address} = req.body;
            console.log("DEBUG:",id,fullName,phoneNumber,address);
            if(!fullName || !phoneNumber || !address) return res.status(400).json({succeeded: false, message: "Thiếu thông tin"});
            const update = await userModel.updateUser(id,fullName,phoneNumber,address);
            if(!update) return res.status(404).json({succeeded: false, message:"Không thể thay đổi thông tin người dùng"});
            return res.status(200).json({succeeded: true,message: "Đổi thông tin thành công"});
        }
        catch(error){
            return res.status(500).json({
                succeeded: false,
                message: error.message
            });
        }

    }
}