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







-- Trigger -> Before create af trade, check om der eksisterer en pris på den givne dato på den givne issue
DELIMITER $$
CREATE TRIGGER Trades_Before_Insert
BEFORE INSERT ON trades FOR EACH ROW
BEGIN 
    IF NEW.date NOT IN (SELECT prices.date FROM prices);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The trade date does not exist in the prices table.';
    ENDIF;
END$$
DELIMITER ;

-- Age Function
DELIMITER $$
CREATE FUNCTION CalculateAge(birthdate DATE) RETURNS INT
BEGIN 
    RETURN TIMESTAMPDIFF(YEAR, birthdate, NOW());
END$$
DELIMITER ;

-- Example of update statement - flag all customers with an invalid age (AE = Age Error)
UPDATE Customer
SET name = CONCAT("AE_", name)
WHERE CalculateAge(birthdate);

-- Example of delete - delete all customers flagged with "AE_"
DELETE FROM Customer 
WHERE name LIKE "AE_%";


