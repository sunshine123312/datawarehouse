#!/bin/bash
# ========== 刷新 Hive 表分区 (MSCK) ==========
TABLES=("ods_event_log" "ods_order_info" "ods_user_info" "ods_sku_info" "ods_payment_info" "ods_category_info")

echo "========== 刷新 Hive 表分区 =========="
for table in "${TABLES[@]}"; do
    echo "修复 $table 分区..."
    hive -e "MSCK REPAIR TABLE $table;"
done

echo "========== 检查分区数 =========="
for table in "${TABLES[@]}"; do
    cnt=$(hive -e "SHOW PARTITIONS $table;" 2>/dev/null | wc -l)
    echo "$table: $cnt 个分区"
done
