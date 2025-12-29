package main

import (
	"log"
	"os"

	"github.com/joho/godotenv"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var db *gorm.DB

func main() {
	// 尝试加载 .env 文件，如果不存在则忽略（Docker 环境中使用环境变量）
	err := godotenv.Load()
	if err != nil {
		log.Println("No .env file found, using environment variables")
	}

	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		log.Fatal("DATABASE_URL environment variable not set")
	}

	db, err = gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("Error connecting to database: %v", err)
	}

	// Auto Migrate User model
	err = db.AutoMigrate(&User{})
	if err != nil {
		log.Fatalf("Error migrating database schema: %v", err)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	r := setupRouter()
	r.Run(":" + port)
}
