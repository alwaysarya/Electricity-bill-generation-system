-- Sample data for Electricity Bill Management System

INSERT INTO customers (name, address, phone, email, meter_number, connection_date)
VALUES
('Amit Sharma', '12 Main Street, Delhi', '9876543210', 'amit@example.com', 'MTR001', '2025-01-15'),
('Priya Gupta', '45 Park Avenue, Mumbai', '9123456780', 'priya@example.com', 'MTR202', '2025-02-05'),
('Raj Patel', '78 Oak Street, Bangalore', '9876543210', 'raj@example.com', 'MTR803', '2025-03-10'),
('Arjun Singh ', '54 Santa Cruise, Hyderabad', '9123456900', 'arjun@example.com', 'MTR304', '2025-04-05'),
('Sudhir Choudhary', '22 Indiranagar, Bangalore', '9123352780', 'sudhir@example.com', 'MTR235', '2025-02-05');
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
(5, '2025-03-01', 200),
(5, '2025-04-01', 220);
(6, '2025-03-01', 350),
(6, '2025-04-01', 300);  

--change 1
--change 2
-- meter readings update!
