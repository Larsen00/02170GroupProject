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



select * from prices;



