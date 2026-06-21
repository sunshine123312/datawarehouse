#!/bin/bash

# 日志生成器停止脚本
echo "-------- 停止日志生成器 --------"
ps -ef | grep "log-generator" | grep -v grep | awk "{print \$2}" | xargs kill -2
echo "日志生成器已停止"
