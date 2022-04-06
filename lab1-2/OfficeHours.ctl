OPTIONS (SKIP=1)
LOAD DATA
CHARACTERSET UTF8
INFILE 'OfficeHours.csv'
INTO TABLE INFERNAL.OFFICEHOURS2
FIELDS TERMINATED BY ";"
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
( office_hours_id, start_time DATE "YYYY-MM-DD:HH24:MI:SS", end_time DATE "YYYY-MM-DD:HH24:MI:SS")