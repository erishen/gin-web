#!/bin/bash

# 检查 Go 是否已安装
if ! command -v go &> /dev/null; then
    echo "Go is not installed. Please install Go and try again."
    exit 1
fi

# 设置环境变量（如果有需要）
# export MY_ENV_VARIABLE=value
export GIN_MODE=release

# 运行 Go 程序
echo "Running Go program..."
go run main.go

# 检查程序是否成功运行
if [ $? -ne 0 ]; then
    echo "Failed to run Go program."
    exit 1
else
    echo "Go program ran successfully."
fi
