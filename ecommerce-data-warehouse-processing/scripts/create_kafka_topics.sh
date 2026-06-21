#!/bin/bash
# ========== 创建 Kafka Topic ==========
KAFKA_HOME="/opt/module/kafka"
BOOTSTRAP="hadoop102:9092,hadoop103:9092,hadoop104:9092"

declare -A TOPICS=(
    ["topic_event_log"]="3"
    ["topic_order_info"]="3"
    ["topic_user_info"]="2"
)

echo "========== 创建/检查 Kafka Topic =========="
for topic in "${!TOPICS[@]}"; do
    partitions=${TOPICS[$topic]}
    $KAFKA_HOME/bin/kafka-topics.sh --create \
        --bootstrap-server $BOOTSTRAP \
        --topic $topic \
        --partitions $partitions \
        --replication-factor 2 \
        --if-not-exists
    echo "Topic $topic 创建完成 (partitions: $partitions)"
done

echo "========== 当前 Topic 列表 =========="
$KAFKA_HOME/bin/kafka-topics.sh --list --bootstrap-server $BOOTSTRAP
