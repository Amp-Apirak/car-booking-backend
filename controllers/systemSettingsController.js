// controllers/systemSettingsController.js
// ควบคุมการทำงานเกี่ยวกับ System Settings

const path = require('path');
const fs = require('fs').promises;
const {
  getAllSettings,
  getSetting,
  updateSetting,
  updateMultipleSettings,
  saveFileInfo,
  getFileInfo,
  deleteFile
} = require('../models/systemSettingsModel');

/**
 * GET /api/system/settings
 * ดึงการตั้งค่าระบบทั้งหมด
 */
exports.getSettings = async (req, res) => {
  try {
    // ถ้าไม่ได้ล็อกอิน ให้ดึงเฉพาะ public settings
    const publicOnly = !req.user;
    
    const settings = await getAllSettings(publicOnly);
    
    res.json({
      success: true,
      data: settings,
      message: publicOnly ? 'ดึงการตั้งค่าสาธารณะสำเร็จ' : 'ดึงการตั้งค่าระบบสำเร็จ'
    });
  } catch (error) {
    console.error('Error fetching system settings:', error);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการดึงการตั้งค่าระบบ',
      error: error.message
    });
  }
};

/**
 * GET /api/system/settings/:key
 * ดึงการตั้งค่าเฉพาะ key
 */
exports.getSetting = async (req, res) => {
  try {
    const { key } = req.params;
    
    const value = await getSetting(key);
    
    if (value === null) {
      return res.status(404).json({
        success: false,
        message: `ไม่พบการตั้งค่า: ${key}`
      });
    }
    
    res.json({
      success: true,
      data: { [key]: value }
    });
  } catch (error) {
    console.error('Error fetching setting:', error);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการดึงการตั้งค่า',
      error: error.message
    });
  }
};

/**
 * POST /api/system/settings
 * อัพเดตการตั้งค่าระบบ (ต้องมีสิทธิ์ admin)
 */
exports.updateSettings = async (req, res) => {
  try {
    // ตรวจสอบสิทธิ์ admin (จะเพิ่ม middleware ภายหลัง)
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'กรุณาเข้าสู่ระบบ'
      });
    }
    
    const settings = req.body;
    const userId = req.user.user_id;
    
    // ตรวจสอบว่ามีการส่งข้อมูลมาหรือไม่
    if (!settings || Object.keys(settings).length === 0) {
      return res.status(400).json({
        success: false,
        message: 'กรุณาส่งข้อมูลการตั้งค่า'
      });
    }
    
    // อัพเดตการตั้งค่าหลายๆ ค่าพร้อมกัน
    await updateMultipleSettings(settings, userId);
    
    res.json({
      success: true,
      message: 'อัพเดตการตั้งค่าระบบสำเร็จ',
      data: settings
    });
    
  } catch (error) {
    console.error('Error updating system settings:', error);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการอัพเดตการตั้งค่าระบบ',
      error: error.message
    });
  }
};

/**
 * PUT /api/system/settings/:key
 * อัพเดตการตั้งค่าเฉพาะ key
 */
exports.updateSetting = async (req, res) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'กรุณาเข้าสู่ระบบ'
      });
    }
    
    const { key } = req.params;
    const { value } = req.body;
    const userId = req.user.user_id;
    
    if (value === undefined) {
      return res.status(400).json({
        success: false,
        message: 'กรุณาส่งค่า value'
      });
    }
    
    const success = await updateSetting(key, value, userId);
    
    if (success) {
      res.json({
        success: true,
        message: `อัพเดตการตั้งค่า ${key} สำเร็จ`,
        data: { [key]: value }
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'ไม่สามารถอัพเดตการตั้งค่าได้'
      });
    }
    
  } catch (error) {
    console.error('Error updating setting:', error);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการอัพเดตการตั้งค่า',
      error: error.message
    });
  }
};

/**
 * POST /api/system/upload-logo
 * อัพโหลดโลโก้ระบบ
 */
exports.uploadLogo = async (req, res) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'กรุณาเข้าสู่ระบบ'
      });
    }
    
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'กรุณาเลือกไฟล์โลโก้'
      });
    }
    
    const file = req.file;
    const userId = req.user.user_id;
    
    // ตรวจสอบประเภทไฟล์
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
    if (!allowedTypes.includes(file.mimetype)) {
      // ลบไฟล์ที่อัพโหลดแล้ว
      await fs.unlink(file.path);
      return res.status(400).json({
        success: false,
        message: 'รองรับเฉพาะไฟล์รูปภาพ (JPG, PNG, GIF, WebP)'
      });
    }
    
    // ตรวจสอบขนาดไฟล์ (2MB)
    if (file.size > 2 * 1024 * 1024) {
      await fs.unlink(file.path);
      return res.status(400).json({
        success: false,
        message: 'ขนาดไฟล์ต้องไม่เกิน 2MB'
      });
    }
    
    // บันทึกข้อมูลไฟล์ในฐานข้อมูล
    const fileInfo = {
      fileName: file.filename,
      originalName: file.originalname,
      filePath: file.path,
      fileSize: file.size,
      mimeType: file.mimetype,
      fileType: 'logo'
    };
    
    const fileId = await saveFileInfo(fileInfo, userId);
    
    // อัพเดต system_logo setting
    const logoUrl = `/uploads/system/${file.filename}`;
    await updateSetting('system_logo', logoUrl, userId);
    
    res.json({
      success: true,
      message: 'อัพโหลดโลโก้สำเร็จ',
      data: {
        fileId,
        logoUrl,
        originalName: file.originalname,
        fileSize: file.size
      }
    });
    
  } catch (error) {
    // ลบไฟล์ถ้าเกิดข้อผิดพลาด
    if (req.file && req.file.path) {
      try {
        await fs.unlink(req.file.path);
      } catch (unlinkError) {
        console.error('Error deleting uploaded file:', unlinkError);
      }
    }
    
    console.error('Error uploading logo:', error);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการอัพโหลดโลโก้',
      error: error.message
    });
  }
};

/**
 * DELETE /api/system/logo
 * ลบโลโก้ระบบ
 */
exports.deleteLogo = async (req, res) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'กรุณาเข้าสู่ระบบ'
      });
    }
    
    const userId = req.user.user_id;
    
    // ดึงโลโก้ปัจจุบัน
    const currentLogo = await getSetting('system_logo');
    
    if (!currentLogo) {
      return res.status(404).json({
        success: false,
        message: 'ไม่พบโลโก้ในระบบ'
      });
    }
    
    // ลบโลโก้จาก setting
    await updateSetting('system_logo', '', userId);
    
    // ลบไฟล์จาก server (ถ้ามี)
    if (currentLogo.startsWith('/uploads/')) {
      const filePath = path.join(process.cwd(), 'public', currentLogo);
      try {
        await fs.unlink(filePath);
      } catch (error) {
        console.warn('Could not delete logo file:', filePath);
      }
    }
    
    res.json({
      success: true,
      message: 'ลบโลโก้สำเร็จ'
    });
    
  } catch (error) {
    console.error('Error deleting logo:', error);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการลบโลโก้',
      error: error.message
    });
  }
};

module.exports = {
  getSettings: exports.getSettings,
  getSetting: exports.getSetting,
  updateSettings: exports.updateSettings,
  updateSetting: exports.updateSetting,
  uploadLogo: exports.uploadLogo,
  deleteLogo: exports.deleteLogo
};