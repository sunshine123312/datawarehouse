#!/bin/bash

# Flume 消费端启动脚本
# 在 hadoop104 执行

echo "--------启动 hadoop104 消费flume-------"
nohup /opt/module/flume/bin/flume-ng agent \
    --conf /opt/module/flume/conf \
    --name a1 \
    --conf-file /opt/module/flume/conf/kafka-flume-hdfs.conf \
    -Dflume.root.logger=INFO,LOGFILE \
    >/opt/module/flume/logs/flume-consume.log 2>&1 &

echo "消费 Flume 已启动！数据将从 Kafka 写入 HDFS"
