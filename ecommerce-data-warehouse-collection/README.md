# 电商数仓项目 — E-Commerce Data Warehouse

基于 Hadoop 生态搭建的离线电商数仓系统，覆盖用户行为日志采集、消息队列缓冲、数据分层存储与分析全流程。

## 项目架构

```
┌─────────────────────────────────────────────────────┐
│                  数据源层                              │
│        App 埋点日志 → Nginx → LogGenerator            │
├─────────────────────────────────────────────────────┤
│                  采集传输层                            │
│   Flume（采集）→ Kafka（消息队列）→ Flume（消费）       │
│        hadoop102         hadoop102/103/104  hadoop104 │
├─────────────────────────────────────────────────────┤
│                  存储计算层                            │
│     HDFS ← YARN ← MapReduce / Hive / Spark            │
├─────────────────────────────────────────────────────┤
│                  调度与元数据                          │
│     KafkaManager ←  ZooKeeper ←  定时调度脚本         │
└─────────────────────────────────────────────────────┘
```

## 集群节点规划

| 主机        | 部署组件                                         |
|-------------|--------------------------------------------------|
| hadoop102   | NameNode, DataNode, ResourceManager, ZooKeeper, Kafka, Flume(采集) |
| hadoop103   | DataNode, NodeManager, ZooKeeper, Kafka          |
| hadoop104   | SecondaryNameNode, NodeManager, ZooKeeper, Kafka, Flume(消费) |

## 启动顺序（一键式）

```bash
1. 启动 Hadoop 集群
2. 启动 ZooKeeper 集群
3. 启动采集 Flume（hadoop102）
4. 启动 Kafka 集群（hadoop102/103/104）
5. 启动消费 Flume（hadoop104）
6. 启动日志生成器
7. KafkaManager 管理界面
```

详情请参阅各子文档：

- [系统架构说明](docs/architecture.md)
- [集群部署文档](docs/cluster-deploy.md)
- [KafkaManager 使用指南](docs/kafka-manager-guide.md)
- [一键启动脚本](scripts/cluster/start-cluster.sh)
