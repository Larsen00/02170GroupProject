USE ISSUE_BANK;

-- Function and event for calculating new prices 

DELIMITER //
CREATE FUNCTION randomPercentage() RETURNS DECIMAL(5,2)
BEGIN
    DECLARE rand_num DECIMAL(5,2);
    
    repeat
    -- Generate a random number between -3% and 4%
    SET rand_num = RAND() * 0.07 - 0.04;
    until rand_num != 0 end repeat;
    
    RETURN rand_num;
END//
DELIMITER ;

SET GLOBAL event_scheduler = 1;

DELIMITER //

CREATE EVENT new_prices
ON SCHEDULE EVERY 1 day
STARTS CURRENT_TIMESTAMP + INTERVAL 1 DAY
DO
BEGIN
    UPDATE prices
    SET price = price * (1+randomPercentage());
END//
DELIMITER ;
-- End of function and event for calculating new prices 

select * from prices;



-- Before save deposit
DELIMITER //
CREATE TRIGGER deposit_before_save
BEFORE INSERT ON deposit FOR EACH ROW
BEGIN
    DECLARE deposits_count INT;
    SELECT COUNT(*) INTO deposits_count FROM deposit WHERE customer_id = NEW.customer_id;
    IF deposits_count IS NULL THEN
        SET NEW.number = 1;
    ELSE
        SET NEW.number = deposits_count + 1;
    END IF;
END //
DELIMITER ;



-- Trigger -> Before create af trade, check om der eksisterer en pris på den givne dato på den givne issue
DELIMITER $$
CREATE TRIGGER Trades_Before_Insert
BEFORE INSERT ON trades FOR EACH ROW
BEGIN 
    IF NEW.date NOT IN (SELECT prices.date FROM prices)
       THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The trade date does not exist in the prices table.';
    END IF;
END $$
DELIMITER ;

-- Age Function
DELIMITER $$

CREATE FUNCTION CalculateAge(birthdate DATE) RETURNS INT
BEGIN 
    RETURN TIMESTAMPDIFF(YEAR, birthdate, CURDATE());
END$$

CREATE TRIGGER customer_Before_insert
BEFORE INSERT ON customer FOR EACH ROW
BEGIN
    IF CalculateAge(NEW.date_of_birth) < 18 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer is underaged';
    END IF;
END$$

DELIMITER ;
-- Function and trigger for checking ISIN validity
DELIMITER //
CREATE FUNCTION checkIsin(isin varchar(12)) RETURNS BOOLEAN
BEGIN
    DECLARE firstChar VARCHAR(1);
    DECLARE secondChar VARCHAR(1);
    DECLARE restOfString VARCHAR(10);
    
    SET firstChar = LEFT(isin, 1);
    SET secondChar = SUBSTRING(isin, 2,1);
	SET restOfString = SUBSTRING(isin, 3,10);

    IF ((ASCII(firstChar) BETWEEN 65 AND 90)  AND (ASCII(secondChar) BETWEEN 65 AND 90) AND restOfString REGEXP '^[0-9]+$') THEN
        RETURN TRUE;
    ELSE RETURN FALSE;
    END IF;
END //


CREATE TRIGGER trades_Before_insert 
BEFORE INSERT ON trades FOR EACH ROW
BEGIN
	# Raise and error if isin is invalid
  IF NOT checkIsin(NEW.issue_isin) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ISIN is invalid';
  END IF;
END //
-- END OF Function and trigger for checking ISIN validity



-- Queries Opgave 6
-- Give three examples of typical SQL query statements using joins, group by,
-- and set operations like UNION and IN. For each query explain informally
-- what it asks about. Show also the output of the queries.


-- number of people with pension accounts
SELECT COUNT(*) AS "pension accounts" FROM deposit WHERE deposit.name LIKE '%Pension%'; 

-- sum of money invested for each customer
SELECT customer_id, SUM(p.price) FROM trades t JOIN prices p ON t.issue_isin = p.isin AND t.date = p.date GROUP BY t.customer_id;


-- Example of update statement - flag all customers with an invalid age (AE = Age Error)
UPDATE Customer
SET name = CONCAT("AE_", name)
WHERE CalculateAge(birthdate);

-- Example of delete - delete all customers flagged with "AE_"
DELETE FROM Customer 
WHERE name LIKE "AE_%";




