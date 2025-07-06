// models/systemSettingsModel.js
// จัดการข้อมูล System Settings และ File Upload

const db = require('../config/db');

/**
 * ดึงการตั้งค่าระบบทั้งหมด
 * @param {boolean} publicOnly - ดึงเฉพาะการตั้งค่าที่เป็น public
 * @returns {Object} การตั้งค่าระบบ
 */
async function getAllSettings(publicOnly = false) {
  try {
    let query = 'SELECT setting_key, setting_value, setting_type, is_public FROM system_settings';
    let params = [];
    
    if (publicOnly) {
      query += ' WHERE is_public = ?';
      params.push(true);
    }
    
    query += ' ORDER BY setting_key';
    
    const [rows] = await db.query(query, params);
    
    // แปลงเป็น object สำหรับใช้งานง่าย
    const settings = {};
    rows.forEach(row => {
      let value = row.setting_value;
      
      // แปลงค่าตาม type
      switch (row.setting_type) {
        case 'boolean':
          value = value === 'true' || value === '1';
          break;
        case 'number':
          value = parseFloat(value);
          break;
        case 'json':
          try {
            value = JSON.parse(value);
          } catch (e) {
            console.warn(`Failed to parse JSON for ${row.setting_key}:`, value);
          }
          break;
        default:
          // string และอื่นๆ ใช้ค่าตามเดิม
          break;
      }
      
      settings[row.setting_key] = value;
    });
    
    return settings;
  } catch (error) {
    console.error('Error fetching system settings:', error);
    throw error;
  }
}

/**
 * ดึงการตั้งค่าเฉพาะ key
 * @param {string} key - key ของการตั้งค่า
 * @returns {any} ค่าการตั้งค่า
 */
async function getSetting(key) {
  try {
    const [rows] = await db.query(
      'SELECT setting_value, setting_type FROM system_settings WHERE setting_key = ?',
      [key]
    );
    
    if (rows.length === 0) {
      return null;
    }
    
    const row = rows[0];
    let value = row.setting_value;
    
    // แปลงค่าตาม type
    switch (row.setting_type) {
      case 'boolean':
        value = value === 'true' || value === '1';
        break;
      case 'number':
        value = parseFloat(value);
        break;
      case 'json':
        try {
          value = JSON.parse(value);
        } catch (e) {
          console.warn(`Failed to parse JSON for ${key}:`, value);
        }
        break;
    }
    
    return value;
  } catch (error) {
    console.error('Error fetching setting:', error);
    throw error;
  }
}

/**
 * อัพเดตการตั้งค่า
 * @param {string} key - key ของการตั้งค่า
 * @param {any} value - ค่าใหม่
 * @param {number} userId - ID ของผู้ใช้ที่อัพเดต
 * @returns {boolean} สำเร็จหรือไม่
 */
async function updateSetting(key, value, userId) {
  try {
    // แปลงค่าให้เป็น string สำหรับเก็บใน database
    let stringValue = value;
    if (typeof value === 'object') {
      stringValue = JSON.stringify(value);
    } else if (typeof value === 'boolean') {
      stringValue = value ? 'true' : 'false';
    } else {
      stringValue = String(value);
    }
    
    const [result] = await db.query(
      `INSERT INTO system_settings (setting_key, setting_value, updated_by) 
       VALUES (?, ?, ?) 
       ON DUPLICATE KEY UPDATE 
       setting_value = VALUES(setting_value),
       updated_by = VALUES(updated_by),
       updated_at = CURRENT_TIMESTAMP`,
      [key, stringValue, userId]
    );
    
    return result.affectedRows > 0;
  } catch (error) {
    console.error('Error updating setting:', error);
    throw error;
  }
}

/**
 * อัพเดตการตั้งค่าหลายๆ ค่าพร้อมกัน
 * @param {Object} settings - object ของการตั้งค่า
 * @param {number} userId - ID ของผู้ใช้ที่อัพเดต
 * @returns {boolean} สำเร็จหรือไม่
 */
async function updateMultipleSettings(settings, userId) {
  const connection = await db.getConnection();
  
  try {
    await connection.beginTransaction();
    
    for (const [key, value] of Object.entries(settings)) {
      let stringValue = value;
      if (typeof value === 'object') {
        stringValue = JSON.stringify(value);
      } else if (typeof value === 'boolean') {
        stringValue = value ? 'true' : 'false';
      } else {
        stringValue = String(value);
      }
      
      await connection.query(
        `INSERT INTO system_settings (setting_key, setting_value, updated_by) 
         VALUES (?, ?, ?) 
         ON DUPLICATE KEY UPDATE 
         setting_value = VALUES(setting_value),
         updated_by = VALUES(updated_by),
         updated_at = CURRENT_TIMESTAMP`,
        [key, stringValue, userId]
      );
    }
    
    await connection.commit();
    return true;
  } catch (error) {
    await connection.rollback();
    console.error('Error updating multiple settings:', error);
    throw error;
  } finally {
    connection.release();
  }
}

/**
 * บันทึกข้อมูลไฟล์ที่อัพโหลด
 * @param {Object} fileInfo - ข้อมูลไฟล์
 * @param {number} userId - ID ของผู้ใช้ที่อัพโหลด
 * @returns {number} ID ของไฟล์ที่บันทึก
 */
async function saveFileInfo(fileInfo, userId) {
  try {
    const { fileName, originalName, filePath, fileSize, mimeType, fileType } = fileInfo;
    
    const [result] = await db.query(
      `INSERT INTO system_files 
       (file_name, original_name, file_path, file_size, mime_type, file_type, uploaded_by) 
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [fileName, originalName, filePath, fileSize, mimeType, fileType, userId]
    );
    
    return result.insertId;
  } catch (error) {
    console.error('Error saving file info:', error);
    throw error;
  }
}

/**
 * ดึงข้อมูลไฟล์จาก ID
 * @param {number} fileId - ID ของไฟล์
 * @returns {Object} ข้อมูลไฟล์
 */
async function getFileInfo(fileId) {
  try {
    const [rows] = await db.query(
      'SELECT * FROM system_files WHERE id = ?',
      [fileId]
    );
    
    return rows.length > 0 ? rows[0] : null;
  } catch (error) {
    console.error('Error fetching file info:', error);
    throw error;
  }
}

/**
 * ลบไฟล์จากระบบ
 * @param {number} fileId - ID ของไฟล์
 * @returns {boolean} สำเร็จหรือไม่
 */
async function deleteFile(fileId) {
  try {
    const [result] = await db.query(
      'DELETE FROM system_files WHERE id = ?',
      [fileId]
    );
    
    return result.affectedRows > 0;
  } catch (error) {
    console.error('Error deleting file:', error);
    throw error;
  }
}

module.exports = {
  getAllSettings,
  getSetting,
  updateSetting,
  updateMultipleSettings,
  saveFileInfo,
  getFileInfo,
  deleteFile
};