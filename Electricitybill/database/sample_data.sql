-- adding more customers (11–25)

INSERT INTO customers (name, phone, email, category_id, connection_date)
VALUES
('Suresh Kumar','9000000001','suresh@gmail.com',1,'2025-01-10'),
('Meena Iyer','9000000002','meena@gmail.com',1,'2025-01-12'),
('Ravi Teja','9000000003','ravi@gmail.com',2,'2025-02-14'),
('Pooja Nair','9000000004','pooja@gmail.com',1,'2025-03-18'),
('Kishore Das','9000000005','kishore@gmail.com',2,'2025-02-25'),
('Deepak Yadav','9000000006','deepak@gmail.com',1,'2025-03-05'),
('Sneha Kulkarni','9000000007','sneha@gmail.com',1,'2025-04-02'),
('Ajay Singh','9000000008','ajay@gmail.com',2,'2025-03-30'),
('Ritika Jain','9000000009','ritika@gmail.com',1,'2025-04-08'),
('Mohit Arora','9000000010','mohit@gmail.com',2,'2025-02-22'),
('Nitin Bansal','9000000011','nitin@gmail.com',2,'2025-03-01'),
('Shalini Verma','9000000012','shalini@gmail.com',1,'2025-04-03'),
('Aakash Jain','9000000013','aakash@gmail.com',2,'2025-03-09'),
('Manish Gupta','9000000014','manish@gmail.com',1,'2025-02-18'),
('Komal Shah','9000000015','komal@gmail.com',1,'2025-04-01');

--------------------------------------------------

-- addresses for new customers

INSERT INTO addresses VALUES
(NULL,11,'Street 1','Delhi','Delhi','110002'),
(NULL,12,'Street 2','Mumbai','Maharashtra','400002'),
(NULL,13,'Street 3','Bangalore','Karnataka','560002'),
(NULL,14,'Street 4','Chennai','Tamil Nadu','600001'),
(NULL,15,'Street 5','Pune','Maharashtra','411002'),
(NULL,16,'Street 6','Hyderabad','Telangana','500002'),
(NULL,17,'Street 7','Jaipur','Rajasthan','302001'),
(NULL,18,'Street 8','Lucknow','UP','226001'),
(NULL,19,'Street 9','Indore','MP','452001'),
(NULL,20,'Street 10','Surat','Gujarat','395001'),
(NULL,21,'Street 11','Nagpur','Maharashtra','440001'),
(NULL,22,'Street 12','Patna','Bihar','800001'),
(NULL,23,'Street 13','Bhopal','MP','462001'),
(NULL,24,'Street 14','Kochi','Kerala','682001'),
(NULL,25,'Street 15','Goa','Goa','403001');

--------------------------------------------------

-- meters setup

INSERT INTO meters (customer_id, meter_number, installation_date, status)
VALUES
(11,'MTR011','2025-01-11','active'),
(12,'MTR012','2025-01-13','active'),
(13,'MTR013','2025-02-15','active'),
(14,'MTR014','2025-03-19','active'),
(15,'MTR015','2025-02-26','active'),
(16,'MTR016','2025-03-06','active'),
(17,'MTR017','2025-04-03','active'),
(18,'MTR018','2025-03-31','active'),
(19,'MTR019','2025-04-09','active'),
(20,'MTR020','2025-02-23','active'),
(21,'MTR021','2025-03-02','active'),
(22,'MTR022','2025-04-04','active'),
(23,'MTR023','2025-03-10','active'),
(24,'MTR024','2025-02-19','active'),
(25,'MTR025','2025-04-02','active');

--------------------------------------------------

-- adding readings (bulk)

INSERT INTO meter_readings VALUES
(NULL,11,'2025-03-01',210),(NULL,11,'2025-04-01',230),
(NULL,12,'2025-03-01',180),(NULL,12,'2025-04-01',200),
(NULL,13,'2025-03-01',320),(NULL,13,'2025-04-01',300),
(NULL,14,'2025-03-01',150),(NULL,14,'2025-04-01',170),
(NULL,15,'2025-03-01',400),(NULL,15,'2025-04-01',420),
(NULL,16,'2025-03-01',260),(NULL,16,'2025-04-01',280),
(NULL,17,'2025-03-01',190),(NULL,17,'2025-04-01',210),
(NULL,18,'2025-03-01',500),(NULL,18,'2025-04-01',480),
(NULL,19,'2025-03-01',350),(NULL,19,'2025-04-01',370),
(NULL,20,'2025-03-01',275),(NULL,20,'2025-04-01',290);

--------------------------------------------------

-- bills (auto-like entries)

INSERT INTO bills VALUES
(NULL,11,'2025-03-01','2025-04-01',230,1150,'2025-04-02','2025-04-15','paid',NULL,NULL,NOW()),
(NULL,12,'2025-03-01','2025-04-01',200,700,'2025-04-02','2025-04-15','paid',NULL,NULL,NOW()),
(NULL,13,'2025-03-01','2025-04-01',300,1500,'2025-04-02','2025-04-15','unpaid',NULL,NULL,NOW()),
(NULL,14,'2025-03-01','2025-04-01',170,595,'2025-04-02','2025-04-15','paid',NULL,NULL,NOW()),
(NULL,15,'2025-03-01','2025-04-01',420,2100,'2025-04-02','2025-04-15','overdue',NULL,NULL,NOW());

--------------------------------------------------

-- payments

INSERT INTO payments VALUES
(NULL,11,'2025-04-10',1150,'UPI','success',NULL),
(NULL,12,'2025-04-10',700,'Card','success',NULL),
(NULL,14,'2025-04-11',595,'NetBanking','success',NULL);

--------------------------------------------------

-- activity logs

INSERT INTO activity_logs VALUES
(NULL,1,'Generated bulk bills',NOW()),
(NULL,1,'Updated tariff',NOW()),
(NULL,1,'Handled complaints',NOW()),
(NULL,1,'Verified payments',NOW());

--------------------------------------------------

-- usage history

INSERT INTO usage_history VALUES
(NULL,11,'March',210),
(NULL,11,'April',230),
(NULL,12,'March',180),
(NULL,12,'April',200);

--------------------------------------------------

-- change more 1
-- change more 2
-- added bulk data
-- extended dataset manually