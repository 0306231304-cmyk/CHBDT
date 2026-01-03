import swaggerJSDoc from 'swagger-jsdoc';

const options = {
  definition: {
    openapi: '3.0.0', // Chuẩn OpenAPI
    info: {
      title: 'API Tài Liệu Bán Hàng',
      version: '1.0.0',
      description: 'Mô tả các API của dự án',
    },
    servers: [
      {
        url: 'http://localhost:3001', // Đường dẫn server
        description: 'Server Local',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
  },
  // Quan trọng: Chỉ định nơi chứa file code cần quét tài liệu
  apis: ['./routes/*.js'], 
};

const swaggerSpec = swaggerJSDoc(options);

export default swaggerSpec;