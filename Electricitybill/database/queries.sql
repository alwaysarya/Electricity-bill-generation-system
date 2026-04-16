-- Common queries for Electricity Bill Management System

-- 1. List all customers
SELECT * FROM customers;

-- 2. Get meter readings for a customer
SELECT r.*
FROM meter_readings r
JOIN customers c ON r.customer_id = c.customer_id
WHERE c.meter_number = 'MTR001';

-- 3. Pending bills report
SELECT b.bill_id, c.name, c.address, b.amount_due, b.due_date
FROM bills b
JOIN customers c ON b.customer_id = c.customer_id
WHERE b.status = 'unpaid';

-- 4. Payment history for a bill
SELECT p.*
FROM payments p
WHERE p.bill_id = 1;
