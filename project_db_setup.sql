DROP DATABASE IF EXISTS issue_bank;
CREATE DATABASE issue_bank ; 
USE issue_bank;


CREATE TABLE customer(
	id INT AUTO_INCREMENT,
    name TEXT NOT NULL, 							
    date_of_birth DATE NOT NULL,
    join_date DATE DEFAULT NOW(),
    PRIMARY KEY (id)
);

CREATE TABLE deposit(
	number INT DEFAULT 1,				
    customer_id INT,
    name VARCHAR(20),					
    startup_date DATE NOT NULL,					
    currency VARCHAR(3) NOT NULL,
    PRIMARY KEY(number, customer_id),
    FOREIGN KEY(customer_id) REFERENCES customer(id) ON DELETE CASCADE
);


CREATE TABLE currency(
    valuta ENUM("DKK", "USD", "BTC", "EUR", "GBP"),
    date DATE,
    exchange_rate FLOAT NOT NULL,
    PRIMARY KEY(valuta, date)
);


CREATE TABLE issue(
	isin VARCHAR(12) PRIMARY KEY, 			
    name VARCHAR(20) NOT NULL,
    type ENUM("stock", "bond") NOT NULL,
    volume INT NOT NULL,
    valuta ENUM("DKK", "USD", "BTC", "EUR", "GBP") NOT NULL, 
    FOREIGN KEY(valuta) REFERENCES currency
);

# Assumes no fractional shares
CREATE TABLE trades(
	issue_isin VARCHAR(12),
    deposit_number INT,
    customer_id INT,
    date DATE,
    amount INT NOT NULL,
    PRIMARY KEY(issue_isin, deposit_number, customer_id, date),
    FOREIGN KEY(deposit_number) REFERENCES deposit(number),
    FOREIGN KEY(customer_id) REFERENCES customer(id) ON DELETE CASCADE,
    FOREIGN KEY(issue_isin) REFERENCES issue(isin)
);

CREATE TABLE prices(
	isin VARCHAR(12), 
    date DATE,
	price FLOAT NOT NULL,
    PRIMARY KEY (isin, date),
    FOREIGN KEY (isin) REFERENCES issue
);

/*
Nice to have views: 
	- Account balance
	- Security market cap
    - Customer balance
    
Possible extensions to setup:
	- Update price more than daily
    - Be able to see price at buy time, so that we can calculate PL e.g. in a view
*/

/* 
    - Inserting data into setup 
*/

-- Inserting data into `customer`
INSERT INTO customer (name, date_of_birth, join_date) VALUES
('Elena Smith', '1998-12-05', '2022-03-15'),
('John Doe', '1969-08-13', '2022-07-22'),
('Michael Johnson', '1998-11-21', '2023-01-05'),
('Sophia Brown', '1964-04-28', '2023-02-17'),
('Lucas Davis', '1958-09-05', '2023-04-12'),
('Emma Wilson', '1998-02-09', '2022-08-30'),
('Olivia Martinez', '1982-06-12', '2022-11-19'),
('Liam Anderson', '1970-11-20', '2023-03-07'),
('Ava Thompson', '1964-08-04', '2022-05-25'),
('Isabella Garcia', '1956-05-28', '2022-12-14');


-- Inserting data into `deposit`
INSERT INTO deposit (number, customer_id, name, startup_date, currency) VALUES
(1, 1, 'Savings Account', '2022-03-20', 'DKK'),
(2, 1, 'Holiday Fund', '2022-04-15', 'DKK'),
(3, 2, 'Emergency Fund', '2022-08-01', 'DKK'),
(4, 2, 'Crypto Investment', '2022-09-10', 'BTC'),
(5, 3, 'House Savings', '2023-01-10', 'DKK'),
(6, 4, 'Education Fund', '2023-02-20', 'DKK'),
(7, 5, 'Retirement Fund', '2023-04-15', 'DKK'),
(8, 6, 'Travel Wallet', '2022-09-01', 'DKK'),
(9, 7, 'Rainy Day Fund', '2022-12-01', 'DKK'),
(10, 8, 'Investment Portfolio', '2023-03-15', 'DKK'),
(11, 9, 'Wedding Savings', '2022-06-01', 'DKK'),
(12, 10, 'Golden Years', '2022-12-20', 'DKK');


-- Inserting data into `currency`
INSERT INTO currency (valuta, date, exchange_rate) VALUES
('DKK', '2023-01-01', 1.0),
('DKK', '2023-02-01', 1.0),
('DKK', '2023-03-01', 1.0),
('DKK', '2023-04-01', 1.0),
('USD', '2023-01-01', 1.45),
('USD', '2023-02-01', 1.50),
('USD', '2023-03-01', 1.55),
('USD', '2023-04-01', 1.48),
('BTC', '2023-01-01', 25000.00),
('BTC', '2023-02-01', 30000.00),
('BTC', '2023-03-01', 35000.00),
('BTC', '2023-04-01', 33000.00),
('EUR', '2023-01-01', 1.10),
('EUR', '2023-02-01', 1.15),
('EUR', '2023-03-01', 1.12),
('EUR', '2023-04-01', 1.18),
('GBP', '2023-01-01', 1.30),
('GBP', '2023-02-01', 1.35),
('GBP', '2023-03-01', 1.32),
('GBP', '2023-04-01', 1.28);


