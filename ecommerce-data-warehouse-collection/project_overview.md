# 电商数仓项目完整概述

## 一、项目背景

在 hadoop102/hadoop103/hadoop104 三节点集群上搭建电商数仓，
从用户行为日志和业务数据库采集数据，经过 Flume → Kafka → HDFS 的实时通道，
最终在 Hive 中构建四层数仓模型，通过 Superset 实现可视化。

## 二、完整数据流

```
┌───────────────┐    ┌────────────────┐    ┌──────────────┐    ┌──────────────────┐
│ 用户行为日志   │ →  │ Flume(采集)    │ →  │ Kafka        │ →  │ Flume(消费)       │
│ (hadoop102)   │    │ (hadoop102/103)│    │ (3节点集群)   │    │ (hadoop104)       │
└───────────────┘    └────────────────┘    └──────────────┘    └──────────────────┘
                                                                      ↓
┌───────────────┐    ┌────────────────┐                          ┌──────────────┐
│ MySQL 业务数据 │ →  │ Sqoop          │ ──────────────────────→  │ HDFS         │
│ (hadoop102)   │    │ (hadoop102)    │                          │ /warehouse   │
└───────────────┘    └────────────────┘                          └──────┬───────┘
                                                                        ↓
┌───────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ Superset  │ ←  │ ADS      │ ←  │ DWS      │ ←  │ DWD      │ ←  │ ODS      │
│ 可视化     │    │ 应用层    │    │ 服务层    │    │ 明细层    │    │ 原始层    │
│ :8088     │    │ 报表      │    │ 聚合      │    │ 清洗      │    │ 存储      │
└───────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘
```

## 三、最简执行流程（首次搭建）

```bash
# Step 1: 启动集群
bin/start-cluster.sh

# Step 2: 初始化 MySQL 业务数据
mysql -uroot -proot < scripts/init_ecommerce_db.sql

# Step 3: 创建 Kafka Topic
scripts/create_kafka_topics.sh

# Step 4: 启动日志生成器
bin/start-log-generator.sh

# Step 5: 使用 Sqoop 导入业务数据到 HDFS
scripts/sqoop_import.sh

# Step 6: 刷新 Hive 分区
scripts/repair_hive_partitions.sh

# Step 7: 创建 Hive 表结构
hive -f hive/create_all_tables.sql

# Step 8: 执行 ETL
hive/etl/run_all_etl.sh

# Step 9: 安装并启动 Superset
# 参考 visualization/superset_setup.md

# Step 10: 导入 SQL 查询到 Superset
# 参考 visualization/sql_queries_for_bi.sql
```

## 四、数仓模型说明

| 分层 | 表名                          | 数据来源           | 说明                  |
|------|-------------------------------|-------------------|-----------------------|
| ODS  | ods_event_log                 | Flume→Kafka→HDFS  | 用户行为JSON原日志      |
| ODS  | ods_order_info / user_info / sku_info / payment_info / category_info | Sqoop→MySQL | 业务数据，TextFile |
| DWD  | dwd_event_detail              | ODS事件表 → 清洗   | 维度退化，JSON解析      |
| DWD  | dwd_order_detail              | ODS订单 → 多表JOIN | 退化维度，Parquet      |
| DWD  | dwd_user_dim / dwd_sku_dim    | ODS维度表 → 标签化  | 年龄分段，价格区间      |
| DWS  | dws_daily_user_behavior       | DWD事件明细        | 按用户+日轻度聚合       |
| DWS  | dws_daily_product_sales       | DWD事件明细+SKU    | 按商品+日聚合          |
| DWS  | dws_daily_order_stats         | DWD订单            | 订单KPI               |
| DWS  | dws_hourly_traffic            | DWD事件            | 小时级流量             |
| ADS  | ads_daily_revenue             | DWS订单统计        | GMV日报               |
| ADS  | ads_top_selling_products      | DWS商品销售        | TopN排行              |
| ADS  | ads_category_sales            | DWS商品销售        | 品类占比              |
| ADS  | ads_hourly_traffic_analysis   | DWS小时流量        | 小时级转化率           |
| ADS  | ads_user_value_segmentation   | DWS用户行为        | 高/中/低价值用户       |
| ADS  | ads_user_retention            | 用户注册+行为      | 留存率                |

## 五、可视化仪表盘

| 仪表盘 | 包含图表                          | 用途              |
|--------|----------------------------------|-------------------|
| 运营总览 | GMV趋势、订单KPI、品类占比、小时流量、用户分层、热销Top10 | 每日运营决策        |
| 商品分析 | 转化漏斗、Top20、品类排行、价格分布  | 商品策略           |
| 用户分析 | 活跃度、价值分层、留存、年龄分布      | 用户运营           |
