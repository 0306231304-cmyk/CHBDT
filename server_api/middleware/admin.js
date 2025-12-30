export default function admin(req,res,next){
    if(!req.userid || !req.is_admin){
        return res.status(403).json({message: "Admin privileges required"});
    }
    next();
};