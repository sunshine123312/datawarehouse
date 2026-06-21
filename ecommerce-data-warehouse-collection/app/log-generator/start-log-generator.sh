#!/bin/bash

# 日志生成器启动脚本
# 部署在 hadoop102

echo "-------- 启动日志生成器 --------"

# 检查日志目录
mkdir -p /opt/module/applog/log

# 运行日志生成器
java -jar /opt/module/applog/log-generator-1.0-SNAPSHOT-jar-with-dependencies.jar \
    --minutes 0 \
    --batch 100 \
    --sleep 2000 \
    --users 100 \
    --items 500 \
    --mode file \
    --logDir /opt/module/applog/log

echo "日志生成器已启动！后台运行中..."
