-- ============================================
-- DWD层 - 明细数据层
-- 清洗、维度退化、空值处理
-- ============================================

-- 1. DWD 事件明细表（从ODS JSON解析，维度退化）
DROP TABLE IF EXISTS dwd_event_detail;
CREATE EXTERNAL TABLE dwd_event_detail (
    action_id    STRING  COMMENT '事件ID',
    uid          INT     COMMENT '用户ID',
    sku_id       INT     COMMENT 'SKU ID',
    category_id  INT     COMMENT '品类ID',
    category_name STRING COMMENT '品类名称(退化维度)',
    action       STRING  COMMENT '事件类型',
    event_hour   INT     COMMENT '事件小时',
    stay_seconds INT     COMMENT '停留秒数',
    count        INT     COMMENT '数量',
    amount       DOUBLE  COMMENT '金额'
)
COMMENT 'DWD - 事件明细表（维度退化后）'
PARTITIONED BY (dt STRING)
STORED AS PARQUET
LOCATION '/warehouse/dwd/event_detail';

-- 2. DWD 订单明细表
DROP TABLE IF EXISTS dwd_order_detail;
CREATE EXTERNAL TABLE dwd_order_detail (
    order_id        INT     COMMENT '订单ID',
    user_id         INT     COMMENT '用户ID',
    user_name       STRING  COMMENT '用户名(退化)',
    sku_id          INT     COMMENT 'SKU ID',
    sku_name        STRING  COMMENT '商品名(退化)',
    category_name   STRING  COMMENT '品类名(退化)',
    sku_num         INT     COMMENT '数量',
    price           DOUBLE  COMMENT '单价',
    order_amount    DOUBLE  COMMENT '订单金额',
    payment_type    INT     COMMENT '支付方式',
    payment_type_name STRING COMMENT '支付方式名称(退化)',
    order_status    STRING  COMMENT '订单状态',
    create_hour     INT     COMMENT '创建小时',
    create_time     STRING  COMMENT '创建时间',
    pay_time        STRING  COMMENT '支付时间'
)
COMMENT 'DWD - 订单明细表'
PARTITIONED BY (dt STRING)
STORED AS PARQUET
LOCATION '/warehouse/dwd/order_detail';

-- 3. DWD 用户维度表（拉链表/全量表）
DROP TABLE IF EXISTS dwd_user_dim;
CREATE EXTERNAL TABLE dwd_user_dim (
    user_id       INT     COMMENT '用户ID',
    user_name     STRING  COMMENT '用户名',
    gender        STRING  COMMENT '性别',
    age           INT     COMMENT '年龄',
    age_group     STRING  COMMENT '年龄段: 00后/90后/80后/70后/其他',
    city          STRING  COMMENT '城市',
    level         STRING  COMMENT '会员等级',
    register_time STRING  COMMENT '注册时间'
)
COMMENT 'DWD - 用户维度表'
PARTITIONED BY (dt STRING)
STORED AS PARQUET
LOCATION '/warehouse/dwd/user_dim';

-- 4. DWD 商品维度表
DROP TABLE IF EXISTS dwd_sku_dim;
CREATE EXTERNAL TABLE dwd_sku_dim (
    sku_id        INT     COMMENT 'SKU ID',
    sku_name      STRING  COMMENT '商品名称',
    category_id   INT     COMMENT '品类ID',
    category_name STRING  COMMENT '品类名称(退化)',
    price         DOUBLE  COMMENT '单价',
    price_range   STRING  COMMENT '价格区间: 0-50/50-100/100-500/500+',
    brand         STRING  COMMENT '品牌'
)
COMMENT 'DWD - 商品维度表'
PARTITIONED BY (dt STRING)
STORED AS PARQUET
LOCATION '/warehouse/dwd/sku_dim';
