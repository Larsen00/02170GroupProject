# HUSK AT SLET
# 10 Rules for a Better SQL Schema
# Only Use Lowercase Letters, Numbers, and Underscores. ...
# Use Simple, Descriptive Column Names. ...
# Use Simple, Descriptive Table Names. ...
# Have an Integer Primary Key. ...
# Be Consistent with Foreign Keys. ...
# Store Datetimes as Datetimes. ...
# UTC, Always UTC. ...
# Have One Source of Truth.


DROP DATABASE IF EXISTS ISSUE_bank;
CREATE DATABASE ISSUE_BANK ; 
USE ISSUE_BANK;

# DROP TABLE IF EXISTS Customer;  
# DROP TABLE IF EXISTS Account;
# DROP TABLE IF EXISTS Investment;
# DROP TABLE IF EXISTS Security;
# DROP TABLE IF EXISTS Currency;

CREATE TABLE customer(
	id INT AUTO_INCREMENT,
    name TEXT, 							# Tænker vi laver en before save som tjekker om navnet er gyldigt (ingen tal og sådan)
    date_of_birth DATE,
    join_date DATE DEFAULT NOW(),
    PRIMARY KEY (id)
);

CREATE TABLE deposit(
	number INT DEFAULT 1,				# syntes når attributet tulhøre tabellen er det ikke nødvendigt at skrive tabel navnet først
    customer_id INT,
    name VARCHAR(20),					# ikke sikker hvorfor den skal have et navn
    startup_date DATE,					# var created 
    currenci VARCHAR(3),
    PRIMARY KEY(number, customer_id),
    FOREIGN KEY(customer_id) REFERENCES customer(id)
);


CREATE TABLE currency(
    valuta ENUM("DKK", "USD", "BTC"),
    date DATE,
    exchange_ratei FLOAT,
    PRIMARY KEY(valuta, date)
);



CREATE TABLE issue(
	isin VARCHAR(12) PRIMARY KEY, 			# vi kan kave en before svae og tjekke gyldighed
    name VARCHAR(20),
    type ENUM("stock", "bond", "crypto") NOT NULL,
    volume INT,
    valuta ENUM("DKK", "USD", "BTC"), 
    FOREIGN KEY(valuta) REFERENCES currency
    # price_date DATE, 
	# price_currency ENUM("DKK", "USD", "BTC"),    			# Lad os lave en price tabel i stedet
	# unit_price FLOAT,
    # FOREIGN KEY(price_currency, price_date) REFERENCES Currency
);

# Assumes no fractional shares
CREATE TABLE investment(
	id INT AUTO_INCREMENT,
	issue_isin VARCHAR(20),
    deposit_number INT,
    customer_id INT,
    trade_date DATE,
    amount INT,
    price FLOAT,
    value FLOAT, 		# behøves måske ikke da den regnes fra amount * price
    # PRIMARY KEY(isin, deposit_number, customer_id),     # man kan vel godt købe samme akite i samme deport mere end en gang på samme dag
    PRIMARY KEY(id),
    FOREIGN KEY(deposit_number) REFERENCES deposit(number),
    FOREIGN KEY(customer_id) REFERENCES customer(id),
    FOREIGN KEY(issue_isin) REFERENCES issue(isin)
);

CREATE TABLE prices(
	isin VARCHAR(12),
    date DATE,
	price FLOAT,
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



