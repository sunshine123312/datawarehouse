-- ============================================
-- ETL: DWD → DWS (订单统计 + 小时级流量)
-- ============================================
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

INSERT OVERWRITE TABLE dws_daily_order_stats PARTITION (dt)
SELECT
    COUNT(*)                                 AS total_orders,
    SUM(CASE WHEN order_status = "paid" THEN 1 ELSE 0 END) AS paid_orders,
    SUM(CASE WHEN order_status = "cancelled" THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(nvl(order_amount,0))                 AS total_order_amount,
    SUM(CASE WHEN order_status = "paid" THEN nvl(order_amount,0) ELSE 0 END) AS total_pay_amount,
    COUNT(DISTINCT user_id)                  AS total_users,
    COUNT(DISTINCT CASE WHEN order_status = "paid" THEN user_id ELSE NULL END) AS paid_users,
    ROUND(AVG(nvl(order_amount,0)), 2)       AS avg_order_amount,
    ROUND(SUM(CASE WHEN order_status = "paid" THEN nvl(order_amount,0) ELSE 0 END)
        / NULLIF(COUNT(DISTINCT CASE WHEN order_status = "paid" THEN user_id ELSE NULL END), 0), 2) AS per_customer_price,
    dt
FROM dwd_order_detail
WHERE dt = '${hiveconf:dt}'
GROUP BY dt;

-- 小时级流量
INSERT OVERWRITE TABLE dws_hourly_traffic PARTITION (dt)
SELECT
    event_hour,
    COUNT(*)                                 AS pageview_cnt,
    COUNT(DISTINCT uid)                      AS uv,
    SUM(CASE WHEN action = "order"   THEN 1 ELSE 0 END) AS order_cnt,
    SUM(CASE WHEN action = "payment" THEN 1 ELSE 0 END) AS pay_cnt,
    dt
FROM dwd_event_detail
WHERE dt = '${hiveconf:dt}'
GROUP BY event_hour, dt;
