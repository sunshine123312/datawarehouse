# 电商数仓 Superset 仪表盘设计方案

## 仪表盘1: 电商运营总览（D-1 Overview）

| 图表 | 类型 | 数据源 | 位置 |
|------|------|--------|------|
| GMV趋势 | 折线图 | ads_daily_revenue | 顶部通栏 |
| 今日订单KPI | 大数字 | dws_daily_order_stats | 顶部KPI行 |
| 品类销售占比 | 饼图 | ads_category_sales | 中左 |
| 小时级流量 | 面积图 | ads_hourly_traffic_analysis | 中右 |
| 用户价值分层 | 柱状图 | ads_user_value_segmentation | 下左 |
| 热销Top10 | 条形图 | ads_top_selling_products | 下右 |

## 仪表盘2: 商品分析

| 图表 | 类型 | 数据源 |
|------|------|--------|
| 商品转化漏斗 | 漏斗图 | dws_daily_product_sales |
| Top20 热销商品 | 表格 | ads_top_selling_products |
| 品类GMV排行 | 水平条 | ads_category_sales |
| 商品价格分布 | 直方图 | dwd_sku_dim |

## 仪表盘3: 用户分析

| 图表 | 类型 | 数据源 |
|------|------|--------|
| 用户活跃分布 | 饼图 | dws_daily_user_behavior |
| 用户价值分层 | 散点图 | ads_user_value_segmentation |
| 留存分析 | 柱状图 | ads_user_retention |
| 年龄分布 | 饼图 | dwd_user_dim |

## 在 Superset 中创建图表的步骤

1. **Charts → +Chart**
2. 选择一个数据集（如 ads_daily_revenue）
3. 选择图表类型（如 Time-series Line Chart）
4. 配置:
   - Time column: dt
   - Metrics: SUM(total_gmv)
5. 点击 **Create Chart**
6. 调整样式后 **Save**
7. 将图表添加到 Dashboard
