-- ============================================
-- ETL: ODS → DWD (订单明细)
-- ============================================
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.mapred.mode=nonstrict;

INSERT OVERWRITE TABLE dwd_order_detail PARTITION (dt)
SELECT
    o.order_id,
    o.user_id,
    u.user_name,
    o.sku_id,
    s.sku_name,
    cat.category_name,
    o.sku_num,
    s.price,
    o.order_amount,
    o.payment_type,
    CASE o.payment_type
        WHEN 1 THEN "微信支付"
        WHEN 2 THEN "支付宝"
        WHEN 3 THEN "银联"
        WHEN 4 THEN "现金"
        ELSE "其他"
    END AS payment_type_name,
    o.order_status,
    CAST(substr(o.create_time,12,2) AS INT) AS create_hour,
    o.create_time,
    o.pay_time,
    o.dt
FROM ods_order_info o
LEFT JOIN ods_user_info u    ON o.user_id = u.user_id AND o.dt = u.dt
LEFT JOIN ods_sku_info s     ON o.sku_id  = s.sku_id  AND o.dt = s.dt
LEFT JOIN ods_category_info cat ON s.category_id = cat.category_id AND o.dt = cat.dt
WHERE o.dt = '${hiveconf:dt}';
