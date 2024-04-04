DROP DATABASE IF EXISTS issue_bank;
CREATE DATABASE issue_bank ; 
USE issue_bank;


CREATE TABLE customer(
	id INT AUTO_INCREMENT ,
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
    FOREIGN KEY(deposit_number) REFERENCES deposit(number) ON DELETE CASCADE,
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
INSERT INTO customer (name, date_of_birth, join_date) VALUE
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
(1, 2, 'Emergency Fund', '2022-08-01', 'DKK'),
(2, 2, 'Crypto Investment', '2022-09-10', 'BTC'),
(1, 3, 'House Savings', '2023-01-10', 'DKK'),
(1, 4, 'Education Fund', '2023-02-20', 'DKK'),
(1, 5, 'Retirement Fund', '2023-04-15', 'DKK'),
(1, 6, 'Travel Wallet', '2022-09-01', 'DKK'),
(1, 7, 'Rainy Day Fund', '2022-12-01', 'DKK'),
(1, 8, 'Investment Portfolio', '2023-03-15', 'DKK'),
(1, 9, 'Wedding Savings', '2022-06-01', 'DKK'),
(1, 10, 'Golden Years', '2022-12-20', 'DKK');


-- Inserting data into `currency`
INSERT INTO currency (valuta, date, exchange_rate)
VALUES
('USD', '2022-01-01', 1.48),
('DKK', '2022-01-01', 1.0),
('EUR', '2022-01-01', 1.10),
('GBP', '2022-01-01', 1.35),
('BTC', '2022-01-01', 33000.00);




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
('US0378331005', 1, 5, '2023-04-17', 1000), -- Apple Inc. Bond investment by Lucas Davis
('DK0009806740', 1, 7, '2023-01-02', 2000), -- Vestas Wind Systems investment by Olivia Martinez
('EU000A1G0V05', 1, 9, '2022-07-01', 1500), -- Siemens AG investment by Ava Thompson
('GB0009252882', 1, 8, '2023-03-18', 2500), -- BP PLC investment by Liam Anderson
('US0231351067', 1, 10, '2023-01-05', 3000), -- Amazon.com Inc. stock investment by Isabella Garcia
('BTC000000002', 1, 1, '2023-03-21', 2),  -- Ethereum Tracker One investment by Elena Smith
('EU000A1G0V00', 1, 2, '2022-08-15', 4000), -- Volkswagen AG investment by John Doe
('GB0031348658', 1, 3, '2023-02-11', 1000), -- GlaxoSmithKline PLC investment by Michael Johnson
('DK0010268606', 1, 4, '2023-03-01', 500),  -- Carlsberg Group A/S investment by Sophia Brown
('US5949181045', 1, 6, '2022-09-05', 750),  -- Microsoft Corp. Bond investment by Emma Wilson
('EU000A1G0V00', 1, 2, '2023-08-15', -2000), -- Volkswagen AG investment by John Doe
('EU000A1G0V00', 1, 2, '2022-09-15', -2000); -- Volkswagen AG investment by John Doe



-- Inserting data into `prices`
INSERT INTO prices (isin, date, price) VALUES
('US0378331005', '2023-04-17', 1), -- Apple Inc. Bond on 2023-04-17
('DK0009806740', '2023-01-02', 169.5), -- Vestas Wind Systems, matching the closest available date
('EU000A1G0V05', '2022-07-01', 140.4), -- Siemens AG on 2022-07-01
('GB0009252882', '2023-03-18', 5.32), -- BP PLC on 2023-03-18
('US0231351067', '2023-01-05', 3110.77), -- Amazon.com Inc. on 2023-01-05
('BTC000000002', '2023-03-21', 32000), -- Ethereum Tracker One on 2023-03-21
('EU000A1G0V00', '2022-08-15', 150), -- Volkswagen AG on 2022-08-15, 
('GB0031348658', '2023-02-11', 18.67), -- GlaxoSmithKline PLC on 2023-02-11
('DK0010268606', '2023-03-01', 1100.00), -- Carlsberg Group A/S on 2023-03-01
('US5949181045', '2022-09-05', 305.2), -- Microsoft Corp. Bond on 2022-09-05
('EU000A1G0V00', '2023-03-01', 300), 
('EU000A1G0V00', '2022-09-15', 300); 


DELIMITER //
CREATE FUNCTION supremum_valuta_date (d DATE, v VARCHAR(3))
	RETURNS DATE
    BEGIN
		DECLARE s_date DATE;
		SELECT
				MAX(date) into s_date
			FROM
				currency
			WHERE 
				currency.valuta = v AND
				currency.date <= d;
		RETURN s_date;
	END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION supremum_price_date (d DATE, isin VARCHAR(12))
	RETURNS DATE
    BEGIN
		DECLARE s_date DATE;
		SELECT
				MAX(date) into s_date
			FROM
				prices
			WHERE 
				prices.isin = isin AND
				prices.date <= d;
		RETURN s_date;
	END//
DELIMITER ;


DELIMITER //
CREATE FUNCTION convert_currency (f VARCHAR(3), t VARCHAR(3), d DATE)
	RETURNS float
    BEGIN
		DECLARE xr1 FLOAT;
		DECLARE xr2 FLOAT;
		SELECT 
				exchange_rate into xr1 
			FROM 
				currency
			WHERE 
				currency.valuta = f AND
				currency.date = supremum_valuta_date(d, f);
		SELECT 
				exchange_rate into xr2
			FROM 
				currency 
			WHERE 
				currency.valuta = t AND
				currency.date = supremum_valuta_date(d, t);
		 RETURN xr1/xr2;
	END//
DELIMITER ;
	

DELIMITER //
CREATE FUNCTION investment_value (amount int, isin VARCHAR(12), d date)
	RETURNS FLOAT
    BEGIN
		DECLARE p FLOAT;
			SELECT 
					price INTO p
				FROM 
					prices
				WHERE 
					prices.date = supremum_price_date(d, isin) AND
                    prices.isin = isin;
		RETURN p*amount;
    END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION calc_deposit_investment_value (amt int, isin VARCHAR(12), trade_date date, issue_valuta VARCHAR(3), deposit_valuta VARCHAR(3) )
	RETURNS DECIMAL(65,2)
	BEGIN
		RETURN investment_value(amt, isin, trade_date)*convert_currency(issue_valuta, deposit_valuta, trade_date);
	END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION calc_trade_value (amt int, isin VARCHAR(12), trade_date date, issue_valuta VARCHAR(3), deposit_valuta VARCHAR(3) )
	RETURNS DECIMAL(65,2)
	BEGIN
		RETURN calc_deposit_investment_value(amt, isin, trade_date, issue_valuta, deposit_valuta)*(-1);
	END//
DELIMITER ;


DELIMITER //
CREATE FUNCTION get_deposit_valuta (id INT, number INT)
RETURNS VARCHAR(3)
BEGIN
    DECLARE val VARCHAR(3);
    SELECT currency INTO val FROM deposit 
    WHERE number = number AND customer_id = id LIMIT 1;
    RETURN val;
END//
DELIMITER ;


DELIMITER //
CREATE FUNCTION get_issue_valuta (i VARCHAR(12))
	RETURNS VARCHAR(3)
    BEGIN
	DECLARE val VARCHAR(3);
	SELECT valuta INTO val FROM issue WHERE isin = i LIMIT 1;
	RETURN val;
    END//
DELIMITER ;


DELIMITER //
CREATE FUNCTION buy_or_sell (amt int)
	RETURNS TEXT
    BEGIN
    RETURN CASE
        WHEN amt > 0 THEN "buy"
        WHEN amt < 0 THEN "sell"
        ELSE NULL 
    END;
    END//
DELIMITER ;

CREATE VIEW all_trades_with_values AS 
	SELECT 
		T.customer_id, 
        deposit_number, 
        isin,
        D.currency as deposit_valuta,
        I.name, 
        date, 
        amount, 
        calc_trade_value(amount, isin, date, valuta, currency) as value,
        buy_or_sell(amount) as status
	FROM
		deposit as D 
	right join 
		trades as T 
	on 
		D.number = T.deposit_number AND 
        D.customer_id = T.customer_id 
    left join 
		issue as I 
	on 
		T.issue_isin = I.isin;

CREATE VIEW all_active_investments AS 
    SELECT
		T.customer_id,
		T.deposit_number, 
        T.issue_isin AS isin,
        T.amount,
        get_issue_valuta(T.issue_isin) AS issue_valuta,
        get_deposit_valuta(T.customer_id, T.deposit_number) AS deposit_valuta,
        calc_deposit_investment_value(T.amount, T.issue_isin, CURDATE(), get_issue_valuta(T.issue_isin), get_deposit_valuta(T.customer_id, T.deposit_number)) AS value,
        "active" as status
    FROM (
        SELECT 
            issue_isin, 
            deposit_number, 
            customer_id, 
            SUM(amount) AS amount
        FROM
            trades
        GROUP BY 
            issue_isin, 
            deposit_number, 
            customer_id
    ) AS T
    WHERE 
        T.amount <> 0;



CREATE VIEW customers_trades_values AS
	SELECT 
		I.customer_id, SUM(I.value_dkk) as value_dkk, I.status
	FROM
		(SELECT 
			customer_id,
			deposit_number,
			deposit_valuta,
			value,
			ROUND(value * convert_currency(deposit_valuta, 'DKK', CURDATE()), 2) as value_dkk,
			status
		FROM 
			all_active_investments
		UNION ALL  
		SELECT 
			customer_id,
			deposit_number,
			deposit_valuta,
			value,
			ROUND(value * convert_currency(deposit_valuta, 'DKK', CURDATE()), 2) as value_dkk,
			status
		FROM 
			all_trades_with_values) AS I
	GROUP BY 
		I.customer_id, I.status;
        
DELIMITER //
CREATE FUNCTION investments_return (id INT)
RETURNS FLOAT
BEGIN
    DECLARE investment DECIMAL(65,2);
    DECLARE value DECIMAL(65,2);
    DECLARE sells DECIMAL(65,2);
    SELECT value_dkk INTO investment FROM customers_trades_values WHERE customer_id = id AND status = 'buy';
    SELECT value_dkk INTO value FROM customers_trades_values WHERE customer_id = id AND status = 'active';
    SELECT value_dkk INTO sells FROM customers_trades_values WHERE customer_id = id AND status = 'sell';
    
    IF investment IS NULL THEN
		SELECT 0 INTO investment;
	END IF;
    
    IF value IS NULL THEN
		SELECT 0 INTO value;
	END IF;
    
    IF sells IS NULL THEN
		SELECT 0 INTO sells;
	END IF;
    
    IF investment = 0 THEN
        RETURN 0;
    ELSE
        RETURN (investment + value + sells) / ABS(investment);
    END IF;
END//
DELIMITER ;

select investments_return(2);

CREATE VIEW customer_investment_return as 
	SELECT *, investments_return(id) FROM customer;
    
SELECT * FROM customer_investment_return;
SELECT * from customers_trades_values;

select * from all_active_investments;
select * from all_trades_with_values;

SELECT value_dkk  FROM customers_trades_values WHERE customer_id = 2 AND status = 'buy';
    SELECT value_dkk  FROM customers_trades_values WHERE customer_id = 2 AND status = 'active';
    SELECT value_dkk  FROM customers_trades_values WHERE customer_id = 2 AND status = 'sell';