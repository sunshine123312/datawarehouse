-- ============================================
-- 电商业务数据库初始化
-- 在 MySQL 中运行: mysql -u root -p < init_ecommerce_db.sql
-- ============================================
CREATE DATABASE IF NOT EXISTS ecommerce_db DEFAULT CHARACTER SET utf8;
USE ecommerce_db;

-- 用户表
DROP TABLE IF EXISTS user_info;
CREATE TABLE user_info (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    user_name     VARCHAR(50)  NOT NULL,
    gender        CHAR(1)      DEFAULT "M",
    age           INT          DEFAULT 25,
    city          VARCHAR(50)  DEFAULT "北京",
    level         VARCHAR(20)  DEFAULT "bronze",
    register_time DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 品类表
DROP TABLE IF EXISTS category_info;
CREATE TABLE category_info (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_id     INT          DEFAULT 0,
    level         INT          DEFAULT 1
) ENGINE=InnoDB;

-- 商品表
DROP TABLE IF EXISTS sku_info;
CREATE TABLE sku_info (
    sku_id      INT AUTO_INCREMENT PRIMARY KEY,
    sku_name    VARCHAR(200) NOT NULL,
    category_id INT          NOT NULL,
    price       DECIMAL(10,2) DEFAULT 0.00,
    brand       VARCHAR(100) DEFAULT "",
    create_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES category_info(category_id)
) ENGINE=InnoDB;

-- 订单表
DROP TABLE IF EXISTS order_info;
CREATE TABLE order_info (
    order_id     INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT          NOT NULL,
    sku_id       INT          NOT NULL,
    sku_num      INT          DEFAULT 1,
    order_amount DECIMAL(10,2) DEFAULT 0.00,
    payment_type INT          DEFAULT 1,
    order_status VARCHAR(20)  DEFAULT "unpaid",
    create_time  DATETIME     DEFAULT CURRENT_TIMESTAMP,
    pay_time     DATETIME     DEFAULT NULL,
    cancel_time  DATETIME     DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES user_info(user_id),
    FOREIGN KEY (sku_id)  REFERENCES sku_info(sku_id)
) ENGINE=InnoDB;

-- 支付表
DROP TABLE IF EXISTS payment_info;
CREATE TABLE payment_info (
    payment_id   INT AUTO_INCREMENT PRIMARY KEY,
    order_id     INT          NOT NULL,
    user_id      INT          NOT NULL,
    amount       DECIMAL(10,2) DEFAULT 0.00,
    payment_type INT          DEFAULT 1,
    pay_time     DATETIME     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES order_info(order_id),
    FOREIGN KEY (user_id)  REFERENCES user_info(user_id)
) ENGINE=InnoDB;

-- 插入品类测试数据
INSERT INTO category_info VALUES
(1, "手机数码", 0, 1), (2, "电脑办公", 0, 1), (3, "家用电器", 0, 1),
(4, "服饰鞋帽", 0, 1), (5, "美妆个护", 0, 1), (6, "食品生鲜", 0, 1),
(7, "家居家装", 0, 1), (8, "图书文娱", 0, 1),
(11, "手机", 1, 2), (12, "平板", 1, 2), (13, "耳机", 1, 2),
(21, "笔记本", 2, 2), (22, "台式机", 2, 2), (23, "显示器", 2, 2),
(31, "冰箱", 3, 2), (32, "洗衣机", 3, 2), (33, "空调", 3, 2);
