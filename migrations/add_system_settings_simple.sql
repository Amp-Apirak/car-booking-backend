-- migrations/add_system_settings_simple.sql
-- สร้างตาราง system_settings สำหรับเก็บการตั้งค่าระบบ (แบบไม่มี Foreign Key)

DROP TABLE IF EXISTS system_files;
DROP TABLE IF EXISTS system_settings;

CREATE TABLE system_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value LONGTEXT,
    setting_type ENUM('string', 'number', 'boolean', 'json', 'file') DEFAULT 'string',
    description VARCHAR(255),
    is_public BOOLEAN DEFAULT FALSE COMMENT 'สามารถเข้าถึงได้โดยไม่ต้องล็อกอิน',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by VARCHAR(100) COMMENT 'ชื่อผู้ใช้ที่อัพเดต'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- สร้างตารางสำหรับเก็บไฟล์ที่อัพโหลด
CREATE TABLE system_files (
    id INT AUTO_INCREMENT PRIMARY KEY,
    file_name VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INT,
    mime_type VARCHAR(100),
    file_type ENUM('logo', 'favicon', 'background', 'other') DEFAULT 'other',
    uploaded_by VARCHAR(100) COMMENT 'ชื่อผู้ใช้ที่อัพโหลด',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert ค่าเริ่มต้นสำหรับระบบ
INSERT INTO system_settings (setting_key, setting_value, setting_type, description, is_public) VALUES
('system_name', 'ระบบจองรถยนต์', 'string', 'ชื่อระบบ', TRUE),
('system_tagline', 'จัดการการจองอย่างมืออาชีพ', 'string', 'คำอธิบายระบบ', TRUE),
('system_logo', '', 'string', 'URL โลโก้ระบบ', TRUE),
('system_favicon', '', 'string', 'URL Favicon', TRUE),
('system_primary_color', '#3b82f6', 'string', 'สีหลักของระบบ', TRUE),
('system_timezone', 'Asia/Bangkok', 'string', 'เขตเวลาของระบบ', TRUE),
('system_language', 'th', 'string', 'ภาษาเริ่มต้นของระบบ', TRUE),
('system_currency', 'THB', 'string', 'สกุลเงินของระบบ', TRUE),
('maintenance_mode', 'false', 'boolean', 'โหมดบำรุงรักษา', FALSE),
('registration_enabled', 'true', 'boolean', 'เปิดให้ลงทะเบียนได้', FALSE)
ON DUPLICATE KEY UPDATE 
setting_value = VALUES(setting_value),
updated_at = CURRENT_TIMESTAMP;

-- สร้าง index สำหรับ performance
CREATE INDEX idx_setting_key ON system_settings(setting_key);
CREATE INDEX idx_is_public ON system_settings(is_public);
CREATE INDEX idx_file_type ON system_files(file_type);

SELECT 'ตารางถูกสร้างเรียบร้อยแล้ว!' as result;