# KafkaManager 使用指南

## 一、简介

KafkaManager 是一个开源的 Kafka 集群管理工具，提供 Web UI 界面，
方便运维人员查看和管理 Kafka 集群、Topic、分区、消费组等。

本项目将其作为电商数仓消息队列的管理端，部署在 hadoop102。

## 二、启动与访问

```bash
# 启动
nohup java -jar /opt/module/kafka-manager/kafka-manager.jar \
    >/opt/module/kafka-manager/logs/manager.log 2>&1 &

# 访问地址
http://hadoop102:9000
```

## 三、常用功能

### 3.1 集群管理

1. 首次访问时，点击 **Add Cluster**
2. 填写集群信息：
   - **Cluster Name**: GmallKafkaCluster
   - **Cluster Zookeeper Hosts**: hadoop102:2181,hadoop103:2181,hadoop104:2181
   - Kafka Version: 2.4.1
   - Enable JMX Polling（可勾选）
   - 勾选 **Enable Auto Topic Creation**
3. 点击 **Save** 即可添加集群

### 3.2 Topic 管理

在 Topic 列表页面可以：
- **查看**：所有 Topic 的分区数、副本数、ISR 状态
- **创建**：点击 Create → 输入 Topic 名称、分区数 (3)、副本因子 (3)
- **删除**：选择 Topic → Delete
- **手动分区**：添加或减少分区（注意减少分区不可逆）

**项目所需 Topic 创建命令（命令行备选）**：
```bash
kafka-topics.sh --bootstrap-server hadoop102:9092 --create \
    --topic TOPIC_START --partitions 3 --replication-factor 3
kafka-topics.sh --bootstrap-server hadoop102:9092 --create \
    --topic TOPIC_EVENT --partitions 3 --replication-factor 3
kafka-topics.sh --bootstrap-server hadoop102:9092 --create \
    --topic TOPIC_LOG --partitions 3 --replication-factor 3
```

### 3.3 消费组监控

- **Consumer Groups** 页面查看所有消费组
- 查看 **Lag**（积压量）判断数据处理速度
- 当 Lag 持续增长时，需要增加消费组消费者或优化 Flume 性能

### 3.4 分区与 Broker 查看

- **Brokers** 页面：显示集群所有节点状态
- **Topics → Partition Details**：查看每个分区的 Leader、Replicas、ISR

## 四、使用场景

| 场景 | 操作 |
|------|------|
| 检查数据是否写入 | 进入 Topics → 选中 Topic → Simulate → 查看最后消息 |
| 判断数据积压 | Consumer Groups → 查看 Lag 指标 |
| Topic 扩容 | Topics → Add Partitions |
| 查看 Broker 健康 | Brokers → 查看每个节点是否在线 |

## 五、常见问题

### Q: 无法连接集群？
确认 ZooKeeper 已启动且端口可达：
```bash
telnet hadoop102 2181
```

### Q: 消费组不显示？
重启 Flume 消费端重新注册消费组，或检查 group.id 配置。
