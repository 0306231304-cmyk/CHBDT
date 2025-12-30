import {hash, compare} from 'bcrypt';
import jwt from 'jsonwebtoken';
import userModel from '../models/userModel.js';

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || "1h";
const PASSWORD_HASH_ROUNDS = parseInt(process.env.PASSWORD_HASH_ROUNDS) || 10;

export default class userController{
    static async generateToken(user){
        return jwt.sign(
            {id: user.CustomerID},
            JWT_SECRET,
            {expiresIn: JWT_EXPIRES_IN}
        );
    }
    static async login(req,res){
        const {email , password} = req.body;

        if(!email || !password) return res.status(400).json({succeeded: false, message: "Username and password required"});

        const user = await userModel.findByUsername(email);
        if(!user) return res.status(401).json({succeeded: false, message: 'Invalid credentials'});
        const isMatch = await compare(password, user.Password);
        if(!isMatch) return res.status(401).json({succeeded: false, message: "Invalid credentials"});
        const token = await userController.generateToken(user);
        res.status(200).json({succeeded: true, token: token})
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
        // 1. Đổi username thành email để khớp với Postman
        const { email, password, fullName, phoneNumber, address } = req.body;

        // 2. Sửa logic kiểm tra null (Dùng || thay vì ?? như code cũ)
        if (!email || !password || !fullName || !phoneNumber || !address) {
            return res.status(400).json({
                succeeded: false, 
                message: 'Không được bỏ trống các trường'
            });
        }

        // 3. Truyền 'email' vào hàm tìm kiếm (thay vì username)
        const existingUser = await userModel.findByUsername(email);
        if (existingUser) {
            return res.status(409).json({
                succeeded: false, 
                message: 'Email already registered'
            });
        }

        // 4. Kiểm tra mật khẩu
        if (!userController.validatePassword(password)) {
            return res.status(400).json({
                succeeded: false, 
                message: 'Password weak: 8-100 chars, must include A-Z, a-z, 0-9, special char'
            });
        }

        const hashedPassword = await hash(password, PASSWORD_HASH_ROUNDS);

        // 5. QUAN TRỌNG: Map biến 'email' vào thuộc tính 'Email' của Model
        // userModel.create yêu cầu object có key là 'Email'
        const newId = await userModel.create({
            Fullname: fullName,
            Email: email, 
            hashedPassword: hashedPassword,
            Address: address,
            PhoneNumber: phoneNumber
        });

        if (!newId) throw new Error('User creation failed');
        
        // Trả về kết quả
        res.status(201).json({
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
        res.status(200).json({succeeded: true, message: 'Logged out'})
    }

    static async profile(req,res){
        const id = req.userid;
        if(!id) return res.status(401).json({succeeded: false ,message: "Unauthorized"});
        const user = await userModel.findById(id);
        if(!user) return res.status(404).json({succeeded: false, message: "User not found"});
        res.status(200).json({succeeded: true, user: {...user,password: ''}});
    }
    static async adminLogin(req,res){
        const { email , password} = req.body;

        if(!email || !password) return res.status(400).json({succeeded: false, message: "Username and password required"});

        const user = await userModel.findByUsername(email);
        if(!user || user.is_admin !== 1) return res.status(401).json({succeeded: false, message: 'Invalid credentials'});
        const isMatch = await compare(password, user.password);
        if(!isMatch) return res.status(401).json({succeeded: false, message: "Invalid credentials"});
        const token = await userController.generateToken(user);
        res.status(200).json({succeeded: true, token: token})
    }
}