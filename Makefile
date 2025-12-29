.PHONY: help build up down restart logs ps clean test dev prod

# 默认目标
.DEFAULT_GOAL := help

# 变量定义
COMPOSE_FILE := docker-compose.yml
DEV_COMPOSE_FILE := docker-compose.dev.yml
APP_NAME := gin-web

# 颜色定义
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

## help: 显示帮助信息
help:
	@echo "$(BLUE)Gin Web Docker 部署 - Makefile 命令$(NC)"
	@echo ""
	@echo "$(GREEN)常用命令:$(NC)"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  /' | sed 's/:/$(GREEN):$(NC)/'
	@echo ""
	@echo "$(GREEN)环境相关:$(NC)"
	@echo "  dev$(NC)    - 开发环境部署（使用 SQLite）"
	@echo "  prod$(NC)   - 生产环境部署（使用 MySQL）"

## build: 构建镜像
build:
	@echo "$(BLUE)构建 Docker 镜像...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build

## up: 启动服务（生产环境）
up:
	@echo "$(BLUE)启动服务（生产环境）...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)服务已启动!$(NC)"
	@echo "应用地址: http://localhost:3000"

## down: 停止并删除容器
down:
	@echo "$(BLUE)停止服务...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down

## restart: 重启服务
restart:
	@echo "$(BLUE)重启服务...$(NC)"
	docker-compose -f $(COMPOSE_FILE) restart

## logs: 查看所有服务日志
logs:
	docker-compose -f $(COMPOSE_FILE) logs -f

## logs-app: 查看应用日志
logs-app:
	docker-compose -f $(COMPOSE_FILE) logs -f app

## logs-mysql: 查看 MySQL 日志（仅在使用 Docker MySQL 时可用）
logs-mysql:
	@echo "$(YELLOW)当前使用本地 MySQL，无 Docker 容器日志$(NC)"

## ps: 查看服务状态
ps:
	@echo "$(BLUE)服务状态:$(NC)"
	docker-compose -f $(COMPOSE_FILE) ps

## clean: 停止服务并删除数据卷
clean:
	@echo "$(RED)警告: 这将删除所有数据！$(NC)"
	@read -p "确认删除? (y/N): " confirm && [ "$$confirm" = "y" ]
	docker-compose -f $(COMPOSE_FILE) down -v
	@echo "$(GREEN)清理完成!$(NC)"

## test: 运行健康检查测试
test:
	@echo "$(BLUE)运行健康检查...$(NC)"
	@curl -s http://localhost:3000/ping | grep -q "pong" && \
		echo "$(GREEN)✓ 健康检查通过$(NC)" || \
		(echo "$(RED)✗ 健康检查失败$(NC)" && exit 1)

## dev: 启动开发环境（SQLite）
dev:
	@echo "$(BLUE)启动开发环境（SQLite）...$(NC)"
	docker-compose -f $(DEV_COMPOSE_FILE) up -d
	@echo "$(GREEN)开发环境已启动!$(NC)"
	@echo "应用地址: http://localhost:3000"

## prod: 启动生产环境（本地 MySQL）
prod:
	@echo "$(BLUE)启动生产环境（本地 MySQL）...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)生产环境已启动!$(NC)"
	@echo "应用地址: http://localhost:3000"

## prod-docker: 启动生产环境（Docker MySQL 容器）
prod-docker:
	@echo "$(BLUE)启动生产环境（Docker MySQL）...$(NC)"
	docker-compose -f docker-compose.mysql.yml up -d
	@echo "$(GREEN)生产环境已启动!$(NC)"
	@echo "应用地址: http://localhost:3000"

## rebuild: 重新构建并启动服务
rebuild:
	@echo "$(BLUE)重新构建并启动服务...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d --build
	@echo "$(GREEN)服务已重新构建并启动!$(NC)"

## exec: 进入应用容器
exec:
	docker-compose -f $(COMPOSE_FILE) exec app sh

## mysql: 进入本地 MySQL（需要本地 MySQL 运行）
mysql:
	mysql -u root -p

## db-shell: 进入本地数据库命令行
db-shell:
	mysql -u $$(DB_USER) -p$$(DB_PASSWORD) $$(DB_NAME)

## backup: 备份数据库（本地 MySQL）
backup:
	@echo "$(BLUE)备份数据库...$(NC)"
	@mkdir -p backups
	mysqldump -u $$(DB_USER) -p$$(DB_PASSWORD) $$(DB_NAME) > backups/backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)备份完成!$(NC)"

## restore: 恢复数据库（需要指定备份文件，如: make restore FILE=backup_20250129_120000.sql）
restore:
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)错误: 请指定备份文件$(NC)"; \
		echo "用法: make restore FILE=backup_20250129_120000.sql"; \
		exit 1; \
	fi
	@echo "$(BLUE)恢复数据库从 $(FILE)...$(NC)"
	mysql -u $$(DB_USER) -p$$(DB_PASSWORD) $$(DB_NAME) < backups/$(FILE)
	@echo "$(GREEN)恢复完成!$(NC)"

## stats: 查看容器资源使用情况
stats:
	docker stats $(APP_NAME)-app --no-stream

## install: 安装依赖（本地开发）
install:
	@echo "$(BLUE)安装 Go 依赖...$(NC)"
	go mod download

## setup-db: 设置本地 MySQL 数据库
setup-db:
	@echo "$(BLUE)设置本地 MySQL 数据库...$(NC)"
	@./setup-local-db.sh

## run: 本地运行（不使用 Docker）
run:
	@echo "$(BLUE)本地运行应用...$(NC)"
	@go run main.go router.go user.go

## fmt: 格式化代码
fmt:
	@echo "$(BLUE)格式化代码...$(NC)"
	go fmt ./...

## vet: 代码静态检查
vet:
	@echo "$(BLUE)运行 go vet...$(NC)"
	go vet ./...

## test-unit: 运行单元测试
test-unit:
	@echo "$(BLUE)运行单元测试...$(NC)"
	go test -v ./...

## all: 格式化、检查并运行测试
all: fmt vet test-unit
	@echo "$(GREEN)所有检查通过!$(NC)"
