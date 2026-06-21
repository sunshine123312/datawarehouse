-- ============================================
-- ODS层 - 原始数据层
-- 保持与源数据一致，不做任何清洗
-- ============================================

-- 1. ODS 用户行为事件日志（从Flume写入HDFS）
DROP TABLE IF EXISTS ods_event_log;
CREATE EXTERNAL TABLE ods_event_log (
    action_id    STRING COMMENT '事件唯一ID',
    uid          INT    COMMENT '用户ID',
    sku_id       INT    COMMENT '商品SKU ID',
    category_id  INT    COMMENT '品类ID',
    action       STRING COMMENT '事件类型: pageview/cart/favor/order/payment',
    ts           STRING COMMENT '事件时间戳 HHmmss',
    stay_seconds INT    COMMENT '停留秒数(pageview)',
    count        INT    COMMENT '数量(cart)',
    amount       DOUBLE COMMENT '金额(order/payment)',
    payment_type INT    COMMENT '支付方式(order)'
)
COMMENT 'ODS - 用户行为事件日志'
PARTITIONED BY (dt STRING COMMENT '分区 格式yyyyMMdd')
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION '/warehouse/ods/event_log';

-- 2. ODS 订单表（来自MySQL业务数据 -> Sqoop导入）
DROP TABLE IF EXISTS ods_order_info;
CREATE EXTERNAL TABLE ods_order_info (
    order_id        INT     COMMENT '订单ID',
    user_id         INT     COMMENT '用户ID',
    sku_id          INT     COMMENT '商品SKU ID',
    sku_num         INT     COMMENT '商品数量',
    order_amount    DOUBLE  COMMENT '订单金额',
    payment_type    INT     COMMENT '支付方式 1微信 2支付宝 3银联 4现金',
    order_status    STRING  COMMENT '订单状态: unpaid/paid/cancelled/completed',
    create_time     STRING  COMMENT '创建时间',
    pay_time        STRING  COMMENT '支付时间',
    cancel_time     STRING  COMMENT '取消时间'
)
COMMENT 'ODS - 订单表'
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/warehouse/ods/order_info';

-- 3. ODS 用户表（MySQL业务数据）
DROP TABLE IF EXISTS ods_user_info;
CREATE EXTERNAL TABLE ods_user_info (
    user_id       INT     COMMENT '用户ID',
    user_name     STRING  COMMENT '用户名',
    gender        STRING  COMMENT '性别 M/F',
    age           INT     COMMENT '年龄',
    city          STRING  COMMENT '城市',
    level         STRING  COMMENT '会员等级: bronze/silver/gold/platinum',
    register_time STRING  COMMENT '注册时间'
)
COMMENT 'ODS - 用户表'
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/warehouse/ods/user_info';

-- 4. ODS 商品SKU表（MySQL业务数据）
DROP TABLE IF EXISTS ods_sku_info;
CREATE EXTERNAL TABLE ods_sku_info (
    sku_id       INT     COMMENT 'SKU ID',
    sku_name     STRING  COMMENT '商品名称',
    category_id  INT     COMMENT '品类ID',
    price        DOUBLE  COMMENT '单价',
    brand        STRING  COMMENT '品牌',
    create_time  STRING  COMMENT '创建时间'
)
COMMENT 'ODS - 商品SKU表'
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/warehouse/ods/sku_info';

-- 5. ODS 支付表（MySQL业务数据）
DROP TABLE IF EXISTS ods_payment_info;
CREATE EXTERNAL TABLE ods_payment_info (
    payment_id   INT     COMMENT '支付ID',
    order_id     INT     COMMENT '订单ID',
    user_id      INT     COMMENT '用户ID',
    amount       DOUBLE  COMMENT '支付金额',
    payment_type INT     COMMENT '支付方式',
    pay_time     STRING  COMMENT '支付时间'
)
COMMENT 'ODS - 支付表'
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/warehouse/ods/payment_info';

-- 6. ODS 品类表（MySQL业务数据）
DROP TABLE IF EXISTS ods_category_info;
CREATE EXTERNAL TABLE ods_category_info (
    category_id   INT     COMMENT '品类ID',
    category_name STRING  COMMENT '品类名称',
    parent_id     INT     COMMENT '父品类ID',
    level         INT     COMMENT '层级'
)
COMMENT 'ODS - 品类表'
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/warehouse/ods/category_info';
