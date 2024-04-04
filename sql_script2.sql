USE ISSUE_BANK;

-- Function to generate a random percentage
DELIMITER //
CREATE PROCEDURE generateRandomPercentage(OUT rand_num DECIMAL(5,2))
BEGIN
    REPEAT
        -- Generate a random number between -4% and 3%
        SET rand_num = RAND() * 0.07 - 0.04;
    UNTIL rand_num != 0 END REPEAT;
END//
DELIMITER ;

-- Enable the event scheduler
SET GLOBAL event_scheduler = ON;

-- Create an event to update prices
DELIMITER //
CREATE EVENT new_prices
ON SCHEDULE EVERY 1 SECOND
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DECLARE rand_percentage DECIMAL(5,2);
    CALL generateRandomPercentage(rand_percentage);
    
    UPDATE prices
    SET price = price * (1 + rand_percentage);
END//
DELIMITER ;

-- Enable the new_prices event
ALTER EVENT new_prices ENABLE;

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
CREATE TRIGGER Trades_Date_Before_Insert
BEFORE INSERT ON trades FOR EACH ROW
BEGIN 

    IF NEW.date NOT IN (SELECT prices.date FROM prices) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The trade date does not exist in the prices table.';
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
CREATE TRIGGER trades_Before_insert 
BEFORE INSERT ON trades FOR EACH ROW
BEGIN
	# Raise and error if isin is invalid
  IF NOT checkIsin(NEW.issue_isin) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ISIN is invalid';
  END IF;
END //


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
DELIMITER ;
-- END OF Function and trigger for checking ISIN validity

-- Queries Opgave 6
-- number of trades made by each customer
SELECT c.name, COUNT(*) AS numOfTrades
FROM customer c
JOIN trades t ON c.id = t.customer_id
GROUP BY c.name;

-- customers who have either made trades or have deposits.
SELECT name FROM customer WHERE id IN (SELECT customer_id FROM trades)
UNION
SELECT name FROM customer WHERE id IN (SELECT customer_id FROM deposit);

-- average volume of trades for each issue type
SELECT i.type, AVG(t.amount) AS avg_volume
FROM trades t
JOIN issue i ON t.issue_isin = i.isin
GROUP BY i.type;

-- Example of update statement - flag all customers with an invalid age (AE = Age Error)
UPDATE Customer
SET name = CONCAT("AE_", name)
WHERE CalculateAge(date_of_birth) < 18;


-- Example of delete - delete all customers flagged with "AE_"
DELETE FROM Customer 
WHERE name LIKE "AE_%";




