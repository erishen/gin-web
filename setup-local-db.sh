#!/bin/bash

# 本地 MySQL 初始化脚本
# 用于创建数据库和用户

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "${BLUE}设置本地 MySQL 数据库...${NC}"

# 读取 root 密码
read -sp "请输入 MySQL root 密码（直接回车跳过）: " ROOT_PASSWORD
echo ""

# 数据库配置
DB_NAME="gin_web_db"
DB_USER="ginuser"
DB_PASSWORD="ginpassword"

# 构建 MySQL 命令
if [ -z "$ROOT_PASSWORD" ]; then
    MYSQL_CMD="mysql -u root"
else
    MYSQL_CMD="mysql -u root -p${ROOT_PASSWORD}"
fi

# 创建数据库
echo "${BLUE}创建数据库: ${DB_NAME}${NC}"
$MYSQL_CMD -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || {
    echo "${RED}数据库创建失败，请检查 root 密码是否正确${NC}"
    exit 1
}

# 创建用户并授权
echo "${BLUE}创建用户: ${DB_USER}${NC}"
$MYSQL_CMD -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';" 2>/dev/null
$MYSQL_CMD -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';" 2>/dev/null

echo "${BLUE}授权用户...${NC}"
$MYSQL_CMD -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';" 2>/dev/null
$MYSQL_CMD -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';" 2>/dev/null
$MYSQL_CMD -e "FLUSH PRIVILEGES;" 2>/dev/null

echo "${GREEN}✓ 数据库设置完成！${NC}"
echo ""
echo "数据库信息："
echo "  数据库名: ${DB_NAME}"
echo "  用户名: ${DB_USER}"
echo "  密码: ${DB_PASSWORD}"
echo ""
echo "请更新 .env 文件中的以下配置："
echo "  DB_USER=${DB_USER}"
echo "  DB_PASSWORD=${DB_PASSWORD}"
echo "  DB_NAME=${DB_NAME}"
