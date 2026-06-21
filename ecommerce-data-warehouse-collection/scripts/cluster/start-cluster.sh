#!/bin/bash

# ==================================================
# 电商数仓集群 — 一键启动脚本
# 执行节点：hadoop102
# ==================================================

echo "========================================"
echo "         启动 集群"
echo "========================================"

# ------------------------------
# 1. 启动 Hadoop 集群
# ------------------------------
echo ""
echo "-------- 启动 hadoop集群 -------"

$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

# ------------------------------
# 2. 启动 ZooKeeper 集群（三台）
# ------------------------------
echo ""
for host in hadoop102 hadoop103 hadoop104; do
    echo "---------- zookeeper $host 启动 ------------"
    ssh $host "/opt/module/zookeeper/bin/zkServer.sh start"
done

# 等待 ZooKeeper 集群就绪
sleep 3

# ------------------------------
# 3. 启动 hadoop102 采集 Flume
# ------------------------------
echo ""
echo "--------启动 hadoop102 采集flume-------"
ssh hadoop102 "nohup /opt/module/flume/bin/flume-ng agent \
    --conf /opt/module/flume/conf \
    --name a1 \
    --conf-file /opt/module/flume/conf/file-flume-kafka.conf \
    -Dflume.root.logger=INFO,LOGFILE \
    >/opt/module/flume/logs/flume-collect.log 2>&1 &"

sleep 2

# ------------------------------
# 4. 启动 hadoop103 采集 Flume（若有第二个采集任务）
# ------------------------------
echo ""
echo "--------启动 hadoop103 采集flume-------"
ssh hadoop103 "nohup /opt/module/flume/bin/flume-ng agent \
    --conf /opt/module/flume/conf \
    --name a1 \
    --conf-file /opt/module/flume/conf/file-flume-kafka.conf \
    -Dflume.root.logger=INFO,LOGFILE \
    >/opt/module/flume/logs/flume-collect.log 2>&1 &"

sleep 2

# ------------------------------
# 5. 启动 Kafka 集群（三台）
# ------------------------------
echo ""
for host in hadoop102 hadoop103 hadoop104; do
    echo "-------启动 $host Kafka-------"
    ssh $host "/opt/module/kafka/bin/kafka-server-start.sh -daemon /opt/module/kafka/config/server.properties"
done

sleep 5

# ------------------------------
# 6. 启动 hadoop104 消费 Flume
# ------------------------------
echo ""
echo "--------启动 hadoop104 消费flume-------"
ssh hadoop104 "nohup /opt/module/flume/bin/flume-ng agent \
    --conf /opt/module/flume/conf \
    --name a1 \
    --conf-file /opt/module/flume/conf/kafka-flume-hdfs.conf \
    -Dflume.root.logger=INFO,LOGFILE \
    >/opt/module/flume/logs/flume-consume.log 2>&1 &"

sleep 2

# ------------------------------
# 7. 启动 KafkaManager
# ------------------------------
echo ""
echo "-------- 启动 KafkaManager -------"
nohup java -jar /opt/module/kafka-manager/kafka-manager.jar \
    >/opt/module/kafka-manager/logs/manager.log 2>&1 &

echo ""
echo "========================================"
echo "         电商数仓集群启动完成！"
echo "========================================"
echo ""
echo "Web 管理地址："
echo "  NameNode       http://hadoop102:9870"
echo "  ResourceManager http://hadoop102:8088"
echo "  KafkaManager   http://hadoop102:9000"
echo "========================================"
