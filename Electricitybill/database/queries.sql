-- inserting some basic data

INSERT INTO customer_categories (category_name) VALUES ('Domestic');
INSERT INTO customer_categories (category_name) VALUES ('Commercial');

INSERT INTO customers (name, phone, email, category_id, connection_date)
VALUES ('John Doe', '9876543210', 'john@example.com', 1, '2024-01-01');

INSERT INTO addresses VALUES (NULL,1,'Main Street','Delhi','Delhi','110001');

INSERT INTO meters (customer_id, meter_number, installation_date)
VALUES (1,'MTR12345','2024-01-02');

-- tariff data

INSERT INTO tariff VALUES (NULL,0,100,2.5);
INSERT INTO tariff VALUES (NULL,101,200,3.5);
INSERT INTO tariff VALUES (NULL,201,500,5.0);

INSERT INTO users VALUES (NULL,'admin','hashedpassword','admin');

---------------------------------------------------

-- adding meter readings

INSERT INTO meter_readings VALUES (NULL,1,'2024-02-01',120);
INSERT INTO meter_readings VALUES (NULL,1,'2024-03-01',150);

---------------------------------------------------

-- checking total units consumed

SELECT meter_id, SUM(units_consumed)
FROM meter_readings
GROUP BY meter_id;

-- checking rate for units

SELECT mr.units_consumed, t.rate_per_unit
FROM meter_readings mr, tariff t
WHERE mr.units_consumed BETWEEN t.min_units AND t.max_units;

---------------------------------------------------

-- creating bill (manual entry)

INSERT INTO bills (
customer_id, billing_period_start, billing_period_end,
units_consumed, amount_due, generated_date, due_date
)
VALUES (1,'2024-02-01','2024-03-01',150,525,'2024-03-02','2024-03-15');

---------------------------------------------------

-- checking bill

SELECT * FROM bills;

SELECT b.bill_id, c.name, b.amount_due, b.status
FROM bills b, customers c
WHERE b.customer_id = c.customer_id;

---------------------------------------------------

-- payment entry

INSERT INTO payments VALUES (NULL,1,'2024-03-10',525,'UPI','success',NULL);

---------------------------------------------------

-- payment history

SELECT * FROM payments;

SELECT p.payment_id, b.bill_id, p.amount_paid
FROM payments p
JOIN bills b ON p.bill_id = b.bill_id;

---------------------------------------------------

-- unpaid bills

SELECT c.name, b.amount_due
FROM customers c, bills b
WHERE c.customer_id = b.customer_id
AND b.status = 'unpaid';

---------------------------------------------------

-- complaints section

INSERT INTO complaints VALUES (NULL,1,'Power fluctuation issue','open',NOW());

SELECT * FROM complaints;

---------------------------------------------------

-- notifications

INSERT INTO notifications VALUES (NULL,1,'Bill generated',NOW(),'sent');

---------------------------------------------------

-- usage analysis

SELECT customer_id, SUM(units_consumed)
FROM usage_history
GROUP BY customer_id;

---------------------------------------------------

-- top consumers

SELECT m.customer_id, SUM(r.units_consumed) AS total_units
FROM meter_readings r, meters m
WHERE r.meter_id = m.meter_id
GROUP BY m.customer_id
ORDER BY total_units DESC;

---------------------------------------------------

-- late payment check

SELECT bill_id, due_date,
DATEDIFF(CURRENT_DATE, due_date) AS late_days
FROM bills
WHERE status = 'unpaid';

---------------------------------------------------

-- revenue calculation

SELECT SUM(amount_paid)
FROM payments
WHERE status = 'success';

---------------------------------------------------

-- activity logs

INSERT INTO activity_logs VALUES (NULL,1,'Generated bill',NOW());

SELECT u.username, a.action, a.action_time
FROM activity_logs a, users u
WHERE a.user_id = u.user_id;

---------------------------------------------------

-- forecast data

SELECT * FROM consumption_forecast;

---------------------------------------------------

-- anomaly logs

SELECT * FROM anomaly_logs;

---------------------------------------------------

-- audit trail

SELECT * FROM audit_trail;

---------------------------------------------------

-- checking indexes

SHOW INDEX FROM bills;
SHOW INDEX FROM payments;

--update 5