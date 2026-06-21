-- ============================================
-- ETL: DWD → DWS (商品销售日汇总)
-- ============================================
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

INSERT OVERWRITE TABLE dws_daily_product_sales PARTITION (dt)
SELECT
    e.sku_id,
    s.sku_name,
    s.category_name,
    s.price,
    SUM(CASE WHEN e.action = "pageview" THEN 1 ELSE 0 END) AS pageview_cnt,
    SUM(CASE WHEN e.action = "add_cart"  THEN 1 ELSE 0 END) AS cart_cnt,
    SUM(CASE WHEN e.action = "order"     THEN 1 ELSE 0 END) AS order_cnt,
    SUM(CASE WHEN e.action = "payment"   THEN 1 ELSE 0 END) AS pay_cnt,
    SUM(CASE WHEN e.action = "order"   THEN nvl(e.amount,0) ELSE 0 END) AS order_amount,
    SUM(CASE WHEN e.action = "payment" THEN nvl(e.amount,0) ELSE 0 END) AS pay_amount,
    CASE WHEN SUM(CASE WHEN e.action = "pageview" THEN 1 ELSE 0 END) = 0
         THEN 0.0
         ELSE ROUND(SUM(CASE WHEN e.action = "order" THEN 1 ELSE 0 END)
              / SUM(CASE WHEN e.action = "pageview" THEN 1 ELSE 0 END), 4)
    END AS conversion_rate,
    e.dt
FROM dwd_event_detail e
LEFT JOIN dwd_sku_dim s ON e.sku_id = s.sku_id AND e.dt = s.dt
WHERE e.dt = '${hiveconf:dt}'
GROUP BY e.sku_id, s.sku_name, s.category_name, s.price, e.dt;
