# 系统架构说明

## 一、整体架构

### 1.1 数据流转路径

```
用户行为日志（埋点）
    │
    ▼
Nginx 日志（hadoop102）
    │
    ▼
Flume 采集（hadoop102）—— 实时监控日志文件
    │
    ▼
Kafka 消息队列（hadoop102/103/104）
    │  └─ Topic: TOPIC_START / TOPIC_EVENT
    ▼
Flume 消费（hadoop104）—— 从 Kafka 拉取数据写入 HDFS
    │
    ▼
HDFS 原始数据层（ODS）
    │
    ▼
Hive 数仓分层：ODS → DWD → DWS → ADS
    │
    ▼
MySQL / 报表展示
```

### 1.2 组件版本

| 组件          | 版本    |
|---------------|---------|
| Hadoop        | 3.1.3   |
| ZooKeeper     | 3.5.7   |
| Kafka         | 2.4.1   |
| Flume         | 1.9.0   |
| JDK           | 1.8     |

## 二、各服务详细配置

### 2.1 Hadoop

- 3 节点：hadoop102 (主)、hadoop103、hadoop104
- NameNode / SecondaryNameNode / ResourceManager 分别在不同节点
- 副本数：3
- 数据块大小：128MB

### 2.2 ZooKeeper

- 3 节点奇数部署
- myid：hadoop102→1, hadoop103→2, hadoop104→3
- 端口：2181
- 选举端口：3888

### 2.3 Kafka

- 3 节点
- broker.id：0 (hadoop102), 1 (hadoop103), 2 (hadoop104)
- 分区数：3
- 副本因子：3

### 2.4 Flume

- **采集 Flume**（hadoop102）：TailDir Source → Kafka Channel → Kafka Sink
- **消费 Flume**（hadoop104）：Kafka Source → File Channel → HDFS Sink

## 三、目录结构（Hadoop102）

```
/opt/module/
├── hadoop-3.1.3/
├── zookeeper-3.5.7/
├── kafka_2.12-2.4.1/
├── apache-flume-1.9.0/
└── applog/              ← 日志生成器输出目录

/opt/software/           ← 安装包存放

/opt/module/hadoop-3.1.3/data/   ← Hadoop 数据目录
/opt/module/hadoop-3.1.3/logs/   ← Hadoop 日志目录
```
