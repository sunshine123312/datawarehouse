#!/bin/bash
# ========== 电商模拟数据生成器 ==========
# 生成用户行为日志: 页面浏览、加购、收藏、下单、支付
# 每天按小时滚动生成，写入 /opt/module/applog/log/

LOG_DIR="/opt/module/applog/log"
mkdir -p $LOG_DIR

# 事件类型权重
EVENTS=("pageview" "cart" "favor" "order" "payment")
WEIGHTS=(50 20 15 10 5)

generate_user_id() {
    echo $(( RANDOM % 1000 + 1 ))
}

generate_sku_id() {
    echo $(( RANDOM % 1000 + 1 ))
}

generate_category_id() {
    echo $(( RANDOM % 100 + 1 ))
}

generate_timestamp() {
    local hour=$1
    local min=$(( RANDOM % 60 ))
    local sec=$(( RANDOM % 60 ))
    printf "%02d%02d%02d" "$hour" "$min" "$sec"
}

pick_event() {
    local r=$(( RANDOM % 100 ))
    local cum=0
    for i in "${!EVENTS[@]}"; do
        cum=$(( cum + WEIGHTS[i] ))
        if [ $r -lt $cum ]; then
            echo "${EVENTS[i]}"
            return
        fi
    done
    echo "pageview"
}

generate_log_line() {
    local event=$1
    local uid=$2
    local sku=$3
    local cat=$4
    local ts=$5
    local action_id=$(date +%s)$(( RANDOM % 10000 ))

    case $event in
        pageview)
            echo "{\"action_id\":\"view_$action_id\",\"uid\":$uid,\"sku_id\":$sku,\"category_id\":$cat,\"action\":\"pageview\",\"ts\":\"$ts\",\"stay_seconds\":$((RANDOM%300+1))}"
            ;;
        cart)
            echo "{\"action_id\":\"cart_$action_id\",\"uid\":$uid,\"sku_id\":$sku,\"category_id\":$cat,\"action\":\"add_cart\",\"ts\":\"$ts\",\"count\":$((RANDOM%5+1))}"
            ;;
        favor)
            echo "{\"action_id\":\"fav_$action_id\",\"uid\":$uid,\"sku_id\":$sku,\"category_id\":$cat,\"action\":\"favor\",\"ts\":\"$ts\"}"
            ;;
        order)
            local amount=$(awk "BEGIN{printf \"%.2f\", $((RANDOM%1000+1)) + RANDOM}")
            echo "{\"action_id\":\"ord_$action_id\",\"uid\":$uid,\"sku_id\":$sku,\"category_id\":$cat,\"action\":\"order\",\"ts\":\"$ts\",\"amount\":$amount,\"payment_type\":$((RANDOM%4+1))}"
            ;;
        payment)
            local amount=$(awk "BEGIN{printf \"%.2f\", $((RANDOM%1000+1)) + RANDOM}")
            echo "{\"action_id\":\"pay_$action_id\",\"uid\":$uid,\"sku_id\":$sku,\"category_id\":$cat,\"action\":\"payment\",\"ts\":\"$ts\",\"amount\":$amount}"
            ;;
    esac
}

echo "========== 开始生成模拟日志 =========="
echo "日志目录: $LOG_DIR"

while true; do
    for (( hour=0; hour<24; hour++ )); do
        # 每个小时生成不同量的数据 (模拟真实流量)
        case $hour in
            0|1|2|3|4|5) batch=50;;    # 凌晨低峰
            6|7|8|22|23) batch=200;;     # 早间/晚间
            9|10|11|14|15) batch=500;;   # 日间高峰
            12|13) batch=300;;           # 午休
            16|17|18) batch=400;;        # 下午
            19|20|21) batch=600;;        # 晚间黄金时段
            *) batch=300;;
        esac

        log_file="$LOG_DIR/app.$(date +%Y%m%d).$hour.log"

        for (( i=0; i<batch; i++ )); do
            uid=$(generate_user_id)
            sku=$(generate_sku_id)
            cat=$(generate_category_id)
            event=$(pick_event)
            ts=$(generate_timestamp "$hour")
            generate_log_line "$event" "$uid" "$sku" "$cat" "$ts" >> "$log_file"
        done

        echo "[$(date '+%H:%M:%S')] 生成 $hour 时数据: $batch 条 -> $log_file"
        sleep 2
    done

    # 跨日切文件
    echo "========== 完成一天数据生成，等待下一轮 =========="
    sleep 60
done
