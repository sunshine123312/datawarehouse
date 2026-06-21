-- ============================================
-- ETL: DWS → ADS (应用层报表)
-- ============================================
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

-- ADS 1: GMV日报
INSERT OVERWRITE TABLE ads_daily_revenue
SELECT
    dt,
    total_pay_amount  AS total_gmv,
    paid_orders       AS total_orders,
    paid_users        AS total_users,
    avg_order_amount  AS avg_order_price,
    per_customer_price AS per_customer
FROM dws_daily_order_stats
WHERE dt = '${hiveconf:dt}';

-- ADS 2: 热销商品Top20
INSERT OVERWRITE TABLE ads_top_selling_products
SELECT
    dt,
    ROW_NUMBER() OVER (ORDER BY pay_amount DESC) AS rank,
    sku_id,
    sku_name,
    category_name,
    pay_amount,
    pay_cnt
FROM dws_daily_product_sales
WHERE dt = '${hiveconf:dt}'
ORDER BY pay_amount DESC
LIMIT 20;

-- ADS 3: 品类销售统计
INSERT OVERWRITE TABLE ads_category_sales
SELECT
    dt,
    category_name,
    SUM(pay_amount)   AS gmv,
    SUM(pay_cnt)      AS order_cnt,
    SUM(pay_cnt)      AS sku_sold_cnt,
    ROUND(SUM(pay_amount) / SUM(SUM(pay_amount)) OVER() * 100, 2) AS gmv_ratio
FROM dws_daily_product_sales
WHERE dt = '${hiveconf:dt}'
GROUP BY dt, category_name;

-- ADS 4: 小时级流量分析
INSERT OVERWRITE TABLE ads_hourly_traffic_analysis
SELECT
    dt,
    hour,
    pageview_cnt AS pv,
    uv,
    order_cnt,
    pay_cnt,
    CASE WHEN uv = 0 THEN 0.0
         ELSE ROUND(order_cnt / uv, 4)
    END AS conversion_rate
FROM dws_hourly_traffic
WHERE dt = '${hiveconf:dt}';

-- ADS 5: 用户价值分层
INSERT OVERWRITE TABLE ads_user_value_segmentation
SELECT
    dt,
    CASE
        WHEN pay_amount >= 1000 THEN "高价值(high)"
        WHEN pay_amount >= 100  THEN "中价值(medium)"
        ELSE "低价值(low)"
    END AS segment,
    COUNT(DISTINCT uid) AS user_cnt,
    SUM(pay_amount)     AS total_gmv,
    ROUND(SUM(payment_cnt) / COUNT(DISTINCT uid), 2) AS avg_order_freq,
    ROUND(SUM(pay_amount) / COUNT(DISTINCT uid), 2)  AS avg_customer_price,
    dt
FROM dws_daily_user_behavior
WHERE dt = '${hiveconf:dt}'
GROUP BY dt,
    CASE
        WHEN pay_amount >= 1000 THEN "高价值(high)"
        WHEN pay_amount >= 100  THEN "中价值(medium)"
        ELSE "低价值(low)"
    END;
