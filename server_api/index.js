import "dotenv/config.js";
import express from 'express';
import bodyParser from "body-parser";
import cors from 'cors';
import userRoutes from "./routes/userRoutes.js";
import adminRoutes from "./routes/adminRoutes.js";
import productRoute from "./routes/productRoutes.js";
import cartRoutes from "./routes/cartRoutes.js";

const app = express();
app.use(bodyParser.json());
app.use(cors({ origin: '*' }));
//Routes
app.get('/',(req,res)=>{
    res.json({message: 'Server API running'});
});
app.use('/admin',adminRoutes);
app.use('/products',productRoute);
app.use('/cart', cartRoutes);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
app.use('/',userRoutes);
app.use((req,res,next)=>{
    res.status(404).json({message: 'Endpoint not found'});
});
//Custom error handle
app.use((err,req,res,next)=>{
    console.error(err.stack);
    if(res.headersSent) return next(err);

    if(process.env.NODE_ENV === 'production'){
        return res.status(500).json({message: 'Something went wrong!'});
    }
    else return res.status(500).json({
        message: err.message,
        code: err.code,
        url: req.originalUrl,
        body: req.body,
        stack: err.stack
    });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT,()=>{
    console.log(`Server running on port ${PORT}`);
});

export default app;