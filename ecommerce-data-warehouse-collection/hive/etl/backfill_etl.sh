#!/bin/bash
# ========== 增量ETL（最近7天执行补数） ==========
for i in {0..7}; do
    DT=$(date -d "-$i days" +%Y%m%d 2>/dev/null || date -v -${i}d +%Y%m%d 2>/dev/null)
    echo "处理日期: $DT"
    bash "$(dirname "$0")/run_all_etl.sh" "$DT"
done
echo "========== 近7天历史补数完成 =========="
