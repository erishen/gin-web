-- 初始化数据库脚本
-- 这个脚本会在 MySQL 容器首次启动时自动执行

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS gin_web_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE gin_web_db;

-- 注意：GORM 的 AutoMigrate 会在应用启动时自动创建表结构
-- 这里不需要手动创建表
