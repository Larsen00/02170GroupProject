# CREATE DATABASE HJ_BANK;
USE HJ_BANK;

DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Account;
DROP TABLE IF EXISTS Investment;
DROP TABLE IF EXISTS Security;
DROP TABLE IF EXISTS Currency;

CREATE TABLE Customer(
	customer_id INT AUTO_INCREMENT,
    name VARCHAR(20),
    date_of_birth DATE,
    join_date DATE DEFAULT NOW(),
    PRIMARY KEY(customer_id)
);

CREATE TABLE Account(
	account_number INT DEFAULT 1,
    customer_id INT,
    name VARCHAR(20),
    created DATE,
    PRIMARY KEY(account_number, customer_id),
    FOREIGN KEY(customer_id) REFERENCES Customer
);

# Assumes no fractional shares
CREATE TABLE Investment(
	isin VARCHAR(20),
    account_number INT,
    customer_id INT,
    buy_date DATE,
    count INT,
    PRIMARY KEY(isin, account_number, customer_id),
    FOREIGN KEY(account_number, customer_id) REFERENCES Account,
    FOREIGN KEY(customer_id) REFERENCES Customer
);

CREATE TABLE Currency(
    price_currency ENUM("DKK", "USD", "BTC"),
    price_date DATE,
    factor FLOAT,
    PRIMARY KEY(price_currency, price_date)
);

CREATE TABLE Security(
	isin VARCHAR(20) PRIMARY KEY,
    name VARCHAR(20),
    type ENUM("stock", "bond", "crypto") NOT NULL,
    volume INT,
    price_date DATE,
    price_currency ENUM("DKK", "USD", "BTC"),
    unit_price FLOAT,
    FOREIGN KEY(price_currency, price_date) REFERENCES Currency
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



