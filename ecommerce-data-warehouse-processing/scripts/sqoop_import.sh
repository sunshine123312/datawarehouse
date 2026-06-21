#!/bin/bash
# ========== Sqoop 全量/增量导入 MySQL 业务数据到 HDFS ==========
# 前置: MySQL中已创建电商业务库 ecommerce_db
# 需要导入的表: order_info, user_info, sku_info, payment_info, category_info

MYSQL_CONN="jdbc:mysql://hadoop102:3306/ecommerce_db?useSSL=false&characterEncoding=utf-8"
MYSQL_USER="root"
MYSQL_PWD="root"

HDFS_BASE="/warehouse/ods"
DT=$(date +%Y%m%d)

import_table() {
    local table=$1
    local hdfs_path=$2
    local incremental=$3

    echo "========== 导入表: $table =========="

    CMD="sqoop import \
        --connect $MYSQL_CONN \
        --username $MYSQL_USER \
        --password $MYSQL_PWD \
        --table $table \
        --target-dir $hdfs_path/$DT \
        --delete-target-dir \
        --fields-terminated-by '\t' \
        --num-mappers 1 \
        --as-textfile"

    if [ "$incremental" = "true" ]; then
        CMD="$CMD --check-column create_time --incremental append --last-value $(date -d '-1 day' +%Y-%m-%d)"
    fi

    eval $CMD
    echo "表 $table 导入完成 -> $hdfs_path/$DT"
}

# 导入各表
import_table "order_info"    "$HDFS_BASE/order_info"
import_table "user_info"     "$HDFS_BASE/user_info"
import_table "sku_info"      "$HDFS_BASE/sku_info"
import_table "payment_info"  "$HDFS_BASE/payment_info"
import_table "category_info" "$HDFS_BASE/category_info"

echo "========== Sqoop 全量导入完成 =========="
echo "在 Hive 中执行 MSCK REPAIR TABLE 刷新分区:"
echo "  hive -e 'MSCK REPAIR TABLE ods_order_info;'"
echo "  hive -e 'MSCK REPAIR TABLE ods_user_info;'"
echo "  hive -e 'MSCK REPAIR TABLE ods_sku_info;'"
echo "  hive -e 'MSCK REPAIR TABLE ods_payment_info;'"
echo "  hive -e 'MSCK REPAIR TABLE ods_category_info;'"
