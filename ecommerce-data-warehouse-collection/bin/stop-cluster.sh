#!/bin/bash
# ========== 停止 集群 ==========
echo "========== 停止 Kafka =========="
for host in hadoop102 hadoop103 hadoop104; do
    echo "-------停止 $host Kafka-------"
    ssh $host "/opt/module/kafka/bin/kafka-server-stop.sh"
done

echo "========== 停止 Flume =========="
for host in hadoop102 hadoop103 hadoop104; do
    ssh $host "ps -ef | grep flume | grep -v grep | awk '{print $2}' | xargs -r kill -9"
done

echo "========== 停止 zookeeper =========="
for host in hadoop102 hadoop103 hadoop104; do
    ssh $host "/opt/module/zookeeper/bin/zkServer.sh stop"
done

echo "========== 停止 hadoop集群 =========="
/opt/module/hadoop/sbin/stop-yarn.sh
/opt/module/hadoop/sbin/stop-dfs.sh

echo "========== 集群已停止 =========="
