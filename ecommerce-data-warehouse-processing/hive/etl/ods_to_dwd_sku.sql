-- ============================================
-- ETL: ODS → DWD (商品维度)
-- ============================================
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

INSERT OVERWRITE TABLE dwd_sku_dim PARTITION (dt)
SELECT
    s.sku_id,
    s.sku_name,
    s.category_id,
    c.category_name,
    s.price,
    CASE
        WHEN s.price <= 50   THEN "0-50"
        WHEN s.price <= 100  THEN "50-100"
        WHEN s.price <= 500  THEN "100-500"
        ELSE "500+"
    END AS price_range,
    s.brand,
    s.dt
FROM ods_sku_info s
LEFT JOIN ods_category_info c ON s.category_id = c.category_id AND s.dt = c.dt
WHERE s.dt = '${hiveconf:dt}';
