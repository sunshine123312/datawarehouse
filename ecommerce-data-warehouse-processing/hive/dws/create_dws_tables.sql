-- ============================================
-- DWS层 - 服务数据层（轻度聚合）
-- ============================================

-- 1. DWS 用户行为日汇总
DROP TABLE IF EXISTS dws_daily_user_behavior;
CREATE EXTERNAL TABLE dws_daily_user_behavior (
    uid            INT     COMMENT '用户ID',
    pageview_cnt   BIGINT  COMMENT '浏览PV数',
    cart_cnt       BIGINT  COMMENT '加购次数',
    favor_cnt      BIGINT  COMMENT '收藏次数',
    order_cnt      BIGINT  COMMENT '下单次数',
    payment_cnt    BIGINT  COMMENT '支付次数',
    order_amount   DOUBLE  COMMENT '下单金额',
    pay_amount     DOUBLE  COMMENT '支付金额',
    active_hours   INT     COMMENT '活跃小时数'
)
COMMENT 'DWS - 用户行为日汇总'
PARTITIONED BY (dt STRING)
STORED AS PARQUET
LOCATION '/warehouse/dws/daily_user_behavior';

-- 2. DWS 商品销售日汇总
DROP TABLE IF EXISTS dws_daily_product_sales;
CREATE EXTERNAL TABLE dws_daily_product_sales (
    sku_id          INT     COMMENT 'SKU ID',
    sku_name        STRING  COMMENT '商品名称',
    category_name   STRING  COMMENT '品类名称',
    price           DOUBLE  COMMENT '单价',
    pageview_cnt    BIGINT  COMMENT '浏览量',
    cart_cnt        BIGINT  COMMENT '加购量',
    order_cnt       BIGINT  COMMENT '下单量',
    pay_cnt         BIGINT  COMMENT '支付量',
    order_amount    DOUBLE  COMMENT '下单金额',
    pay_amount      DOUBLE  COMMENT '支付金额',
    conversion_rate DOUBLE  COMMENT '下单转化率(支付/浏览)'
)
COMMENT 'DWS - 商品销售日汇总'
PARTITIONED BY (dt STRING)
STORED AS PARQUET
LOCATION '/warehouse/dws/daily_product_sales';

-- 3. DWS 订单统计日汇总
DROP TABLE IF EXISTS dws_daily_order_stats;
CREATE EXTERNAL TABLE dws_daily_order_stats (
    total_orders        BIGINT  COMMENT '总订单数',
    paid_orders         BIGINT  COMMENT '已支付订单数',
    cancelled_orders    BIGINT  COMMENT '取消订单数',
    total_order_amount  DOUBLE  COMMENT '总下单金额',
    total_pay_amount    DOUBLE  COMMENT '总支付金额',
    total_users         BIGINT  COMMENT '下单用户数',
    paid_users          BIGINT  COMMENT '支付用户数',
    avg_order_amount    DOUBLE  COMMENT '平均订单金额',
    per_customer_price  DOUBLE  COMMENT '客单价'
)
COMMENT 'DWS - 订单统计日汇总'
PARTITIONED BY (dt STRING)
STORED AS PARQUET
LOCATION '/warehouse/dws/daily_order_stats';

-- 4. DWS 小时级流量汇总
DROP TABLE IF EXISTS dws_hourly_traffic;
CREATE EXTERNAL TABLE dws_hourly_traffic (
    hour        INT     COMMENT '小时',
    pageview_cnt BIGINT COMMENT 'PV',
    uv          BIGINT  COMMENT '独立访客',
    order_cnt   BIGINT  COMMENT '订单数',
    pay_cnt     BIGINT  COMMENT '支付数'
)
COMMENT 'DWS - 小时级流量汇总'
PARTITIONED BY (dt STRING)
STORED AS PARQUET
LOCATION '/warehouse/dws/hourly_traffic';
