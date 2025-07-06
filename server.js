/**
 * server.js
 *  เริ่มต้นเซิร์ฟเวอร์ Express และตั้งค่า Middleware พื้นฐาน
 */

require("dotenv").config(); // โหลดตัวแปรจาก .env

const express = require("express");
const morgan = require("morgan");
const cors = require("cors");
const bodyParser = require("body-parser");
const adRoutes = require("./routes/adRoutes");
const swaggerUi = require("swagger-ui-express");
const swaggerSpec = require("./swagger");

const db = require("./config/db"); // เชื่อมต่อ MySQL (pool)

// ทดสอบเชื่อมต่อ DB
db.getConnection()
  .then((connection) => {
    console.log("✅ Connected to MySQL database");
    connection.release(); // คืน connection ให้ pool
  })
  .catch((err) => {
    console.error("❌ Error connecting to MySQL:", err);
  });

const app = express();

/* ---------- Middleware พื้นฐาน ---------- */
app.use(morgan("dev")); // แสดง log request
app.use(cors()); // เปิด CORS ทุกโดเมน (ปรับให้เข้มขึ้นภายหลัง)
app.use(bodyParser.json()); // รับ JSON body
app.use(bodyParser.urlencoded({ extended: true })); // รับ form-urlencoded body

/* ---------- Static Files ---------- */
// เสิร์ฟไฟล์ static สำหรับ uploads
app.use('/uploads', express.static('public/uploads'));

/* ---------- Routes ---------- */
const authRoutes = require("./routes/authRoutes");
const vehicleRoutes = require("./routes/vehicleRoutes");
const bookingRoutes = require("./routes/bookingRoutes");
const equipRoutes = require("./routes/bookingEquipmentRoutes");
const equipmentRoutes = require("./routes/equipmentRoutes");
const approvalFlowRoutes = require("./routes/approvalFlowRoutes.js");
const approvalStepRoutes = require("./routes/approvalStepRoutes.js");
const roleRoutes = require("./routes/roleRoutes");
const permissionRoutes = require("./routes/permissionRoutes");
const rolePermissionRoutes = require("./routes/rolePermissionRoutes");
const organizationRoutes = require('./routes/organizationRoutes');
const userRoleRoutes      = require('./routes/userRoleRoutes');
const userAllowedOrgRoutes= require('./routes/userAllowedOrgRoutes');
const driverRoutes        = require('./routes/driverRoutes');
const userRoutes          = require('./routes/userRoutes');
const systemSettingsRoutes = require('./routes/systemSettingsRoutes');

app.use("/api/ad", adRoutes); // เส้นทาง AD
app.use("/api/auth", authRoutes); // เส้นทาง Auth ทั้งหมด
app.use("/api/vehicles", vehicleRoutes); // เส้นทาง Vehicles
app.use("/api/bookings", bookingRoutes); // เส้นทาง Bookings
app.use("/api/bookings/:id/equipments", equipRoutes); // เส้นทาง Booking Equipments
app.use("/api/equipments", equipmentRoutes); // เส้นทาง Equipments
app.use("/api/approval-flows", approvalFlowRoutes); // เส้นทาง Approval Flows
app.use("/api/approval-flows", approvalStepRoutes); // เส้นทาง Approval Steps
app.use("/api/roles", roleRoutes);
app.use("/api/permissions", permissionRoutes);
app.use("/api/role-permissions", rolePermissionRoutes);
app.use("/api/organizations", organizationRoutes); // เส้นทาง Organizations
app.use('/api/user-roles',      userRoleRoutes);
app.use('/api/user-allowed-orgs', userAllowedOrgRoutes);
app.use('/api/drivers',           driverRoutes); // เส้นทาง Drivers
app.use('/api/users',             userRoutes);   // เส้นทาง Users
app.use('/api/system',            systemSettingsRoutes); // เส้นทาง System Settings

/* ---------- ทดสอบเส้นทาง root ---------- */
app.get("/", async (req, res) => {
  // ตรวจสอบเชื่อม DB ได้หรือไม่
  const [rows] = await db.query("SELECT NOW() AS now");
  res.json({ message: "ระบบพร้อมทำงาน", dbTime: rows[0].now });
});

// Swagger
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

/* ---------- เริ่มต้นเซิร์ฟเวอร์ ---------- */
const PORT = process.env.PORT || 3000;
app.listen(PORT, () =>
  console.log(`🚀 Server รันที่ http://localhost:${PORT}`)
);
