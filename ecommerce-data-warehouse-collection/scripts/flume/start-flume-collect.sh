#!/bin/bash

# Flume 采集端启动脚本
# 在 hadoop102 执行

echo "--------启动 hadoop102 采集flume-------"
nohup /opt/module/flume/bin/flume-ng agent \
    --conf /opt/module/flume/conf \
    --name a1 \
    --conf-file /opt/module/flume/conf/file-flume-kafka.conf \
    -Dflume.root.logger=INFO,LOGFILE \
    >/opt/module/flume/logs/flume-collect.log 2>&1 &

echo "采集 Flume 已启动！"
