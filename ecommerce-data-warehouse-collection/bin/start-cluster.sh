#!/bin/bash
# ========== 启动 集群 ==========
echo "========== 启动 hadoop集群 =========="
/opt/module/hadoop/sbin/start-dfs.sh
/opt/module/hadoop/sbin/start-yarn.sh

echo "========== zookeeper 启动 =========="
for host in hadoop102 hadoop103 hadoop104; do
    echo "---------- zookeeper $host 启动 ------------"
    ssh $host "/opt/module/zookeeper/bin/zkServer.sh start"
done

echo "========== 启动 hadoop102 采集flume =========="
ssh hadoop102 "nohup /opt/module/flume/bin/flume-ng agent -n a1 -c /opt/module/flume/conf -f /opt/module/flume/conf/flume-kafka.conf -Dflume.root.logger=INFO,console >/dev/null 2>&1 &"

echo "========== 启动 hadoop103 采集flume =========="
ssh hadoop103 "nohup /opt/module/flume/bin/flume-ng agent -n a1 -c /opt/module/flume/conf -f /opt/module/flume/conf/flume-kafka.conf -Dflume.root.logger=INFO,console >/dev/null 2>&1 &"

echo "========== 启动 Kafka =========="
for host in hadoop102 hadoop103 hadoop104; do
    echo "-------启动 $host Kafka-------"
    ssh $host "/opt/module/kafka/bin/kafka-server-start.sh -daemon /opt/module/kafka/config/server.properties"
done

echo "========== 启动 hadoop104 消费flume =========="
ssh hadoop104 "nohup /opt/module/flume/bin/flume-ng agent -n a1 -c /opt/module/flume/conf -f /opt/module/flume/conf/flume-hdfs.conf -Dflume.root.logger=INFO,console >/dev/null 2>&1 &"

echo "========== 启动 KafkaManager =========="
nohup java -jar /opt/module/kafka-manager/kafka-manager-*.jar >/dev/null 2>&1 &

echo "========== 创建 HDFS 数仓目录 =========="
hadoop fs -mkdir -p /warehouse/ods/event_log
hadoop fs -mkdir -p /warehouse/ods/order_info
hadoop fs -mkdir -p /warehouse/ods/user_info
hadoop fs -mkdir -p /warehouse/ods/sku_info
hadoop fs -mkdir -p /warehouse/ods/payment_info
hadoop fs -mkdir -p /warehouse/ods/category_info
hadoop fs -mkdir -p /warehouse/dwd
hadoop fs -mkdir -p /warehouse/dws
hadoop fs -mkdir -p /warehouse/ads

echo "========== 集群启动完成 =========="
