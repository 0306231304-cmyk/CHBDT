import userModel from "../models/userModel.js";
import jsonwebtoken from 'jsonwebtoken';
const {verify} = jsonwebtoken;
const JWT_SECRET = process.env.JWT_SECRET;

export default async function auth(req,res,next) {
    const authHeader = req.headers.authorization;

    if(!authHeader || !authHeader.startsWith('Bearer ')){
        return res.status(401).json({message: 'Authorization required'});
    }
    const token = authHeader.split(' ')[1];

    if(await userModel.isTokenRevoked(token)){
        return res.status(401).json({message: 'Invalid or expired token'});
    }

    const {id} = verify(token, JWT_SECRET);
    if(!id)return res.status(401).json({message: 'Invalid or expired token'});
    const user = await userModel.findById(id);
    if(!user) return res.status(401).json({message: 'User not found'});

    req.userid = id;
    req.username = user.username;
    req.is_admin = user.is_admin;
    req.token = token;
    next();
};