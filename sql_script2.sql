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
DO
BEGIN
    UPDATE prices
    SET price = price * (1+randomPercentage());
END//
DELIMITER ;
-- End of function and event for calculating new prices 


-- Example of delete statement, note that by "ON DELETE CASCADE" this deletes all related rows too
DELETE FROM Customer WHERE id = 1;


