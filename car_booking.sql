-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 06, 2025 at 05:31 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `car_booking`
--

-- --------------------------------------------------------

--
-- Table structure for table `approvals`
--

CREATE TABLE `approvals` (
  `approval_id` char(32) NOT NULL COMMENT 'รหัสการอนุมัติแบบ UUID v4 ไม่มีขีด (32 หลัก)',
  `booking_id` char(32) NOT NULL COMMENT 'รหัสการจอง (FK → bookings.booking_id)',
  `approver_id` char(32) NOT NULL COMMENT 'รหัสผู้อนุมัติ (FK → users.user_id)',
  `step` tinyint(4) NOT NULL COMMENT 'ลำดับขั้นการอนุมัติ (1–5)',
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending' COMMENT 'สถานะการอนุมัติ (pending=รอ, approved=อนุมัติ, rejected=ไม่อนุมัติ)',
  `comment` text DEFAULT NULL COMMENT 'ความคิดเห็นหรือเหตุผลในการอนุมัติ/ปฏิเสธ',
  `approved_at` timestamp NULL DEFAULT NULL COMMENT 'วันที่อนุมัติ/ปฏิเสธ',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่สร้าง record การอนุมัติ',
  `step_id` char(32) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเก็บข้อมูลการอนุมัติการจองรถแต่ละขั้น';

-- --------------------------------------------------------

--
-- Table structure for table `approval_flows`
--

CREATE TABLE `approval_flows` (
  `flow_id` char(32) NOT NULL,
  `flow_name` varchar(100) NOT NULL,
  `flow_description` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `approval_flows`
--

INSERT INTO `approval_flows` (`flow_id`, `flow_name`, `flow_description`, `is_active`) VALUES
('2c9cd21bd64b4447af7cb1c8cc03c31b', 'อนุมัติทั่วไป 3 ลำดับขั้น', 'อนุมัติทั่วไป 3 ลำดับขั้น เห็นชอบโดย สท. >> อนุมัติขั้นแรงโดย ปลัด,รองปลัด >> อนุมัติขั้นสุดท้าย นายก, รองนายก ', 1);

-- --------------------------------------------------------

--
-- Table structure for table `approval_steps`
--

CREATE TABLE `approval_steps` (
  `step_id` char(32) NOT NULL,
  `flow_id` char(32) DEFAULT NULL,
  `step_order` int(11) NOT NULL,
  `role_id` char(32) DEFAULT NULL,
  `step_name` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `approval_steps`
--

INSERT INTO `approval_steps` (`step_id`, `flow_id`, `step_order`, `role_id`, `step_name`) VALUES
('64fee3bdec5b438c99ae4d536e413b5f', '2c9cd21bd64b4447af7cb1c8cc03c31b', 1, 'ac171b33817c4b889666abe978e11baa', 'ผู้อนุมัติระดับ 1'),
('9efd17f10547414d92f2feaed636c17b', '2c9cd21bd64b4447af7cb1c8cc03c31b', 2, '7d8729453319497eb7630914179975b4', 'ผู้อนุมัติระดับ 2'),
('a76e0c9eacb94dfc873063c6b8e6f6e8', '2c9cd21bd64b4447af7cb1c8cc03c31b', 3, '0527b784f86b49a9b3e80084e9cf7ce5', 'ผู้อนุมัติระดับ 3');

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `log_id` char(32) NOT NULL COMMENT 'รหัสบันทึกประวัติแบบ UUID v4 ไม่มีขีด (32 หลัก)',
  `user_id` char(32) NOT NULL COMMENT 'รหัสผู้ใช้งาน (FK → users.user_id)',
  `module` varchar(50) NOT NULL COMMENT 'ชื่อโมดูลที่มีการกระทำ เช่น bookings, users, vehicles',
  `action` varchar(100) NOT NULL COMMENT 'รายละเอียดการกระทำ เช่น create_booking, update_profile',
  `ip_address` varchar(45) DEFAULT NULL COMMENT 'ที่อยู่ IP ของผู้ใช้งาน',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่และเวลาที่บันทึกเหตุการณ์'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางบันทึกประวัติการใช้งานระบบ';

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` char(32) NOT NULL COMMENT 'รหัสการจองแบบ UUID v4 ไม่มีขีด (32 หลัก)',
  `user_id` char(32) NOT NULL COMMENT 'รหัสผู้จอง (FK → users.user_id)',
  `vehicle_id` char(32) NOT NULL COMMENT 'รหัสรถ (FK → vehicles.vehicle_id)',
  `driver_id` char(32) DEFAULT NULL COMMENT 'รหัสพนักงานขับรถ (FK → drivers.driver_id) ถ้าไม่มีคนขับให้เป็น NULL',
  `num_passengers` int(11) NOT NULL COMMENT 'จำนวนผู้โดยสาร',
  `reason` text DEFAULT NULL COMMENT 'เหตุผลหรือรายละเอียดการขอใช้งาน',
  `phone` varchar(20) DEFAULT NULL COMMENT 'เบอร์โทรศัพท์ผู้จอง',
  `start_date` date NOT NULL COMMENT 'วันที่เริ่มใช้งาน',
  `start_time` time NOT NULL COMMENT 'เวลาที่เริ่มใช้งาน',
  `end_date` date NOT NULL COMMENT 'วันที่สิ้นสุดการใช้งาน',
  `end_time` time NOT NULL COMMENT 'เวลาที่สิ้นสุดการใช้งาน',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่สร้างการจอง',
  `origin_location` varchar(255) DEFAULT NULL COMMENT 'สถานที่ต้นทาง',
  `destination_location` varchar(255) DEFAULT NULL COMMENT 'สถานที่ปลายทาง',
  `start_odometer` int(11) DEFAULT NULL COMMENT 'เลขไมค์ขาไป',
  `end_odometer` int(11) DEFAULT NULL COMMENT 'เลขไมค์ขากลับ',
  `total_distance` decimal(10,2) DEFAULT NULL COMMENT 'ระยะทางรวม (กิโลเมตร)',
  `status` enum('pending','approved','rejected','cancelled_by_user','cancelled_by_officer') NOT NULL DEFAULT 'pending' COMMENT 'สถานะการจอง (pending=รออนุมัติ, approved=อนุมัติ, rejected=ไม่อนุมัติ, cancelled_by_user=ยกเลิกโดยผู้จอง, cancelled_by_officer=ยกเลิกโดยเจ้าหน้าที่)',
  `flow_id` char(32) DEFAULT NULL,
  `approval_status` enum('pending','approved','rejected') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเก็บข้อมูลการจองรถ';

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`booking_id`, `user_id`, `vehicle_id`, `driver_id`, `num_passengers`, `reason`, `phone`, `start_date`, `start_time`, `end_date`, `end_time`, `created_at`, `origin_location`, `destination_location`, `start_odometer`, `end_odometer`, `total_distance`, `status`, `flow_id`, `approval_status`) VALUES
('81746405193b44a598b0a12a1d1f5677', 'f9591a0215794225b088d53b6d2ef37d', 'ce4c794c341c4ca9bc74d6484cdcbe22', '3b1f8a7c5d9e2f6a4c8b0d1e3f5a7c9d', 2, 'ไปรับเอกสาร', '0812345678', '2025-07-01', '09:00:00', '2025-07-01', '12:00:00', '2025-06-29 10:50:42', 'สํานักงานใหญ่', 'สาขา 4', 1000, 1050, 50.00, 'pending', '2c9cd21bd64b4447af7cb1c8cc03c31b', 'pending'),
('f7a8cf7ec3644264ab8eda3c05b483f7', 'f9591a0215794225b088d53b6d2ef37d', 'ce4c794c341c4ca9bc74d6484cdcbe22', '3b1f8a7c5d9e2f6a4c8b0d1e3f5a7c9d', 2, 'ไปรับเอกสาร', '0812345678', '2025-07-01', '09:00:00', '2025-07-01', '12:00:00', '2025-06-29 11:08:29', 'สํานักงานใหญ่', 'สาขา 4', 1000, 1050, 50.00, 'pending', '2c9cd21bd64b4447af7cb1c8cc03c31b', 'pending');

-- --------------------------------------------------------

--
-- Table structure for table `booking_approval_logs`
--

CREATE TABLE `booking_approval_logs` (
  `log_id` char(32) NOT NULL,
  `booking_id` char(32) NOT NULL,
  `step_id` char(32) NOT NULL,
  `approved_by` char(32) NOT NULL,
  `approved_at` datetime DEFAULT current_timestamp(),
  `status` enum('approved','rejected') NOT NULL,
  `comment` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `booking_approval_status`
--

CREATE TABLE `booking_approval_status` (
  `booking_id` char(32) NOT NULL,
  `flow_id` char(32) NOT NULL,
  `current_step_order` int(11) NOT NULL DEFAULT 1,
  `is_approved` tinyint(1) DEFAULT 0,
  `is_rejected` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `booking_approval_status`
--

INSERT INTO `booking_approval_status` (`booking_id`, `flow_id`, `current_step_order`, `is_approved`, `is_rejected`) VALUES
('f7a8cf7ec3644264ab8eda3c05b483f7', '2c9cd21bd64b4447af7cb1c8cc03c31b', 1, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `booking_equipments`
--

CREATE TABLE `booking_equipments` (
  `booking_equipment_id` char(32) NOT NULL COMMENT 'รหัสเชื่อมโยงการจอง-อุปกรณ์แบบ UUID v4 ไม่มีขีด (32 หลัก)',
  `booking_id` char(32) NOT NULL COMMENT 'รหัสการจอง (FK → bookings.booking_id)',
  `equipment_id` char(32) NOT NULL COMMENT 'รหัสอุปกรณ์เสริม (FK → equipments.equipment_id)',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่เพิ่มอุปกรณ์เสริมให้กับการจอง',
  `quantity` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเชื่อมการจองกับอุปกรณ์เสริม';

--
-- Dumping data for table `booking_equipments`
--

INSERT INTO `booking_equipments` (`booking_equipment_id`, `booking_id`, `equipment_id`, `created_at`, `quantity`) VALUES
('cac1c8f986fd42ca8911fd247caa0aa7', '81746405193b44a598b0a12a1d1f5677', 'b6073afe518a4097ad284540dd7751df', '2025-06-29 10:54:23', 1),
('ed9a54d5f98640d19684f645e94859dd', '81746405193b44a598b0a12a1d1f5677', '1dde628980ae46069b7b9d53a1ef5783', '2025-06-29 10:53:38', 1);

-- --------------------------------------------------------

--
-- Table structure for table `drivers`
--

CREATE TABLE `drivers` (
  `driver_id` char(32) NOT NULL COMMENT 'รหัสพนักงานขับรถแบบ UUID v4 ไม่มีขีด (32 หลัก)',
  `name` varchar(100) NOT NULL COMMENT 'ชื่อ-นามสกุลพนักงานขับรถ',
  `phone` varchar(20) DEFAULT NULL COMMENT 'เบอร์โทรศัพท์พนักงานขับรถ',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่เพิ่มพนักงานขับรถ'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเก็บข้อมูลพนักงานขับรถ';

--
-- Dumping data for table `drivers`
--

INSERT INTO `drivers` (`driver_id`, `name`, `phone`, `created_at`) VALUES
('3b1f8a7c5d9e2f6a4c8b0d1e3f5a7c9d', 'Somchai Driver', '0812345678', '2025-06-29 09:54:58'),
('550e8400e29b41d4a716446655440000', 'Anucha Driver', '0898765432', '2025-06-29 09:54:58');

-- --------------------------------------------------------

--
-- Table structure for table `equipments`
--

CREATE TABLE `equipments` (
  `equipment_id` char(32) NOT NULL COMMENT 'รหัสอุปกรณ์เสริมแบบ UUID v4 ไม่มีขีด (32 หลัก)',
  `equipment_name` varchar(100) NOT NULL COMMENT 'ชื่ออุปกรณ์เสริม เช่น GPS, ที่ชาร์จมือถือ',
  `description` varchar(254) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่สร้างรายการอุปกรณ์'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเก็บข้อมูลอุปกรณ์เสริม';

--
-- Dumping data for table `equipments`
--

INSERT INTO `equipments` (`equipment_id`, `equipment_name`, `description`, `created_at`) VALUES
('1dde628980ae46069b7b9d53a1ef5783', 'ลำโพง', 'เครื่องขยายเสียง ไมค์ลำโพง', '2025-06-29 09:48:39'),
('4af6247464854d3abbcbb71d1626ebc7', 'GPS Navigatort', 'เครื่องระบุตำแหน่ง', '2025-06-29 09:48:14'),
('b6073afe518a4097ad284540dd7751df', 'กล้องติดรถยนต์', 'บันทึกภาพขณะขับขี่', '2025-06-29 09:47:36'),
('cf1a00334c224a7bb4d4cb6dbaec72a7', 'Baby Seat', 'เบาะนั่งเด็ก', '2025-06-29 09:48:00'),
('e12446199cd44846b3d13da411aed69b', 'น้ำมัน', 'น้ำมันสำรอง (เป็นกะร่อน)', '2025-06-29 09:49:06');

-- --------------------------------------------------------

--
-- Table structure for table `jwt_blacklist`
--

CREATE TABLE `jwt_blacklist` (
  `jti` char(36) NOT NULL COMMENT 'UUID v4 ของ token',
  `user_id` char(32) NOT NULL,
  `expired_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `organizations`
--

CREATE TABLE `organizations` (
  `organization_id` char(32) NOT NULL,
  `parent_id` char(32) DEFAULT NULL,
  `path` varchar(255) DEFAULT NULL,
  `name` varchar(100) NOT NULL COMMENT 'ชื่อแผนก',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่สร้างแผนก'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเก็บข้อมูลแผนก';

--
-- Dumping data for table `organizations`
--

INSERT INTO `organizations` (`organization_id`, `parent_id`, `path`, `name`, `created_at`) VALUES
('2e950612491a11f08b210242ac120002', NULL, '2e950612491a11f08b210242ac120002', 'Point TI', '2025-06-28 15:41:15'),
('bf4f9c05543611f097453417ebbed40a', '2e950612491a11f08b210242ac120002', '2e950612491a11f08b210242ac120002/bf4f9c05543611f097453417ebbed40a', 'องค์การบริหารส่วนจังหวัดชลบุรี', '2025-06-28 15:44:17'),
('bf515beb543711f097453417ebbed40a', 'bf4f9c05543611f097453417ebbed40a', '2e950612491a11f08b210242ac120002/bf4f9c05543611f097453417ebbed40a/bf515beb543711f097453417ebbed40a', 'โรงพยาบาลส่งเสริมสุขภาพบ้านห้วยสูบ', '2025-06-28 15:51:26'),
('d6149e48543811f097453417ebbed40a', 'bf4f9c05543611f097453417ebbed40a', '2e950612491a11f08b210242ac120002/bf4f9c05543611f097453417ebbed40a/d6149e48543811f097453417ebbed40a', 'โรงพยาบาลส่งเสริมสุขภาพหนองหงษ์', '2025-06-28 15:59:14');

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `permission_id` char(32) NOT NULL COMMENT 'รหัสสิทธิ์แบบ UUID v4 ไม่มีขีด (32 หลัก)',
  `name` varchar(100) NOT NULL COMMENT 'ชื่อสิทธิ์ เช่น create_booking, approve_booking',
  `description` text DEFAULT NULL COMMENT 'รายละเอียดเพิ่มเติมของสิทธิ์',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่สร้างสิทธิ์'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเก็บสิทธิ์ต่างๆ ในระบบ';

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`permission_id`, `name`, `description`, `created_at`) VALUES
('6f6caa1d4d764e02b3ad938420d53bde', 'approve_booking', 'อนุมัติ/ปฏิเสธการจอง', '2025-06-28 16:02:08'),
('db208d5446734211b6f01c92cabf5f8e', 'manage_vehicles', 'จัดการรายการยานพาหนะ', '2025-06-28 16:02:17'),
('f0789ee3639f421d8c3a1131dd90423d', 'create_booking', 'สร้างการจอง', '2025-06-28 16:01:51');

-- --------------------------------------------------------

--
-- Table structure for table `refresh_tokens`
--

CREATE TABLE `refresh_tokens` (
  `token_id` char(36) NOT NULL COMMENT 'รหัส token',
  `user_id` char(32) NOT NULL COMMENT 'FK → users.user_id',
  `token_hash` char(64) NOT NULL COMMENT 'เก็บเป็น hash เพื่อความปลอดภัย',
  `expired_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'วันหมดอายุ เช่น 7 วัน',
  `revoked_at` timestamp NULL DEFAULT NULL COMMENT 'วันเวลาที่เพิกถอน (NULL = ยังใช้ได้)',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่สร้าง'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเก็บ refresh token ต่อผู้ใช้';

--
-- Dumping data for table `refresh_tokens`
--

INSERT INTO `refresh_tokens` (`token_id`, `user_id`, `token_hash`, `expired_at`, `revoked_at`, `created_at`) VALUES
('056eab07-ac32-4ce3-ba97-48fc5e2d59f0', '036354d67ec34f9eb28cd26c8b2ec26e', 'ebb2787b9439023f6f78a82d1050da95050565d17ff6aa17efec8e70c9d3c17d', '2025-07-06 05:02:58', NULL, '2025-06-29 05:02:58'),
('2a32af64-380c-4ba8-b58c-c22b9e28b963', '8b06d87178544b52b9269eafc89c4cb0', '31adad82e5ad885527590e64bc4e22c09b7873ca60e3744993d96c8539674429', '2025-07-05 16:15:10', NULL, '2025-06-28 16:15:10'),
('332548de-5752-4c7a-b10a-850be9bbc64a', '036354d67ec34f9eb28cd26c8b2ec26e', 'd804e56d887c12cd65f6f21e36df8d83adae20e7436d0e8b13f3011823ae5e34', '2025-07-05 15:49:54', NULL, '2025-06-28 15:49:54'),
('3d1f353c-19ef-4b46-ba52-bfbc995125c1', '036354d67ec34f9eb28cd26c8b2ec26e', 'c1d4686928da3e4408a0af60fa9979aa6c72cf6427de0b73514561d167517781', '2025-07-06 10:21:49', NULL, '2025-06-29 10:21:49'),
('6af44aca-79c1-4fb5-92f3-1c93a6d4092b', '036354d67ec34f9eb28cd26c8b2ec26e', 'a9521b8d1ba3df0181bed085bc700fd44a6522ec2ac40a38b2edd5828080c9f2', '2025-07-05 16:08:55', NULL, '2025-06-28 16:08:55'),
('716e4fef-bd7f-4b5e-a58c-d561b41fbe44', 'f9591a0215794225b088d53b6d2ef37d', '030e78a415f0b3e3e8c929d62745f36d6b1c98d74d0fb16258aeea2a01386662', '2025-07-05 16:14:53', NULL, '2025-06-28 16:14:53'),
('779e1034-81a3-4d8b-891d-98985368e2d4', 'f31524fdbb9f4460b7c5f80fda33cf08', '5aa89304378ef45052c42a24eb5083c2a1561dd3031b15c5f9e312241085e5f6', '2025-07-05 16:14:13', NULL, '2025-06-28 16:14:13'),
('7e87ab58-a111-40fd-93e1-745436f473b8', '3699f1ea64684ac78b02afd1fb9b3cdd', 'eb71bc3ce618581fddae985d25efed0c16dbc1044aea15eb6178cf79484a867b', '2025-07-06 10:58:26', NULL, '2025-06-29 10:58:26'),
('953b10a6-b927-4529-9b62-7de74ee33b56', 'cd257e3d337941e5ac61f5ea9de99e92', '21b724b78da5d7621f9fb12b31219ce91b01199f1569530079fab676390f5968', '2025-07-06 05:03:21', NULL, '2025-06-29 05:03:21'),
('a09cb443-6eea-4b60-bfad-385fdb28ca0a', '036354d67ec34f9eb28cd26c8b2ec26e', 'c0a008b333fa5b4ad651b2d8994850b38741b6cb3f4c06e0486687795a2d7b45', '2025-07-06 05:02:41', NULL, '2025-06-29 05:02:41'),
('a3292fe4-f3bd-49ce-8af5-40f5c6ecdee0', '036354d67ec34f9eb28cd26c8b2ec26e', '4ce069fb63886a761855bc8685251c8d5e12012df80db766bacb01a3e9359de8', '2025-07-06 10:46:57', NULL, '2025-06-29 10:46:57'),
('a98ca90f-c20e-4fc0-98d7-9524e8d95ece', '3699f1ea64684ac78b02afd1fb9b3cdd', 'f2c87345e25c55084ec50c3f085759a546703dae386a103c0ca453d5c6c4ab9a', '2025-07-06 11:11:01', NULL, '2025-06-29 11:11:01'),
('ac21c75c-45fd-4f1b-b300-15cbf31ae56c', '3699f1ea64684ac78b02afd1fb9b3cdd', '53428dbf555f0e3fc32e92e3f580d75bfa68a95f36ce8ee067c948a084d27897', '2025-07-06 12:56:03', NULL, '2025-06-29 12:56:03'),
('bd2c77bd-cf27-4ff6-9bb8-f400843d99da', 'aadaec379b964a44ac33896816f752ad', 'fe2e99d428ea85aaed75e903143024aec2c8a4edb848f0cffc735b20ca2c9c72', '2025-07-05 16:14:22', NULL, '2025-06-28 16:14:22'),
('cb65206b-5bea-4c78-ae69-0d5e737e4b89', '5ed0cce547ea4898aca5ee633449c2fb', 'c6532139a289aca1874014f59641d187abc3282c09e5ef672583db10739fb994', '2025-07-05 16:13:17', NULL, '2025-06-28 16:13:17'),
('d495edec-a904-4bb7-89d9-17e19fbe538a', '036354d67ec34f9eb28cd26c8b2ec26e', '250d337aecdde26c964dabdd55bffaf66b799b55b2bee0297a8bf3040cae1f7f', '2025-07-06 10:50:24', NULL, '2025-06-29 10:50:24'),
('d55ab049-ce3c-4230-98f0-8017d62b48e2', '036354d67ec34f9eb28cd26c8b2ec26e', '55802cd14ea93fb19bb9879fa4d98ac7dbcbf7744fdd44e778fcd6328fa58dd1', '2025-07-06 12:55:48', NULL, '2025-06-29 12:55:48'),
('de832e86-7320-4e4c-9ac5-9eecb1a9b923', '3699f1ea64684ac78b02afd1fb9b3cdd', '28f935991f51ae10a02213bbbe7353efc64a5bdfe0eee192dfb2706e83d2cb74', '2025-07-06 12:45:54', NULL, '2025-06-29 12:45:54'),
('e10479fa-7a0f-4609-b5b1-d1e2298a8fa0', '3699f1ea64684ac78b02afd1fb9b3cdd', 'b528c6f1fc385464c80998cdf67223301e4bf20f3c398b52f2ec439d750e57c7', '2025-07-05 16:14:02', NULL, '2025-06-28 16:14:02'),
('eca08e39-9a76-4fb5-bd33-efee42216498', '036354d67ec34f9eb28cd26c8b2ec26e', 'd92b3bb6df15007cea2bda1e2f58bebaac654c4f2e5a354c511619e2e13a3e99', '2025-07-06 09:46:46', NULL, '2025-06-29 09:46:46'),
('eef46306-bc9d-437c-852c-cfc2a8cfb6cc', '036354d67ec34f9eb28cd26c8b2ec26e', '30e4734af342c5ba261b12bc6b09f511eeace0b11eaf964d22671d5e115929fc', '2025-07-06 03:48:23', NULL, '2025-06-29 03:48:23'),
('f3bac213-8f21-4028-bfc6-37fb7dd27193', '036354d67ec34f9eb28cd26c8b2ec26e', '1486bdc2552858bde5b349ec323394217393795ff55c12d149014e4badfb1404', '2025-07-05 15:43:14', NULL, '2025-06-28 15:43:14');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `role_id` char(32) NOT NULL COMMENT 'รหัสบทบาทแบบ UUID v4 ไม่มีขีด (32 หลัก)',
  `name` varchar(50) NOT NULL COMMENT 'ชื่อบทบาท เช่น admin, manager, staff',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่สร้างบทบาท'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเก็บบทบาทของผู้ใช้งาน';

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`role_id`, `name`, `created_at`) VALUES
('0527b784f86b49a9b3e80084e9cf7ce5', 'approve level3', '2025-06-29 10:05:50'),
('5e600f16228846a59f512dcda88b1fc0', 'admin', '2025-06-28 16:00:40'),
('687e5497bfdc447da1e6e4d98827b46c', 'staff', '2025-06-28 16:00:56'),
('7d8729453319497eb7630914179975b4', 'approve level2', '2025-06-29 10:05:44'),
('850f38dc62364a8ca0adadce762a46b5', 'manager', '2025-06-28 16:00:49'),
('ac171b33817c4b889666abe978e11baa', 'approve level1', '2025-06-28 16:01:07');

-- --------------------------------------------------------

--
-- Table structure for table `role_permissions`
--

CREATE TABLE `role_permissions` (
  `role_permission_id` char(32) NOT NULL COMMENT 'รหัสเชื่อมโยงบทบาท-สิทธิ์ UUID v4 ไม่มีขีด (32 หลัก)',
  `role_id` char(32) NOT NULL COMMENT 'รหัสบทบาท (FK → roles.role_id)',
  `permission_id` char(32) NOT NULL COMMENT 'รหัสสิทธิ์ (FK → permissions.permission_id)',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่สร้าง mapping'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเชื่อมบทบาทกับสิทธิ์';

--
-- Dumping data for table `role_permissions`
--

INSERT INTO `role_permissions` (`role_permission_id`, `role_id`, `permission_id`, `created_at`) VALUES
('27f75f120e04480da922b5c5df432957', '5e600f16228846a59f512dcda88b1fc0', 'f0789ee3639f421d8c3a1131dd90423d', '2025-06-28 16:09:56'),
('6b66c835f4784b808e72168ff7aaad82', 'ac171b33817c4b889666abe978e11baa', 'f0789ee3639f421d8c3a1131dd90423d', '2025-06-28 16:11:21'),
('6c52f9ede5ae4c49a583f1d29b671aef', 'ac171b33817c4b889666abe978e11baa', '6f6caa1d4d764e02b3ad938420d53bde', '2025-06-28 16:11:15'),
('6dc555cac66448588366b57f802d21f7', '850f38dc62364a8ca0adadce762a46b5', 'db208d5446734211b6f01c92cabf5f8e', '2025-06-28 16:10:38'),
('711c026af130496f9667ff61591bb71c', '0527b784f86b49a9b3e80084e9cf7ce5', 'f0789ee3639f421d8c3a1131dd90423d', '2025-06-29 10:07:12'),
('9bd6da43bf63492e8f719a2c3573bba2', '850f38dc62364a8ca0adadce762a46b5', 'f0789ee3639f421d8c3a1131dd90423d', '2025-06-28 16:10:23'),
('9dfbbf29841441fb8867a6f287b54316', '7d8729453319497eb7630914179975b4', 'f0789ee3639f421d8c3a1131dd90423d', '2025-06-29 10:06:54'),
('bdf455fbc6874f8698db92a506e6e192', '5e600f16228846a59f512dcda88b1fc0', 'db208d5446734211b6f01c92cabf5f8e', '2025-06-28 16:09:51'),
('eee8c1853580498fa79aae99a6287e19', '7d8729453319497eb7630914179975b4', '6f6caa1d4d764e02b3ad938420d53bde', '2025-06-29 10:07:59'),
('efecfbf0b136419eaac8b716a972ff04', '0527b784f86b49a9b3e80084e9cf7ce5', '6f6caa1d4d764e02b3ad938420d53bde', '2025-06-29 10:07:43'),
('f099dec316a1441cbffcd71308da881b', '5e600f16228846a59f512dcda88b1fc0', '6f6caa1d4d764e02b3ad938420d53bde', '2025-06-28 16:09:45');

-- --------------------------------------------------------

--
-- Table structure for table `system_files`
--

CREATE TABLE `system_files` (
  `id` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `original_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` int(11) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_type` enum('logo','favicon','background','other') DEFAULT 'other',
  `uploaded_by` varchar(100) DEFAULT NULL COMMENT 'ชื่อผู้ใช้ที่อัพโหลด',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_settings`
--

CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` longtext DEFAULT NULL,
  `setting_type` enum('string','number','boolean','json','file') DEFAULT 'string',
  `description` varchar(255) DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT 0 COMMENT 'สามารถเข้าถึงได้โดยไม่ต้องล็อกอิน',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` varchar(100) DEFAULT NULL COMMENT 'ชื่อผู้ใช้ที่อัพเดต'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `system_settings`
--

INSERT INTO `system_settings` (`id`, `setting_key`, `setting_value`, `setting_type`, `description`, `is_public`, `created_at`, `updated_at`, `updated_by`) VALUES
(1, 'system_name', 'ระบบจองรถยนต์', 'string', 'ชื่อระบบ', 1, '2025-07-06 15:27:49', '2025-07-06 15:30:59', NULL),
(2, 'system_tagline', 'จัดการการจองอย่างมืออาชีพ', 'string', 'คำอธิบายระบบ', 1, '2025-07-06 15:27:49', '2025-07-06 15:30:59', NULL),
(3, 'system_logo', '', 'string', 'URL โลโก้ระบบ', 1, '2025-07-06 15:27:49', '2025-07-06 15:30:59', NULL),
(4, 'system_favicon', '', 'string', 'URL Favicon', 1, '2025-07-06 15:27:49', '2025-07-06 15:30:59', NULL),
(5, 'system_primary_color', '#3b82f6', 'string', 'สีหลักของระบบ', 1, '2025-07-06 15:27:49', '2025-07-06 15:30:59', NULL),
(6, 'system_timezone', 'Asia/Bangkok', 'string', 'เขตเวลาของระบบ', 1, '2025-07-06 15:27:49', '2025-07-06 15:30:59', NULL),
(7, 'system_language', 'th', 'string', 'ภาษาเริ่มต้นของระบบ', 1, '2025-07-06 15:27:49', '2025-07-06 15:30:59', NULL),
(8, 'system_currency', 'THB', 'string', 'สกุลเงินของระบบ', 1, '2025-07-06 15:27:49', '2025-07-06 15:30:59', NULL),
(9, 'maintenance_mode', 'false', 'boolean', 'โหมดบำรุงรักษา', 0, '2025-07-06 15:27:49', '2025-07-06 15:30:59', NULL),
(10, 'registration_enabled', 'true', 'boolean', 'เปิดให้ลงทะเบียนได้', 0, '2025-07-06 15:27:49', '2025-07-06 15:30:59', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` char(32) NOT NULL COMMENT 'รหัสผู้ใช้งานแบบ UUID v4 ไม่มีขีด (32 หลัก)',
  `username` varchar(50) NOT NULL COMMENT 'ชื่อบัญชี (Account) ใช้สำหรับล็อกอิน',
  `email` varchar(100) NOT NULL COMMENT 'อีเมลของผู้ใช้',
  `password` varchar(255) NOT NULL COMMENT 'รหัสผ่าน (เก็บเป็น hash ด้วย bcryptjs)',
  `first_name` varchar(100) DEFAULT NULL COMMENT 'ชื่อจริงของผู้ใช้',
  `last_name` varchar(100) DEFAULT NULL COMMENT 'นามสกุลของผู้ใช้',
  `gender` enum('male','female','other') DEFAULT NULL COMMENT 'เพศ (ชาย, หญิง, ไม่ระบุ)',
  `citizen_id` varchar(13) DEFAULT NULL COMMENT 'เลขบัตรประชาชน 13 หลัก',
  `phone` varchar(20) DEFAULT NULL COMMENT 'เบอร์โทรศัพท์',
  `address` text DEFAULT NULL COMMENT 'ที่อยู่',
  `country` varchar(100) DEFAULT NULL COMMENT 'ประเทศ',
  `province` varchar(100) DEFAULT NULL COMMENT 'จังหวัด',
  `postal_code` varchar(10) DEFAULT NULL COMMENT 'รหัสไปรษณีย์',
  `avatar_path` varchar(255) DEFAULT NULL COMMENT 'พาธหรือ URL รูปโปรไฟล์ (Avatar)',
  `organization_id` char(32) NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active' COMMENT 'สถานะสมาชิก (active=ใช้งานได้, inactive=ระงับ)',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่สร้างบัญชี',
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp() COMMENT 'วันที่แก้ไขข้อมูลล่าสุด'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเก็บข้อมูลสมาชิกระบบ';

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `email`, `password`, `first_name`, `last_name`, `gender`, `citizen_id`, `phone`, `address`, `country`, `province`, `postal_code`, `avatar_path`, `organization_id`, `status`, `created_at`, `updated_at`) VALUES
('036354d67ec34f9eb28cd26c8b2ec26e', 'admin', 'admin@example.com', '$2b$10$IgWPGMwS9MRxNon7f5qu/uL8U.xihrNV.8VfgcI7x1iz/9Tit9aNq', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2e950612491a11f08b210242ac120002', 'active', '2025-06-28 15:43:14', NULL),
('3699f1ea64684ac78b02afd1fb9b3cdd', 'approve_one', 'approve_one@example.com', '$2b$10$jY8gbo9G/JxStjsiBj7E5eBqGZ4L/GV01Q4QWo017eYi/aEutOHSO', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'bf4f9c05543611f097453417ebbed40a', 'active', '2025-06-28 16:14:02', NULL),
('5ed0cce547ea4898aca5ee633449c2fb', 'manager', 'manager@example.com', '$2b$10$BKg8rwgxgRJCR6yBxB1GheSABCjdD/5lGwCBwF4f/lZgPbb9mBtqe', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'bf4f9c05543611f097453417ebbed40a', 'active', '2025-06-28 16:13:17', NULL),
('8b06d87178544b52b9269eafc89c4cb0', 'staff_two', 'staff_two@example.com', '$2b$10$QM5UHLDfzzXPtxdidxdq7.QoE/go6.skRr9LcU8nthwqVCSIHddta', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'd6149e48543811f097453417ebbed40a', 'active', '2025-06-28 16:15:10', NULL),
('aadaec379b964a44ac33896816f752ad', 'approve_tree', 'approve_tree@example.com', '$2b$10$TjRr6GYuYLa1rPWIsrZvH.d3NzGMNJZNH4saItXzUmr571X0/tFrW', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'bf4f9c05543611f097453417ebbed40a', 'active', '2025-06-28 16:14:22', NULL),
('cd257e3d337941e5ac61f5ea9de99e92', 'testuser', 'test@example.com', '$2b$10$8WSiP3Pdf9E64Avdyg4ua.nDMMGMZHf9UiWZi/MItcGt1YtQmB9ku', 'ทดสอบ', 'โมเดล', 'other', '1234567890123', '0812345678', '123/4 ถ.ทดสอบ', 'Thailand', 'Bangkok', '10200', NULL, '2e950612491a11f08b210242ac120002', 'active', '2025-06-29 04:58:01', NULL),
('f31524fdbb9f4460b7c5f80fda33cf08', 'approve_two', 'approve_two@example.com', '$2b$10$1Pa56mRTUNTwhJEfz09iGOkXH2.motGkC/ywzWwZyu509UnujRp52', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'bf4f9c05543611f097453417ebbed40a', 'active', '2025-06-28 16:14:13', NULL),
('f9591a0215794225b088d53b6d2ef37d', 'staff_one', 'staff_one@example.com', '$2b$10$aIP0lKPI/3KsHnVdC0kO3OSdYtsOBBf8GZMBCIiotzEElESr1qQuK', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'bf515beb543711f097453417ebbed40a', 'active', '2025-06-28 16:14:53', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_allowed_orgs`
--

CREATE TABLE `user_allowed_orgs` (
  `id` char(32) NOT NULL,
  `user_id` char(32) NOT NULL,
  `organization_id` char(32) NOT NULL,
  `granted_by` char(32) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_allowed_orgs`
--

INSERT INTO `user_allowed_orgs` (`id`, `user_id`, `organization_id`, `granted_by`, `created_at`) VALUES
('11fd87ab7ba8445e90a1b9c3e6627d7d', '8b06d87178544b52b9269eafc89c4cb0', 'd6149e48543811f097453417ebbed40a', '036354d67ec34f9eb28cd26c8b2ec26e', '2025-06-29 17:30:53'),
('22ec87db47f746808f92dae7ada5ae5b', 'aadaec379b964a44ac33896816f752ad', 'bf4f9c05543611f097453417ebbed40a', '036354d67ec34f9eb28cd26c8b2ec26e', '2025-06-29 17:29:58'),
('6de1396f8fa74f45a746f5d154f4931a', 'f31524fdbb9f4460b7c5f80fda33cf08', 'bf4f9c05543611f097453417ebbed40a', '036354d67ec34f9eb28cd26c8b2ec26e', '2025-06-29 17:30:08'),
('a801b8ec8c6c49dd8bd0a61ee8bcfe73', 'f9591a0215794225b088d53b6d2ef37d', 'bf515beb543711f097453417ebbed40a', '036354d67ec34f9eb28cd26c8b2ec26e', '2025-06-29 17:30:36'),
('c37f287316494e4e825275a7367c4d9f', '036354d67ec34f9eb28cd26c8b2ec26e', '2e950612491a11f08b210242ac120002', '036354d67ec34f9eb28cd26c8b2ec26e', '2025-06-29 17:27:15'),
('c985c4ea494640d58d9cc0f532ef309c', '5ed0cce547ea4898aca5ee633449c2fb', 'bf4f9c05543611f097453417ebbed40a', '036354d67ec34f9eb28cd26c8b2ec26e', '2025-06-29 17:27:49'),
('f6a48902ae67478590f3229beb85fc5a', '3699f1ea64684ac78b02afd1fb9b3cdd', 'bf4f9c05543611f097453417ebbed40a', '036354d67ec34f9eb28cd26c8b2ec26e', '2025-06-29 17:29:46');

-- --------------------------------------------------------

--
-- Table structure for table `user_roles`
--

CREATE TABLE `user_roles` (
  `user_role_id` char(32) NOT NULL COMMENT 'รหัสเชื่อมโยงผู้ใช้-บทบาท UUID v4 ไม่มีขีด (32 หลัก)',
  `user_id` char(32) NOT NULL COMMENT 'รหัสผู้ใช้ (FK → users.user_id)',
  `role_id` char(32) NOT NULL COMMENT 'รหัสบทบาท (FK → roles.role_id)',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่กำหนดบทบาทให้ผู้ใช้'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเชื่อมผู้ใช้กับบทบาท';

--
-- Dumping data for table `user_roles`
--

INSERT INTO `user_roles` (`user_role_id`, `user_id`, `role_id`, `created_at`) VALUES
('11b0f3cf586f4011a9404aa68601ff3c', 'f9591a0215794225b088d53b6d2ef37d', '687e5497bfdc447da1e6e4d98827b46c', '2025-06-29 10:24:25'),
('14cead2b702c446f8408fb67c551f41d', '8b06d87178544b52b9269eafc89c4cb0', '0527b784f86b49a9b3e80084e9cf7ce5', '2025-06-29 10:25:41'),
('6cd3526ddd2c4a9e9bb84bd0b28fa049', '5ed0cce547ea4898aca5ee633449c2fb', '850f38dc62364a8ca0adadce762a46b5', '2025-06-29 10:23:35'),
('9c9a2e4335b742baa0b155db15cc09f0', '036354d67ec34f9eb28cd26c8b2ec26e', '5e600f16228846a59f512dcda88b1fc0', '2025-06-29 10:22:54'),
('cb3b7a53383b4b3c95c076c34b8d4fd3', 'f9591a0215794225b088d53b6d2ef37d', 'ac171b33817c4b889666abe978e11baa', '2025-06-29 10:25:13'),
('cf494e1b7c534be28da35cd5600294b5', '8b06d87178544b52b9269eafc89c4cb0', '687e5497bfdc447da1e6e4d98827b46c', '2025-06-29 10:24:35'),
('e0957fefc8d54ab6ab1b1146ba84b922', 'f31524fdbb9f4460b7c5f80fda33cf08', '7d8729453319497eb7630914179975b4', '2025-06-29 10:25:27');

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

CREATE TABLE `vehicles` (
  `vehicle_id` char(32) NOT NULL COMMENT 'รหัสยานพาหนะแบบ UUID v4 ไม่มีขีด (32 หลัก)',
  `license_plate` varchar(20) NOT NULL COMMENT 'ทะเบียนรถ เช่น กข 1234',
  `type_id` char(32) NOT NULL COMMENT 'รหัสประเภทยานพาหนะ (FK → vehicle_types.type_id)',
  `brand_id` char(32) NOT NULL COMMENT 'รหัสยี่ห้อรถ (FK → vehicle_brands.brand_id)',
  `capacity` int(11) NOT NULL COMMENT 'จำนวนที่นั่ง',
  `color` varchar(50) DEFAULT NULL COMMENT 'สีของยานพาหนะ',
  `description` text DEFAULT NULL COMMENT 'รายละเอียดเพิ่มเติมของยานพาหนะ',
  `image_path` varchar(255) DEFAULT NULL COMMENT 'พาธหรือ URL รูปภาพของรถ',
  `is_public` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'สถานะเผยแพร่ (1=เผยแพร่, 0=ไม่เผยแพร่)',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่เพิ่มข้อมูลรถ'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเก็บข้อมูลยานพาหนะ';

--
-- Dumping data for table `vehicles`
--

INSERT INTO `vehicles` (`vehicle_id`, `license_plate`, `type_id`, `brand_id`, `capacity`, `color`, `description`, `image_path`, `is_public`, `created_at`) VALUES
('91b4266e4ba941999f2186fcfabe4625', '2ภภ 5678', '46c86c2abe4943fa9eaefd8d5390988e', '0054a92642a24ddfbc9b3a41c6a6f182', 4, 'ขาว', 'รถกระบะ Isuzu D-Max สีขาว', 'https://example.com/image.jpg', 1, '2025-06-29 04:39:27'),
('ce4c794c341c4ca9bc74d6484cdcbe22', '3ฒฒ 9012', '1bb3ecbfc708461fa6773b98263b561c', '4adbe2f19def47d1803bd7c375344be7', 4, 'ขาว', 'รถเก๋ง สีขาว', 'https://example.com/image.jpg', 1, '2025-06-29 04:42:45');

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_brands`
--

CREATE TABLE `vehicle_brands` (
  `brand_id` char(32) NOT NULL COMMENT 'รหัสยี่ห้อแบบ UUID v4 ไม่มีขีด (32 หลัก)',
  `name` varchar(50) NOT NULL COMMENT 'ชื่อยี่ห้อ เช่น Mitsubishi, Toyota',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่สร้างยี่ห้อ'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเก็บยี่ห้อของยานพาหนะ';

--
-- Dumping data for table `vehicle_brands`
--

INSERT INTO `vehicle_brands` (`brand_id`, `name`, `created_at`) VALUES
('0054a92642a24ddfbc9b3a41c6a6f182', 'Toyota', '2025-06-29 03:53:41'),
('10ac008cee404dcd9f27db9d476d6849', 'Great Wall Motors', '2025-06-29 03:56:17'),
('11f97600bf76480c86e94c28b91c53cb', 'Ducati', '2025-06-29 03:57:45'),
('1f77be61b12f459bbac2a625a9f95701', 'Hino', '2025-06-29 03:56:48'),
('21a0317dd2d041bead7e96c14fb32a04', 'Kia', '2025-06-29 03:56:05'),
('28096986aece42919d6c2d604daf2690', 'Suzuki รุ่น Let \' so', '2025-06-29 03:57:11'),
('31868b6b9fcd452ba93fc8e5a2d5f07a', 'Hyundai', '2025-06-29 03:55:54'),
('3407b7b806974ad380da4e03bb8e4075', 'MINI', '2025-06-29 03:55:39'),
('4382fb0318734898a3db18a84489f963', 'Volvo', '2025-06-29 03:55:18'),
('4541a487c93f4f108d88a106bd8ed05f', 'GPX', '2025-06-29 03:57:39'),
('45424e4042514b12999f8e5bda5bfa97', 'BYD (รถไฟฟ้า)', '2025-06-29 03:56:25'),
('4a2a8892225c438086499dec159a82bd', 'Suzuki', '2025-06-29 03:54:32'),
('4adbe2f19def47d1803bd7c375344be7', 'Nissan', '2025-06-29 03:54:07'),
('4e786e3ddd4b41fb9eebb1fd4acdefc7', 'Chevrolet', '2025-06-29 03:55:49'),
('51a1e0a6338b4a35ae834395a216c43f', 'Mitsubishi', '2025-06-29 03:54:14'),
('56851d9e508043809a52a771880594ea', 'Ford', '2025-06-29 03:55:44'),
('58f400a03d0b4b6abc6b2c89b0127478', 'Porsche', '2025-06-29 03:55:33'),
('627067d11c544523994e95d2de20ad00', 'BMW', '2025-06-29 03:54:59'),
('7b50337ef86d42c2a063c24b94925138', 'MITSUBISHI Triton DoubleCab 2.5 GLS 4x4', '2025-06-29 03:56:59'),
('90b3e11f9ed84853af439336e9b01334', 'Isuzu', '2025-06-29 03:54:46'),
('91b099dc6a42486987c4dd82498bc319', 'Subaru', '2025-06-29 03:54:25'),
('97feb0acd4804935864441fa3da83e1f', 'MG (Morris Garages)', '2025-06-29 03:56:11'),
('9977ac0a08bf4fc7b70159d2fd21f9e6', 'Volkswagen', '2025-06-29 03:55:12'),
('9a4c139d72be41fcb2bfae6c46d0f805', 'Tesla', '2025-06-29 03:57:56'),
('9e51cb4cce964e149e7b959b52b2540a', 'Tiger', '2025-06-29 03:57:34'),
('9ebcff4a133f47a0bde7cd6447938502', 'Audi', '2025-06-29 03:55:25'),
('a5920d6481b7455e82f53ba4337a0c76', 'Honda', '2025-06-29 03:54:00'),
('ce4b95b451ed4714a9644c6a9f7ea7ad', 'Kawasaki', '2025-06-29 03:57:27'),
('d24820d4872f491d9baab0d42f1ec9d4', 'Mazda', '2025-06-29 03:54:19'),
('d48e2b73e1c547e7b79182efcd1bec75', 'Yamaha', '2025-06-29 03:56:54'),
('e44db22454e142a49ec7df38424ef3df', 'Changan', '2025-06-29 03:56:31'),
('ed975bb17ae34d93b29fc5fcf9c6e89d', 'Yamaha Fino', '2025-06-29 03:57:05'),
('f8410dae606b45a8aca44a77ced9e2ec', 'Mercedes-Benz', '2025-06-29 03:54:53');

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_equipments`
--

CREATE TABLE `vehicle_equipments` (
  `vehicle_equipment_id` char(32) NOT NULL COMMENT 'รหัสเชื่อมโยงรถ-อุปกรณ์ UUID v4 ไม่มีขีด (32 หลัก)',
  `vehicle_id` char(32) NOT NULL COMMENT 'รหัสรถ (FK → vehicles.vehicle_id)',
  `equipment_id` char(32) NOT NULL COMMENT 'รหัสอุปกรณ์เสริม (FK → equipments.equipment_id)',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่เพิ่มอุปกรณ์ให้รถ'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเชื่อมรถกับอุปกรณ์เสริม';

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_types`
--

CREATE TABLE `vehicle_types` (
  `type_id` char(32) NOT NULL COMMENT 'รหัสประเภทยานพาหนะแบบ UUID v4 ไม่มีขีด (32 หลัก)',
  `name` varchar(50) NOT NULL COMMENT 'ชื่อประเภท เช่น รถกระบะ, รถตู้',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'วันที่สร้างประเภทยานพาหนะ'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ตารางเก็บประเภทของยานพาหนะ';

--
-- Dumping data for table `vehicle_types`
--

INSERT INTO `vehicle_types` (`type_id`, `name`, `created_at`) VALUES
('02c1a498157d444ab72c78b3a12c3645', 'รถมินิบัส', '2025-06-29 03:53:10'),
('1bb3ecbfc708461fa6773b98263b561c', 'รถเก๋ง (Sedan)', '2025-06-29 03:50:31'),
('3dd6ba6d46924605a22a5cb4a1316995', 'รถมอเตอร์ไซค์ทั่วไป (Standard)', '2025-06-29 03:51:20'),
('46c86c2abe4943fa9eaefd8d5390988e', 'รถกระบะ CAB 4 ประตู', '2025-06-29 03:52:51'),
('50b5c7a595524136a72a2bbbc93be3e7', 'รถโดยสาร (Bus)', '2025-06-29 03:50:55'),
('6ba7befc5d014e72b3f1852483b2b237', 'รถกระบะ (Pickup Truck)', '2025-06-29 03:51:11'),
('704b2c763d2f48b19c27a988a85b15df', 'รถตู้ (Van)', '2025-06-29 03:51:03'),
('76ab88d13a6942df8b97412c49d23f59', 'รถบรรทุกเล็ก 6 ล้อ', '2025-06-29 03:52:59'),
('97a41815af2e441da88e780c077f258a', 'รถบรรทุก 10 ล้อ', '2025-06-29 03:53:04'),
('b3ed5ca016bf4bfc96107eb4739b6360', 'รถกระบะ CAB 2 ประตู', '2025-06-29 03:52:44'),
('e94799b7bd8549a181dba1482e8d3e8e', 'รถบรรทุก 10 ล้อ', '2025-06-29 03:53:04');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `approvals`
--
ALTER TABLE `approvals`
  ADD PRIMARY KEY (`approval_id`),
  ADD KEY `fk_apv_booking` (`booking_id`),
  ADD KEY `fk_apv_user` (`approver_id`),
  ADD KEY `step_id` (`step_id`);

--
-- Indexes for table `approval_flows`
--
ALTER TABLE `approval_flows`
  ADD PRIMARY KEY (`flow_id`);

--
-- Indexes for table `approval_steps`
--
ALTER TABLE `approval_steps`
  ADD PRIMARY KEY (`step_id`),
  ADD KEY `flow_id` (`flow_id`),
  ADD KEY `role_id` (`role_id`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `fk_al_user` (`user_id`);

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `fk_b_user` (`user_id`),
  ADD KEY `fk_b_vehicle` (`vehicle_id`),
  ADD KEY `fk_b_driver` (`driver_id`),
  ADD KEY `flow_id` (`flow_id`);

--
-- Indexes for table `booking_approval_logs`
--
ALTER TABLE `booking_approval_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `step_id` (`step_id`),
  ADD KEY `approved_by` (`approved_by`);

--
-- Indexes for table `booking_approval_status`
--
ALTER TABLE `booking_approval_status`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `flow_id` (`flow_id`);

--
-- Indexes for table `booking_equipments`
--
ALTER TABLE `booking_equipments`
  ADD PRIMARY KEY (`booking_equipment_id`),
  ADD KEY `fk_be_booking` (`booking_id`),
  ADD KEY `fk_be_equipment` (`equipment_id`);

--
-- Indexes for table `drivers`
--
ALTER TABLE `drivers`
  ADD PRIMARY KEY (`driver_id`);

--
-- Indexes for table `equipments`
--
ALTER TABLE `equipments`
  ADD PRIMARY KEY (`equipment_id`);

--
-- Indexes for table `jwt_blacklist`
--
ALTER TABLE `jwt_blacklist`
  ADD PRIMARY KEY (`jti`);

--
-- Indexes for table `organizations`
--
ALTER TABLE `organizations`
  ADD PRIMARY KEY (`organization_id`),
  ADD KEY `fk_org_parent` (`parent_id`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`permission_id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD PRIMARY KEY (`token_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`role_id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD PRIMARY KEY (`role_permission_id`),
  ADD KEY `fk_rp_role` (`role_id`),
  ADD KEY `fk_rp_permission` (`permission_id`);

--
-- Indexes for table `system_files`
--
ALTER TABLE `system_files`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_file_type` (`file_type`);

--
-- Indexes for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`),
  ADD KEY `idx_setting_key` (`setting_key`),
  ADD KEY `idx_is_public` (`is_public`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `fk_users_organization` (`organization_id`);

--
-- Indexes for table `user_allowed_orgs`
--
ALTER TABLE `user_allowed_orgs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `organization_id` (`organization_id`);

--
-- Indexes for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD PRIMARY KEY (`user_role_id`),
  ADD KEY `fk_ur_user` (`user_id`),
  ADD KEY `fk_ur_role` (`role_id`);

--
-- Indexes for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`vehicle_id`),
  ADD UNIQUE KEY `license_plate` (`license_plate`),
  ADD KEY `fk_vehicle_type` (`type_id`),
  ADD KEY `fk_vehicle_brand` (`brand_id`);

--
-- Indexes for table `vehicle_brands`
--
ALTER TABLE `vehicle_brands`
  ADD PRIMARY KEY (`brand_id`);

--
-- Indexes for table `vehicle_equipments`
--
ALTER TABLE `vehicle_equipments`
  ADD PRIMARY KEY (`vehicle_equipment_id`),
  ADD KEY `fk_ve_vehicle` (`vehicle_id`),
  ADD KEY `fk_ve_equipment` (`equipment_id`);

--
-- Indexes for table `vehicle_types`
--
ALTER TABLE `vehicle_types`
  ADD PRIMARY KEY (`type_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `system_files`
--
ALTER TABLE `system_files`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_settings`
--
ALTER TABLE `system_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `approvals`
--
ALTER TABLE `approvals`
  ADD CONSTRAINT `approvals_ibfk_1` FOREIGN KEY (`step_id`) REFERENCES `approval_steps` (`step_id`),
  ADD CONSTRAINT `fk_apv_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
  ADD CONSTRAINT `fk_apv_user` FOREIGN KEY (`approver_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `approval_steps`
--
ALTER TABLE `approval_steps`
  ADD CONSTRAINT `approval_steps_ibfk_1` FOREIGN KEY (`flow_id`) REFERENCES `approval_flows` (`flow_id`),
  ADD CONSTRAINT `approval_steps_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`);

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `fk_al_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`flow_id`) REFERENCES `approval_flows` (`flow_id`),
  ADD CONSTRAINT `fk_b_driver` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`),
  ADD CONSTRAINT `fk_b_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_b_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`vehicle_id`);

--
-- Constraints for table `booking_approval_logs`
--
ALTER TABLE `booking_approval_logs`
  ADD CONSTRAINT `booking_approval_logs_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
  ADD CONSTRAINT `booking_approval_logs_ibfk_2` FOREIGN KEY (`step_id`) REFERENCES `approval_steps` (`step_id`),
  ADD CONSTRAINT `booking_approval_logs_ibfk_3` FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `booking_approval_status`
--
ALTER TABLE `booking_approval_status`
  ADD CONSTRAINT `booking_approval_status_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
  ADD CONSTRAINT `booking_approval_status_ibfk_2` FOREIGN KEY (`flow_id`) REFERENCES `approval_flows` (`flow_id`);

--
-- Constraints for table `booking_equipments`
--
ALTER TABLE `booking_equipments`
  ADD CONSTRAINT `fk_be_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
  ADD CONSTRAINT `fk_be_equipment` FOREIGN KEY (`equipment_id`) REFERENCES `equipments` (`equipment_id`),
  ADD CONSTRAINT `fk_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
  ADD CONSTRAINT `fk_equipment` FOREIGN KEY (`equipment_id`) REFERENCES `equipments` (`equipment_id`);

--
-- Constraints for table `organizations`
--
ALTER TABLE `organizations`
  ADD CONSTRAINT `fk_org_parent` FOREIGN KEY (`parent_id`) REFERENCES `organizations` (`organization_id`);

--
-- Constraints for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD CONSTRAINT `fk_rt_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD CONSTRAINT `fk_rp_permission` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`permission_id`),
  ADD CONSTRAINT `fk_rp_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_organization` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`);

--
-- Constraints for table `user_allowed_orgs`
--
ALTER TABLE `user_allowed_orgs`
  ADD CONSTRAINT `user_allowed_orgs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `user_allowed_orgs_ibfk_2` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`);

--
-- Constraints for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `fk_ur_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`),
  ADD CONSTRAINT `fk_ur_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD CONSTRAINT `fk_vehicle_brand` FOREIGN KEY (`brand_id`) REFERENCES `vehicle_brands` (`brand_id`),
  ADD CONSTRAINT `fk_vehicle_type` FOREIGN KEY (`type_id`) REFERENCES `vehicle_types` (`type_id`);

--
-- Constraints for table `vehicle_equipments`
--
ALTER TABLE `vehicle_equipments`
  ADD CONSTRAINT `fk_ve_equipment` FOREIGN KEY (`equipment_id`) REFERENCES `equipments` (`equipment_id`),
  ADD CONSTRAINT `fk_ve_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`vehicle_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
