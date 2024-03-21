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
    currenci VARCHAR(3) NOT NULL,
    PRIMARY KEY(number, customer_id),
    FOREIGN KEY(customer_id) REFERENCES customer(id)
);


CREATE TABLE currency(
    valuta ENUM("DKK", "USD", "BTC"),
    date DATE,
    exchange_rate FLOAT NOT NULL,
    PRIMARY KEY(valuta, date)
);


CREATE TABLE issue(
	isin VARCHAR(12) PRIMARY KEY, 			
    name VARCHAR(20) NOT NULL,
    type ENUM("stock", "bond") NOT NULL,
    volume INT NOT NULL,
    valuta ENUM("DKK", "USD", "BTC") NOT NULL, 
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
    FOREIGN KEY(customer_id) REFERENCES customer(id),
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

# Inserting data into setup
# TODO



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



