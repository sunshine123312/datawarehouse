# 预设仪表盘图表 SQL 查询
# 在 Superset SQL Lab 中运行这些查询，然后将结果创建为图表

-- ============================================
-- 图表1: GMV日报趋势
-- ============================================
SELECT
    dt,
    total_gmv,
    total_orders,
    per_customer
FROM ads_daily_revenue
ORDER BY dt DESC
LIMIT 30;

-- ============================================
-- 图表2: 热销商品Top10（条形图）
-- ============================================
SELECT
    rank,
    sku_name,
    pay_amount,
    pay_cnt
FROM ads_top_selling_products
WHERE dt = (SELECT MAX(dt) FROM ads_top_selling_products)
ORDER BY rank
LIMIT 10;

-- ============================================
-- 图表3: 品类销售占比（饼图）
-- ============================================
SELECT
    category_name,
    gmv,
    gmv_ratio
FROM ads_category_sales
WHERE dt = (SELECT MAX(dt) FROM ads_category_sales)
ORDER BY gmv DESC;

-- ============================================
-- 图表4: 小时级流量分析（折线图）
-- ============================================
SELECT
    concat(dt, " ", LPAD(CAST(hour AS STRING), 2, "0"), ":00") AS time_label,
    pv,
    uv,
    order_cnt,
    pay_cnt,
    conversion_rate
FROM ads_hourly_traffic_analysis
WHERE dt = (SELECT MAX(dt) FROM ads_hourly_traffic_analysis)
ORDER BY hour;

-- ============================================
-- 图表5: 用户价值分层（饼图/柱状图）
-- ============================================
SELECT
    segment,
    user_cnt,
    total_gmv,
    avg_customer_price
FROM ads_user_value_segmentation
WHERE dt = (SELECT MAX(dt) FROM ads_user_value_segmentation)
ORDER BY user_cnt DESC;

-- ============================================
-- 图表6: 订单概览KPI卡片
-- ============================================
SELECT
    dt,
    total_orders,
    paid_orders,
    cancelled_orders,
    total_order_amount,
    total_pay_amount,
    total_users,
    paid_users,
    avg_order_amount,
    per_customer_price
FROM dws_daily_order_stats
WHERE dt = (SELECT MAX(dt) FROM dws_daily_order_stats);

-- ============================================
-- 图表7: 用户留存分析（柱状图）
-- ============================================
SELECT
    retention_day,
    retention_rate
FROM ads_user_retention
WHERE dt = (SELECT MAX(dt) FROM ads_user_retention)
ORDER BY retention_day;

-- ============================================
-- 图表8: 商品转化漏斗（漏斗图）
-- ============================================
SELECT
    action,
    cnt
FROM (
    SELECT "pageview" AS action, SUM(pageview_cnt) AS cnt FROM dws_daily_product_sales WHERE dt = (SELECT MAX(dt) FROM dws_daily_product_sales)
    UNION ALL
    SELECT "cart"     AS action, SUM(cart_cnt)     AS cnt FROM dws_daily_product_sales WHERE dt = (SELECT MAX(dt) FROM dws_daily_product_sales)
    UNION ALL
    SELECT "order"    AS action, SUM(order_cnt)    AS cnt FROM dws_daily_product_sales WHERE dt = (SELECT MAX(dt) FROM dws_daily_product_sales)
    UNION ALL
    SELECT "payment"  AS action, SUM(pay_cnt)      AS cnt FROM dws_daily_product_sales WHERE dt = (SELECT MAX(dt) FROM dws_daily_product_sales)
) t
ORDER BY cnt DESC;
