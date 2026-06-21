#!/bin/bash
# ========== 创建 HDFS 数仓目录 ==========
hadoop fs -mkdir -p /warehouse/ods/event_log
hadoop fs -mkdir -p /warehouse/ods/order_info
hadoop fs -mkdir -p /warehouse/ods/user_info
hadoop fs -mkdir -p /warehouse/ods/sku_info
hadoop fs -mkdir -p /warehouse/ods/payment_info
hadoop fs -mkdir -p /warehouse/ods/category_info
hadoop fs -mkdir -p /warehouse/dwd
hadoop fs -mkdir -p /warehouse/dws
hadoop fs -mkdir -p /warehouse/ads

echo "========== HDFS 数仓目录创建完成 =========="
hadoop fs -ls -R /warehouse
