#!/bin/bash
# ========== 全量ETL执行脚本 ==========
# 从ODS -> DWD -> DWS -> ADS 逐层处理
# 用法: bash run_all_etl.sh [日期 yyyyMMdd]  默认当天

if [ -n "$1" ]; then
    DT=$1
else
    DT=$(date +%Y%m%d)
fi

echo "=========================================="
echo "开始执行 ETL | 日期: $DT"
echo "=========================================="

BASE_DIR=$(cd "$(dirname "$0")" && pwd)
HIVE="hive"

# Step 1: ODS -> DWD
echo "---------- [1/5] ODS -> DWD 事件明细 ----------"
$HIVE -f $BASE_DIR/../etl/ods_to_dwd_event.sql -hiveconf dt=$DT

echo "---------- [2/5] ODS -> DWD 订单明细 ----------"
$HIVE -f $BASE_DIR/../etl/ods_to_dwd_order.sql -hiveconf dt=$DT

echo "---------- [3/5] ODS -> DWD 用户/商品维度 ----------"
$HIVE -f $BASE_DIR/../etl/ods_to_dwd_user.sql -hiveconf dt=$DT
$HIVE -f $BASE_DIR/../etl/ods_to_dwd_sku.sql -hiveconf dt=$DT

# Step 2: DWD -> DWS
echo "---------- [4/5] DWD -> DWS 聚合 ----------"
$HIVE -f $BASE_DIR/../etl/dwd_to_dws_user_behavior.sql -hiveconf dt=$DT
$HIVE -f $BASE_DIR/../etl/dwd_to_dws_product_sales.sql -hiveconf dt=$DT
$HIVE -f $BASE_DIR/../etl/dwd_to_dws_order_stats.sql -hiveconf dt=$DT

# Step 3: DWS -> ADS
echo "---------- [5/5] DWS -> ADS 报表 ----------"
$HIVE -f $BASE_DIR/../etl/dws_to_ads.sql -hiveconf dt=$DT

echo "=========================================="
echo "ETL 执行完成！日期: $DT"
echo "=========================================="
echo ""
echo "报表已生成，可通过 Superset 查看：http://hadoop102:8088"
