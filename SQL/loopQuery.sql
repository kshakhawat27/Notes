TRUNCATE table con.Category c

SELECT * FROM con.Category c 
ORDER BY c.id desc

DECLARE @init INT=1;
WHILE(@init<=500)
BEGIN
INSERT INTO con.Category 
SELECT 'item'+CAST(@init AS VARCHAR(10)),'note'+CAST(@init AS varchar(10)),1,GETDATE(),NULL,NULL,1

SET @init=@init+1;
end


