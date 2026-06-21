-- ============================================
-- ETL: ODS → DWD (事件明细)
-- 执行: hive -f ods_to_dwd_event.sql -hiveconf dt=20260621
-- ============================================
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.mapred.mode=nonstrict;

INSERT OVERWRITE TABLE dwd_event_detail PARTITION (dt)
SELECT
    action_id,
    uid,
    sku_id,
    category_id,
    c.category_name,
    action,
    CAST(substr(ts,1,2) AS INT) AS event_hour,
    nvl(stay_seconds, 0),
    nvl(count, 0),
    nvl(amount, 0.0),
    dt
FROM ods_event_log e
LEFT JOIN ods_category_info c
  ON e.category_id = c.category_id AND e.dt = c.dt
WHERE e.dt = '${hiveconf:dt}';
