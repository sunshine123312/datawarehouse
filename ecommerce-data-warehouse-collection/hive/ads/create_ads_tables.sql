-- ============================================
-- ADS层 - 应用数据层（最终报表）
-- ============================================

-- 1. ADS GMV日报
DROP TABLE IF EXISTS ads_daily_revenue;
CREATE EXTERNAL TABLE ads_daily_revenue (
    dt              STRING  COMMENT '日期',
    total_gmv       DOUBLE  COMMENT '当日GMV(支付金额)',
    total_orders    BIGINT  COMMENT '支付订单数',
    total_users     BIGINT  COMMENT '支付用户数',
    avg_order_price DOUBLE  COMMENT '平均订单价',
    per_customer    DOUBLE  COMMENT '客单价'
)
COMMENT 'ADS - GMV日报'
STORED AS PARQUET
LOCATION '/warehouse/ads/daily_revenue';

-- 2. ADS 热销商品TopN
DROP TABLE IF EXISTS ads_top_selling_products;
CREATE EXTERNAL TABLE ads_top_selling_products (
    dt              STRING  COMMENT '日期',
    rank            INT     COMMENT '排名',
    sku_id          INT     COMMENT 'SKU ID',
    sku_name        STRING  COMMENT '商品名称',
    category_name   STRING  COMMENT '品类',
    pay_amount      DOUBLE  COMMENT '支付金额',
    pay_cnt         BIGINT  COMMENT '支付件数'
)
COMMENT 'ADS - 热销商品TopN'
STORED AS PARQUET
LOCATION '/warehouse/ads/top_selling_products';

-- 3. ADS 品类销售统计
DROP TABLE IF EXISTS ads_category_sales;
CREATE EXTERNAL TABLE ads_category_sales (
    dt              STRING  COMMENT '日期',
    category_name   STRING  COMMENT '品类',
    gmv             DOUBLE  COMMENT '品类GMV',
    order_cnt       BIGINT  COMMENT '品类订单数',
    sku_sold_cnt    BIGINT  COMMENT '品类售出件数',
    gmv_ratio       DOUBLE  COMMENT 'GMV占比(%)'
)
COMMENT 'ADS - 品类销售统计'
STORED AS PARQUET
LOCATION '/warehouse/ads/category_sales';

-- 4. ADS 小时级流量分析
DROP TABLE IF EXISTS ads_hourly_traffic_analysis;
CREATE EXTERNAL TABLE ads_hourly_traffic_analysis (
    dt              STRING  COMMENT '日期',
    hour            INT     COMMENT '小时',
    pv              BIGINT  COMMENT '页面浏览',
    uv              BIGINT  COMMENT '独立访客',
    order_cnt       BIGINT  COMMENT '订单数',
    pay_cnt         BIGINT  COMMENT '支付数',
    conversion_rate DOUBLE  COMMENT 'UV转化率(订单/访客)'
)
COMMENT 'ADS - 小时级流量分析'
STORED AS PARQUET
LOCATION '/warehouse/ads/hourly_traffic_analysis';

-- 5. ADS 用户留存
DROP TABLE IF EXISTS ads_user_retention;
CREATE EXTERNAL TABLE ads_user_retention (
    dt              STRING  COMMENT '统计日期',
    register_date   STRING  COMMENT '注册日期',
    retention_day   INT     COMMENT '留存天数(1/3/7/30)',
    new_user_cnt    BIGINT  COMMENT '新增用户数',
    retention_user_cnt BIGINT COMMENT '留存用户数',
    retention_rate  DOUBLE  COMMENT '留存率'
)
COMMENT 'ADS - 用户留存分析'
STORED AS PARQUET
LOCATION '/warehouse/ads/user_retention';

-- 6. ADS 用户价值分层（RFM简化版）
DROP TABLE IF EXISTS ads_user_value_segmentation;
CREATE EXTERNAL TABLE ads_user_value_segmentation (
    dt              STRING  COMMENT '统计日期',
    segment         STRING  COMMENT '分层: high/medium/low',
    user_cnt        BIGINT  COMMENT '用户数',
    total_gmv       DOUBLE  COMMENT 'GMV',
    avg_order_freq  DOUBLE  COMMENT '平均下单频次',
    avg_customer_price DOUBLE COMMENT '平均客单价'
)
COMMENT 'ADS - 用户价值分层'
STORED AS PARQUET
LOCATION '/warehouse/ads/user_value_segmentation';