-- Inserting data into `issue`
INSERT INTO issue (isin, name, type, volume, valuta) VALUES
('DK0009806740', 'Vestas Wind Systems', 'stock', 6714, 'DKK'),
('US0378331005', 'Apple Inc. Bond', 'bond', 3835, 'USD'),
('BTC000000001', 'Bitcoin Tracker One', 'stock', 8346, 'BTC'),
('DK0009816458', 'Danske Bank Bond', 'bond', 2575, 'DKK'),
('US0231351067', 'Amazon.com Inc.', 'stock', 7648, 'USD'),
('EU000A1G0V05', 'Siemens AG', 'stock', 4500, 'EUR'),
('GB0031348658', 'GlaxoSmithKline PLC', 'stock', 3000, 'GBP'),
('US5949181045', 'Microsoft Corp. Bond', 'bond', 5000, 'USD'),
('DK0010268606', 'Carlsberg Group A/S', 'stock', 2200, 'DKK'),
('EU000A1G0V00', 'Volkswagen AG', 'stock', 4100, 'EUR'),
('GB0009252882', 'BP PLC', 'stock', 6200, 'GBP'),
('US38259P5089', 'Google Inc. Bond', 'bond', 2500, 'USD'),
('BTC000000002', 'Ethereum Tracker One', 'stock', 9000, 'BTC');


-- Inserting data into `investment`
INSERT INTO trades (issue_isin, deposit_number, customer_id, date, amount) VALUES
('US0378331005', 7, 5, '2023-04-17', 1000), -- Apple Inc. Bond investment by Lucas Davis
('DK0009806740', 9, 7, '2023-01-02', 2000), -- Vestas Wind Systems investment by Olivia Martinez
('EU000A1G0V05', 11, 9, '2022-07-01', 1500), -- Siemens AG investment by Ava Thompson
('GB0009252882', 10, 8, '2023-03-18', 2500), -- BP PLC investment by Liam Anderson
('US0231351067', 12, 10, '2023-01-05', 3000), -- Amazon.com Inc. stock investment by Isabella Garcia
('BTC000000002', 1, 1, '2023-03-21', 0.2),  -- Ethereum Tracker One investment by Elena Smith
('EU000A1G0V00', 3, 2, '2022-08-15', 4000), -- Volkswagen AG investment by John Doe
('GB0031348658', 5, 3, '2023-02-11', 1000), -- GlaxoSmithKline PLC investment by Michael Johnson
('DK0010268606', 6, 4, '2023-03-01', 500),  -- Carlsberg Group A/S investment by Sophia Brown
('US5949181045', 8, 6, '2022-09-05', 750);  -- Microsoft Corp. Bond investment by Emma Wilson



-- Inserting data into `prices`
INSERT INTO prices (isin, date, price) VALUES
('DK0009806740', '2023-06-13', 169.5), -- Vestas Wind Systems on 2023-06-13
('DK0009806740', '2022-02-08', 221.3), -- Vestas Wind Systems on 2022-02-08
('DK0009806740', '2021-05-24', 245.7), -- Vestas Wind Systems on 2021-05-24
('US0378331005', '2022-11-08', 103.4), -- Apple Inc. Bond on 2022-11-08
('US0378331005', '2021-09-13', 101.5), -- Apple Inc. Bond on 2021-09-13
('BTC000000001', '2023-06-13', 29000),  -- Bitcoin Tracker One on 2023-06-13
('BTC000000001', '2022-02-08', 40000),  -- Bitcoin Tracker One on 2022-02-08
('BTC000000001', '2021-05-24', 35000),  -- Bitcoin Tracker One on 2021-05-24
('US0231351067', '2022-11-08', 3110.77), -- Amazon.com Inc. on 2022-11-08
('US0231351067', '2021-09-13', 3345.55), -- Amazon.com Inc. on 2021-09-13
('EU000A1G0V05', '2023-06-13', 140.4),  -- Siemens AG on 2023-06-13
('EU000A1G0V05', '2022-02-08', 132.2),  -- Siemens AG on 2022-02-08
('EU000A1G0V05', '2021-05-24', 125.6),  -- Siemens AG on 2021-05-24
('DK0009816458', '2023-04-01', 105.75), -- Danske Bank Bond
('EU000A1G0V00', '2023-03-01', 154.3),  -- Volkswagen AG
('GB0031348658', '2023-02-01', 18.67),  -- GlaxoSmithKline PLC
('US5949181045', '2023-01-01', 305.2),  -- Microsoft Corp. Bond
('DK0010268606', '2022-12-01', 1100.00),-- Carlsberg Group A/S
('GB0009252882', '2022-11-01', 5.32),   -- BP PLC
('US38259P5089', '2022-10-01', 2784.4), -- Google Inc. Bond
('BTC000000002', '2022-09-01', 32000);  -- Ethereum Tracker One




# DELIMITER //
# CREATE FUNCTION calc_trade_value (isin VARCHAR(12), trade_date date, d_number int, c_id int)
# 	RETURNS FLOAT
# 	BEGIN
# 		DECLARE amt INT;
#         DECLARE p FLOAT;
# 		SELECT 
# 				trades.amount INTO amt 
#             FROM 
# 				trades 
# 			WHERE 
# 				trades.issue_isin = isin AND 
# 				trades.date = trade_date AND 
# 				trades.deposit_number = d_number AND 
# 				trades.customer_id = c_id;
# 		SELECT 
# 				price INTO p
#             FROM 
# 				prices
#             WHERE 
#             prices.date = trade_date;
# 		
# 	END//
# DELIMITER ;


# CREATE FUNCTION customer_investment_value (c_id int, d date)
# 	RETURNS FLOAT
# 	



