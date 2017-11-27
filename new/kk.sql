\connect sample
select * from company;
 CREATE TEMP TABLE tmp (
        ID INT     NOT NULL,
        key       int NOT NULL
	);

COPY tmp FROM '/tmp/data/t1.txt' WITH (DELIMITER ',') ;
    INSERT INTO company (
        id, key)    
	SELECT id, key  FROM tmp;
DROP TABLE tmp;
COMMIT;
