# 电商数仓项目 — E-Commerce Data Warehouse

## 项目架构

```
用户行为日志 → Flume → Kafka → Flume → HDFS → Hive(ODS) → Hive(DWD) → Hive(DWS) → Hive(ADS) → 可视化
业务数据(MySQL) → Sqoop → HDFS ────────────────────────────────────↑
```

## 集群服务器规划

| 服务                | hadoop102        | hadoop103        | hadoop104        |
|---------------------|------------------|------------------|------------------|
| HDFS NameNode       | ✓                |                  |                  |
| HDFS DataNode       | ✓                | ✓                | ✓                |
| SecondaryNameNode   |                  |                  | ✓                |
| YARN ResourceManager| ✓                |                  |                  |
| YARN NodeManager    | ✓                | ✓                | ✓                |
| ZooKeeper           | ✓                | ✓                | ✓                |
| Kafka               | ✓                | ✓                | ✓                |
| Flume(采集)         | ✓                | ✓                |                  |
| Flume(消费)         |                  |                  | ✓                |
| Hive                | ✓                |                  |                  |
| MySQL               | ✓                |                  |                  |
| Sqoop               | ✓                |                  |                  |
| Superset            | ✓                |                  |                  |
| 日志生成器          | ✓                |                  |                  |

## 数仓分层说明

| 分层 | 名称         | 说明                                           |
|------|--------------|------------------------------------------------|
| ODS  | 原始数据层   | 保持原样导入，存储用户行为日志与业务数据        |
| DWD  | 明细数据层   | 清洗、去重、维度退化、空值处理                   |
| DWS  | 服务数据层   | 按日/主题轻度聚合，用户行为宽表、订单宽表         |
| ADS  | 应用数据层   | 面向最终报表与可视化，GMV、TopN、留存率等        |

## 快速启动

```bash
# 1. 启动集群
bin/start-cluster.sh

# 2. 生成模拟数据
bin/start-log-generator.sh

# 3. 创建 Hive 表结构
hive -f hive/create_all_tables.sql

# 4. 执行 ETL
hive/etl/run_all_etl.sh

# 5. 可视化：访问 http://hadoop102:8088 打开 Superset
```

## 目录结构

```
ecommerce-data-warehouse/
├── bin/               # 集群启停 + 工具脚本
├── conf/              # Flume、LogGen 配置
├── data/              # 模拟数据生成器
├── hive/              # Hive DDL + ETL SQL
│   ├── ods/           # 原始数据层
│   ├── dwd/           # 明细数据层
│   ├── dws/           # 服务数据层
│   ├── ads/           # 应用数据层
│   └── etl/           # 分层 ETL 脚本
├── visualization/     # Superset + BI 查询
└── scripts/           # 辅助工具
```
