OPTIONS (SKIP=1)
LOAD DATA
CHARACTERSET UTF8
INFILE 'Employees.csv'
INTO TABLE INFERNAL.EMPLOYEES2
FIELDS TERMINATED BY ";"
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
( employee_id, department_id, post_id, access_level_id, first_name char(30), second_name char(30), patronymic char(30), age, employment_date DATE "YYYY-MM-DD:HH24:MI:SS" )