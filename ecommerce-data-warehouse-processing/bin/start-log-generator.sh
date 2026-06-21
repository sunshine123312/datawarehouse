#!/bin/bash
# ========== 启动模拟日志生成器 ==========
nohup bash /opt/module/applog/mock-log-generator.sh >/opt/module/applog/log/generator.log 2>&1 &
echo "========== 日志生成器已启动, PID: $! =========="
