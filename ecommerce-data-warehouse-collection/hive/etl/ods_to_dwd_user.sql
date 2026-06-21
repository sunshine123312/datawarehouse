-- ============================================
-- ETL: ODS → DWD (用户维度)
-- ============================================
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.mapred.mode=nonstrict;

INSERT OVERWRITE TABLE dwd_user_dim PARTITION (dt)
SELECT
    user_id,
    user_name,
    gender,
    age,
    CASE
        WHEN age <= 20 THEN "00后"
        WHEN age <= 30 THEN "90后"
        WHEN age <= 40 THEN "80后"
        WHEN age <= 50 THEN "70后"
        ELSE "其他"
    END AS age_group,
    city,
    level,
    register_time,
    dt
FROM ods_user_info
WHERE dt = '${hiveconf:dt}';
