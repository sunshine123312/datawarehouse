#!/bin/bash

# ==================================================
# 电商数仓集群 — 状态检查脚本
# ==================================================

echo "========================================"
echo "         集群状态检查"
echo "========================================"

echo ""
echo "--- Hadoop ---"
echo "HDFS 安全模式状态:"
hdfs dfsadmin -safemode get 2>/dev/null || echo "  [WARN] HDFS 未运行"

echo ""
echo "HDFS 报告:"
hdfs dfsadmin -report 2>/dev/null | head -20 || echo "  [WARN] HDFS 未运行"

echo ""
echo "YARN 节点列表:"
yarn node -list 2>/dev/null || echo "  [WARN] YARN 未运行"

echo ""
echo "--- ZooKeeper ---"
for host in hadoop102 hadoop103 hadoop104; do
    echo "---------- zookeeper $host 状态 ------------"
    ssh $host "/opt/module/zookeeper/bin/zkServer.sh status"
done

echo ""
echo "--- Kafka ---"
for host in hadoop102 hadoop103 hadoop104; do
    echo "---------- kafka $host ------------"
    ssh $host "ps -ef | grep 'kafka\.Kafka' | grep -v grep | awk '{print \"  PID: \"\$2\"  Status: RUNNING\"}'"
done

echo ""
echo "--- Flume ---"
for host in hadoop102 hadoop103 hadoop104; do
    echo "---------- flume $host ------------"
    ssh $host "ps -ef | grep flume | grep -v grep | awk '{print \"  PID: \"\$2\"  \"\$NF}'"
done

echo ""
echo "=============================="
echo "检查完成！"
echo "=============================="
