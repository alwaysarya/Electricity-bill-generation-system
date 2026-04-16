-- Sample data for Electricity Bill Management System

INSERT INTO customers (name, address, phone, email, meter_number, connection_date)
VALUES
('Amit Sharma', '12 Main Street, Delhi', '9876543210', 'amit@example.com', 'MTR001', '2025-01-15'),
('Priya Gupta', '45 Park Avenue, Mumbai', '9123456780', 'priya@example.com', 'MTR002', '2025-02-05');

INSERT INTO meter_readings (customer_id, reading_date, units_consumed)
VALUES
(1, '2025-03-01', 310),
(1, '2025-04-01', 250),
(2, '2025-03-01', 420),
(2, '2025-04-01', 390);
(3, '2025-03-01', 150),
(3, '2025-04-01', 180);         
(4, '2025-03-01', 500),
(4, '2025-04-01', 450);             


-- meter readings update!
