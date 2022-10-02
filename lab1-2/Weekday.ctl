OPTIONS (SKIP=1)
LOAD DATA
CHARACTERSET UTF8
INFILE 'WeekDay.csv'
TRUNCATE
INTO TABLE INFERNAL.WEEKDAY2
FIELDS TERMINATED BY ";"
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
( day_id, description char(30) )