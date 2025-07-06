// routes/systemSettingsRoutes.js
// กำหนด API Routes สำหรับ System Settings

const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const router = express.Router();

const {
  getSettings,
  getSetting,
  updateSettings,
  updateSetting,
  uploadLogo,
  deleteLogo
} = require('../controllers/systemSettingsController');

const authMiddleware = require('../middleware/authMiddleware');

// สร้างโฟลเดอร์สำหรับเก็บไฟล์ถ้ายังไม่มี
const uploadDir = path.join(process.cwd(), 'public', 'uploads', 'system');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// ตั้งค่า multer สำหรับ upload ไฟล์
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    // สร้างชื่อไฟล์ใหม่เพื่อป้องกันชื่อซ้ำ
    const timestamp = Date.now();
    const randomStr = Math.random().toString(36).substring(2, 15);
    const ext = path.extname(file.originalname);
    const fileName = `logo-${timestamp}-${randomStr}${ext}`;
    cb(null, fileName);
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 2 * 1024 * 1024, // 2MB
    files: 1
  },
  fileFilter: function (req, file, cb) {
    // ตรวจสอบประเภทไฟล์
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('รองรับเฉพาะไฟล์รูปภาพ (JPG, PNG, GIF, WebP)'), false);
    }
  }
});

/**
 * @swagger
 * /api/system/settings:
 *   get:
 *     tags: [System Settings]
 *     summary: ดึงการตั้งค่าระบบ
 *     description: ดึงการตั้งค่าระบบทั้งหมด (public settings ถ้าไม่ได้ล็อกอิน)
 *     responses:
 *       200:
 *         description: ดึงการตั้งค่าสำเร็จ
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                 message:
 *                   type: string
 */
router.get('/settings', getSettings);

/**
 * @swagger
 * /api/system/settings/{key}:
 *   get:
 *     tags: [System Settings]
 *     summary: ดึงการตั้งค่าเฉพาะ key
 *     parameters:
 *       - in: path
 *         name: key
 *         required: true
 *         schema:
 *           type: string
 *         description: key ของการตั้งค่า
 *     responses:
 *       200:
 *         description: ดึงการตั้งค่าสำเร็จ
 *       404:
 *         description: ไม่พบการตั้งค่า
 */
router.get('/settings/:key', getSetting);

/**
 * @swagger
 * /api/system/settings:
 *   post:
 *     tags: [System Settings]
 *     summary: อัพเดตการตั้งค่าระบบ
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               system_name:
 *                 type: string
 *                 example: "ระบบจองรถยนต์ใหม่"
 *               system_tagline:
 *                 type: string
 *                 example: "จัดการการจองอย่างมืออาชีพ"
 *               system_primary_color:
 *                 type: string
 *                 example: "#3b82f6"
 *     responses:
 *       200:
 *         description: อัพเดตการตั้งค่าสำเร็จ
 *       401:
 *         description: ไม่ได้รับอนุญาต
 */
router.post('/settings', authMiddleware, updateSettings);

/**
 * @swagger
 * /api/system/settings/{key}:
 *   put:
 *     tags: [System Settings]
 *     summary: อัพเดตการตั้งค่าเฉพาะ key
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: key
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               value:
 *                 oneOf:
 *                   - type: string
 *                   - type: number
 *                   - type: boolean
 *                   - type: object
 *     responses:
 *       200:
 *         description: อัพเดตการตั้งค่าสำเร็จ
 */
router.put('/settings/:key', authMiddleware, updateSetting);

/**
 * @swagger
 * /api/system/upload-logo:
 *   post:
 *     tags: [System Settings]
 *     summary: อัพโหลดโลโก้ระบบ
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               logo:
 *                 type: string
 *                 format: binary
 *                 description: ไฟล์โลโก้ (JPG, PNG, GIF, WebP ไม่เกิน 2MB)
 *     responses:
 *       200:
 *         description: อัพโหลดโลโก้สำเร็จ
 *       400:
 *         description: ไฟล์ไม่ถูกต้อง
 *       401:
 *         description: ไม่ได้รับอนุญาต
 */
router.post('/upload-logo', authMiddleware, upload.single('logo'), uploadLogo);

/**
 * @swagger
 * /api/system/logo:
 *   delete:
 *     tags: [System Settings]
 *     summary: ลบโลโก้ระบบ
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: ลบโลโก้สำเร็จ
 *       404:
 *         description: ไม่พบโลโก้
 */
router.delete('/logo', authMiddleware, deleteLogo);

// Middleware สำหรับจัดการ error ของ multer
router.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        success: false,
        message: 'ขนาดไฟล์ใหญ่เกินไป (ขีดจำกัด 2MB)'
      });
    }
    if (error.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({
        success: false,
        message: 'สามารถอัพโหลดได้ทีละ 1 ไฟล์เท่านั้น'
      });
    }
  }
  
  if (error.message.includes('รองรับเฉพาะไฟล์รูปภาพ')) {
    return res.status(400).json({
      success: false,
      message: error.message
    });
  }
  
  next(error);
});

module.exports = router;