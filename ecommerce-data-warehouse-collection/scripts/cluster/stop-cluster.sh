#!/bin/bash

# ==================================================
# 电商数仓集群 — 一键停止脚本
# ==================================================

echo "========================================"
echo "         停止 集群"
echo "========================================"

# 1. 停止消费 Flume（hadoop104）
echo "-------- 停止 hadoop104 消费flume --------"
ssh hadoop104 "ps -ef | grep flume | grep kafka-flume-hdfs | awk '{print \$2}' | xargs kill -2"

# 2. 停止 Kafka 集群
echo ""
for host in hadoop102 hadoop103 hadoop104; do
    echo "------- 停止 $host Kafka -------"
    ssh $host "/opt/module/kafka/bin/kafka-server-stop.sh"
done

# 3. 停止采集 Flume
echo ""
echo "-------- 停止 hadoop102 采集flume --------"
ssh hadoop102 "ps -ef | grep flume | grep file-flume-kafka | awk '{print \$2}' | xargs kill -2"
echo "-------- 停止 hadoop103 采集flume --------"
ssh hadoop103 "ps -ef | grep flume | grep file-flume-kafka | awk '{print \$2}' | xargs kill -2"

# 4. 停止 ZooKeeper 集群
echo ""
for host in hadoop102 hadoop103 hadoop104; do
    echo "---------- zookeeper $host 停止 ------------"
    ssh $host "/opt/module/zookeeper/bin/zkServer.sh stop"
done

# 5. 停止 Hadoop 集群
echo ""
echo "-------- 停止 hadoop集群 -------"
$HADOOP_HOME/sbin/stop-yarn.sh
$HADOOP_HOME/sbin/stop-dfs.sh

# 6. 停止 KafkaManager
echo ""
echo "-------- 停止 KafkaManager -------"
ps -ef | grep kafka-manager | grep -v grep | awk '{print $2}' | xargs kill -2

echo ""
echo "========================================"
echo "         集群已停止！"
echo "========================================"
