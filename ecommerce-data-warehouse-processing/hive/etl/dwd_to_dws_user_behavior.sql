-- ============================================
-- ETL: DWD → DWS (用户行为日汇总)
-- ============================================
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

INSERT OVERWRITE TABLE dws_daily_user_behavior PARTITION (dt)
SELECT
    uid,
    SUM(CASE WHEN action = "pageview" THEN 1 ELSE 0 END) AS pageview_cnt,
    SUM(CASE WHEN action = "add_cart"  THEN 1 ELSE 0 END) AS cart_cnt,
    SUM(CASE WHEN action = "favor"     THEN 1 ELSE 0 END) AS favor_cnt,
    SUM(CASE WHEN action = "order"     THEN 1 ELSE 0 END) AS order_cnt,
    SUM(CASE WHEN action = "payment"   THEN 1 ELSE 0 END) AS payment_cnt,
    SUM(CASE WHEN action = "order"   THEN nvl(amount,0) ELSE 0 END) AS order_amount,
    SUM(CASE WHEN action = "payment" THEN nvl(amount,0) ELSE 0 END) AS pay_amount,
    COUNT(DISTINCT event_hour) AS active_hours,
    dt
FROM dwd_event_detail
WHERE dt = '${hiveconf:dt}'
GROUP BY uid, dt;
