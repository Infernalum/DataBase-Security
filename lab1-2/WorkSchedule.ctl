OPTIONS (SKIP=1)
LOAD DATA
CHARACTERSET UTF8
INFILE 'WorkSchedule.csv'
TRUNCATE
INTO TABLE INFERNAL.WORKSCHEDULE2
FIELDS TERMINATED BY ";"
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
( employee_id, day_id, office_hours_id)