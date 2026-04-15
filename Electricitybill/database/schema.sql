CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    category_id INT,
    connection_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customer_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    street VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    pincode VARCHAR(10),
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE regions (
    region_id INT AUTO_INCREMENT PRIMARY KEY,
    region_name VARCHAR(100)
);

CREATE TABLE outages (
    outage_id INT AUTO_INCREMENT PRIMARY KEY,
    region_id INT,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    reason TEXT,
    FOREIGN KEY(region_id) REFERENCES regions(region_id) ON DELETE CASCADE
);

CREATE TABLE meters (
    meter_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    meter_number VARCHAR(50) UNIQUE NOT NULL,
    installation_date DATE,
    status ENUM('active','inactive') DEFAULT 'active',
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE devices (
    device_id INT AUTO_INCREMENT PRIMARY KEY,
    meter_id INT,
    device_type VARCHAR(50),
    firmware_version VARCHAR(50),
    status VARCHAR(50),
    FOREIGN KEY(meter_id) REFERENCES meters(meter_id)
);

CREATE TABLE meter_readings (
    reading_id INT AUTO_INCREMENT PRIMARY KEY,
    meter_id INT NOT NULL,
    reading_date DATE NOT NULL,
    units_consumed INT NOT NULL,
    UNIQUE(meter_id, reading_date),
    FOREIGN KEY(meter_id) REFERENCES meters(meter_id) ON DELETE CASCADE
);

CREATE TABLE smart_meter_data (
    data_id INT AUTO_INCREMENT PRIMARY KEY,
    meter_id INT,
    timestamp TIMESTAMP,
    units FLOAT,
    FOREIGN KEY(meter_id) REFERENCES meters(meter_id) ON DELETE CASCADE
);

CREATE TABLE anomaly_logs (
    anomaly_id INT AUTO_INCREMENT PRIMARY KEY,
    meter_id INT,
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    FOREIGN KEY(meter_id) REFERENCES meters(meter_id)
);

CREATE TABLE tariff (
    tariff_id INT AUTO_INCREMENT PRIMARY KEY,
    min_units INT,
    max_units INT,
    rate_per_unit DECIMAL(5,2)
);

CREATE TABLE time_tariff (
    time_tariff_id INT AUTO_INCREMENT PRIMARY KEY,
    tariff_id INT,
    start_hour INT,
    end_hour INT,
    rate DECIMAL(5,2),
    FOREIGN KEY(tariff_id) REFERENCES tariff(tariff_id)
);

CREATE TABLE seasonal_tariff (
    seasonal_id INT AUTO_INCREMENT PRIMARY KEY,
    tariff_id INT,
    season VARCHAR(20),
    rate_multiplier DECIMAL(3,2),
    FOREIGN KEY(tariff_id) REFERENCES tariff(tariff_id)
);

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin','staff') DEFAULT 'staff'
);

CREATE TABLE user_sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    login_time TIMESTAMP,
    logout_time TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(user_id)
);

CREATE TABLE password_resets (
    reset_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    token VARCHAR(255),
    expiry_time TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    billing_period_start DATE NOT NULL,
    billing_period_end DATE NOT NULL,
    units_consumed INT NOT NULL,
    amount_due DECIMAL(10,2) NOT NULL,
    late_fee DECIMAL(10,2) DEFAULT 0,
    generated_date DATE NOT NULL,
    due_date DATE NOT NULL,
    status ENUM('unpaid','paid','overdue') DEFAULT 'unpaid',
    generated_by INT,
    invoice_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY(generated_by) REFERENCES users(user_id)
);

CREATE TABLE bill_components (
    component_id INT AUTO_INCREMENT PRIMARY KEY,
    bill_id INT,
    component_name VARCHAR(100),
    amount DECIMAL(10,2),
    FOREIGN KEY(bill_id) REFERENCES bills(bill_id) ON DELETE CASCADE
);

CREATE TABLE bill_adjustments (
    adjustment_id INT AUTO_INCREMENT PRIMARY KEY,
    bill_id INT,
    reason VARCHAR(255),
    amount DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(bill_id) REFERENCES bills(bill_id) ON DELETE CASCADE
);

CREATE TABLE discounts (
    discount_id INT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(100),
    percentage DECIMAL(5,2)
);

CREATE TABLE bill_discounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bill_id INT,
    discount_id INT,
    FOREIGN KEY(bill_id) REFERENCES bills(bill_id),
    FOREIGN KEY(discount_id) REFERENCES discounts(discount_id)
);

CREATE TABLE penalty_rules (
    rule_id INT AUTO_INCREMENT PRIMARY KEY,
    days_late INT,
    penalty_amount DECIMAL(10,2)
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    bill_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50),
    status ENUM('success','pending','failed') DEFAULT 'success',
    remarks TEXT,
    FOREIGN KEY(bill_id) REFERENCES bills(bill_id) ON DELETE CASCADE
);

CREATE TABLE payment_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT,
    gateway_response TEXT,
    status VARCHAR(50),
    FOREIGN KEY(payment_id) REFERENCES payments(payment_id) ON DELETE CASCADE
);

CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    message TEXT,
    sent_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('sent','pending'),
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE complaints (
    complaint_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    description TEXT,
    status ENUM('open','resolved','in_progress'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE usage_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    month VARCHAR(20),
    units_consumed INT,
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE consumption_forecast (
    forecast_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    predicted_units INT,
    forecast_month VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE activity_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(255),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(user_id)
);



CREATE INDEX idx_customer ON bills(customer_id);
CREATE INDEX idx_bill ON payments(bill_id);

-- schema update
--update 1