-- 创建数据库（若不存在）
CREATE DATABASE IF NOT EXISTS community_elderly_care CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE community_elderly_care;

-- 1. 社区表
CREATE TABLE IF NOT EXISTS community (
                                         id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                         community_name VARCHAR(100) NOT NULL COMMENT '社区名称',
    address VARCHAR(255) NOT NULL COMMENT '社区地址',
    contact_person VARCHAR(50) COMMENT '联系人',
    contact_phone VARCHAR(20) COMMENT '联系电话',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社区信息表';

-- 2. 老年用户表
CREATE TABLE IF NOT EXISTS elderly_user (
                                            id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                            username VARCHAR(50) NOT NULL UNIQUE COMMENT '登录账号',
    password VARCHAR(50) NOT NULL COMMENT '明文密码',
    real_name VARCHAR(50) NOT NULL COMMENT '真实姓名',
    phone VARCHAR(20) NOT NULL UNIQUE COMMENT '手机号',
    id_card VARCHAR(18) UNIQUE COMMENT '身份证号',
    community_id BIGINT COMMENT '所属社区ID',
    address VARCHAR(255) COMMENT '详细住址',
    emergency_contact VARCHAR(50) COMMENT '紧急联系人',
    emergency_phone VARCHAR(20) COMMENT '紧急联系人电话',
    health_status VARCHAR(255) COMMENT '健康状况备注',
    status TINYINT DEFAULT 1 COMMENT '1-正常,0-禁用',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (community_id) REFERENCES community(id) ON DELETE SET NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='老年用户表';

-- 3. 护工表
CREATE TABLE IF NOT EXISTS caregiver (
                                         id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                         username VARCHAR(50) NOT NULL UNIQUE COMMENT '登录账号',
    password VARCHAR(50) NOT NULL COMMENT '明文密码',
    real_name VARCHAR(50) NOT NULL COMMENT '真实姓名',
    phone VARCHAR(20) NOT NULL UNIQUE COMMENT '手机号',
    id_card VARCHAR(18) UNIQUE COMMENT '身份证号',
    avatar VARCHAR(255) COMMENT '头像URL',
    skill VARCHAR(255) COMMENT '服务技能',
    qualification VARCHAR(255) COMMENT '资质证书URL',
    community_id BIGINT COMMENT '服务社区ID',
    status TINYINT DEFAULT 0 COMMENT '0-待审核,1-已通过,2-已拒绝',
    approval_remark VARCHAR(255) COMMENT '审核备注',
    rating DECIMAL(2,1) DEFAULT 5.0 COMMENT '平均评分',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (community_id) REFERENCES community(id) ON DELETE SET NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='护工表';

-- 4. 服务订单表
CREATE TABLE IF NOT EXISTS service_order (
                                             id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                             order_no VARCHAR(32) NOT NULL UNIQUE COMMENT '订单编号',
    elderly_id BIGINT NOT NULL COMMENT '下单用户ID',
    caregiver_id BIGINT COMMENT '接单护工ID',
    community_id BIGINT NOT NULL COMMENT '服务社区ID',
    service_type VARCHAR(50) NOT NULL COMMENT '服务类型（护理、保洁、代购等）',
    service_time DATETIME NOT NULL COMMENT '预约服务时间',
    service_address VARCHAR(255) NOT NULL COMMENT '服务地址',
    service_desc VARCHAR(500) COMMENT '服务需求描述',
    status TINYINT NOT NULL COMMENT '0-待接单,1-已接单,2-服务中,3-已完成,4-已取消',
    score TINYINT COMMENT '评分(1-5)',
    comment VARCHAR(500) COMMENT '评价内容',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (elderly_id) REFERENCES elderly_user(id) ON DELETE CASCADE,
    FOREIGN KEY (caregiver_id) REFERENCES caregiver(id) ON DELETE SET NULL,
    FOREIGN KEY (community_id) REFERENCES community(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务订单表';

-- 5. 紧急呼叫表
CREATE TABLE IF NOT EXISTS emergency_call (
                                              id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                              elderly_id BIGINT NOT NULL COMMENT '呼叫用户ID',
                                              community_id BIGINT NOT NULL COMMENT '所属社区ID',
                                              call_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '呼叫时间',
                                              status TINYINT DEFAULT 0 COMMENT '0-未处理,1-已响应,2-已解决',
                                              handler_id BIGINT COMMENT '处理护工/管理员ID',
                                              handler_remark VARCHAR(255) COMMENT '处理备注',
    FOREIGN KEY (elderly_id) REFERENCES elderly_user(id) ON DELETE CASCADE,
    FOREIGN KEY (community_id) REFERENCES community(id) ON DELETE CASCADE,
    FOREIGN KEY (handler_id) REFERENCES caregiver(id) ON DELETE SET NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='紧急呼叫表';

-- 6. 评价表
CREATE TABLE IF NOT EXISTS evaluation (
                                          id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                          order_id BIGINT NOT NULL UNIQUE COMMENT '关联订单ID',
                                          elderly_id BIGINT NOT NULL COMMENT '评价用户ID',
                                          caregiver_id BIGINT NOT NULL COMMENT '被评价护工ID',
                                          score TINYINT NOT NULL COMMENT '1-5分',
                                          comment VARCHAR(500) COMMENT '评价内容',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
    order_no VARCHAR(32) COMMENT '关联订单编号（冗余）',
    elderly_name VARCHAR(50) COMMENT '评价用户姓名（冗余）',
    FOREIGN KEY (order_id) REFERENCES service_order(id) ON DELETE CASCADE,
    FOREIGN KEY (elderly_id) REFERENCES elderly_user(id) ON DELETE CASCADE,
    FOREIGN KEY (caregiver_id) REFERENCES caregiver(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评价表';

-- 7. 管理员表
CREATE TABLE IF NOT EXISTS admin (
                                     id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                     username VARCHAR(50) NOT NULL UNIQUE COMMENT '登录账号',
    password VARCHAR(50) NOT NULL COMMENT '明文密码',
    real_name VARCHAR(50) COMMENT '真实姓名',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员表';

-- 插入测试数据（直接可用）
INSERT INTO community (community_name, address, contact_person, contact_phone)
VALUES ('阳光社区', '北京市朝阳区建国路88号', '张三', '13800138000');

INSERT INTO elderly_user (username, password, real_name, phone, community_id, address, emergency_contact, emergency_phone)
VALUES ('laonian1', '123456', '张大爷', '13900139000', 1, '阳光社区3号楼2单元501', '李四', '13700137000');

INSERT INTO caregiver (username, password, real_name, phone, community_id, skill, status)
VALUES ('hugong1', '123456', '李护工', '13600136000', 1, '上门护理、代购药品', 1);

INSERT INTO service_order (order_no, elderly_id, caregiver_id, community_id, service_type, service_time, service_address, service_desc, status)
VALUES ('2024052010001', 1, 1, 1, '上门护理', '2024-05-20 09:00:00', '阳光社区3号楼2单元501', '日常护理、测量血压', 3);

INSERT INTO evaluation (order_id, elderly_id, caregiver_id, score, comment, order_no, elderly_name)
VALUES (1, 1, 1, 5, '服务非常周到，态度热情，护理专业，值得推荐！', '2024052010001', '张大爷');

INSERT INTO admin (username, password, real_name)
VALUES ('admin', 'admin123', '系统管理员');


-- 为紧急呼叫表添加当前地址字段
-- 执行此 SQL 脚本来添加 current_address 字段

ALTER TABLE emergency_call
    ADD COLUMN current_address VARCHAR(255) COMMENT '当前地址（呼叫时手动输入）' AFTER handler_remark;




