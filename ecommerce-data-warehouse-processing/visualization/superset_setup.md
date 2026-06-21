# Apache Superset 可视化配置指南

## 1. 安装 Superset

\`\`\`bash
# 在 hadoop102 上安装
ssh hadoop102

# 安装依赖
sudo yum install -y gcc gcc-c++ libffi-devel python3-devel python3-pip

# 安装 Superset
pip3 install apache-superset psycopg2-binary pyhive thrift_sasl

# 初始化数据库
superset db upgrade

# 创建管理员用户
export FLASK_APP=superset
superset fab create-admin \
    --username admin \
    --firstname Admin \
    --lastname User \
    --email admin@example.com \
    --password admin123

# 初始化
superset init

# 启动（前台调试用，正式请用 gunicorn）
superset run -h 0.0.0.0 -p 8088 --with-threads --reload
\`\`\`

## 2. 配置 Hive 数据源

1. 浏览器访问 http://hadoop102:8088
2. 用 admin / admin123 登录
3. 顶部菜单: **Data → Databases → + Database**
4. 填写:
   - Database Name: \`hive_warehouse\`
   - SQLAlchemy URI: \`hive://hadoop102:10000/warehouse\`
5. 点击 **Test Connection** 确认成功
6. 点击 **Save**

## 3. 导入数据集

1. **Data → Datasets → + Dataset**
2. 依次添加以下表:
   - \`ads_daily_revenue\` (GMV日报)
   - \`ads_top_selling_products\` (热销TopN)
   - \`ads_category_sales\` (品类销售)
   - \`ads_hourly_traffic_analysis\` (小时级流量)
   - \`ads_user_value_segmentation\` (用户分层)
   - \`ads_user_retention\` (留存分析)
   - \`dws_daily_order_stats\` (订单统计)

## 4. 创建仪表盘

已在 \`dashboard_templates.md\` 中提供预定义 SQL 查询，
可直接在 Superset 中 **SQL Lab → SQL Editor** 中运行获取数据，
然后通过 **Charts → +Chart** 创建可视化图表，拖拽到仪表盘中。
