// swagger.js
const swaggerJSDoc = require("swagger-jsdoc");

const options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Car Booking System API",
      version: "1.0.0",
      description: "เอกสาร Swagger API สำหรับระบบจองรถยนต์",
    },
    servers: [
      {
        url: "http://localhost:4000/api", // ✅ แก้ตาม base URL ของคุณ
        description: "Local Server",
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
        },
      },
    },
    security: [
      {
        bearerAuth: [],
      },
    ],
  },
  apis: ["./routes/*.js"], // ✅ เส้นทางไฟล์ที่ใส่คอมเมนต์ Swagger
};

const swaggerSpec = swaggerJSDoc(options);
module.exports = swaggerSpec;
