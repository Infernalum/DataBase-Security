
/* Creating synonyms */
CREATE PUBLIC SYNONYM AccessLevelsPs 
FOR Infernal.AccessLevels;

CREATE PUBLIC SYNONYM AssignedCasesPs 
FOR Infernal.AssignedCases;

CREATE PUBLIC SYNONYM CasesPs 
FOR Infernal.Cases;

CREATE PUBLIC SYNONYM DepartmentsPs 
FOR Infernal.Departments;

CREATE PUBLIC SYNONYM EmployeesPs 
FOR Infernal.Employees;

CREATE PUBLIC SYNONYM OfficeHoursPs 
FOR Infernal.OfficeHours;

CREATE PUBLIC SYNONYM PeckingOrderPs 
FOR Infernal.PeckingOrder;

CREATE PUBLIC SYNONYM PostsPs 
FOR Infernal.Posts;

CREATE PUBLIC SYNONYM StatusStatesPs 
FOR Infernal.StatusStates;

CREATE PUBLIC SYNONYM WeekDayPs 
FOR Infernal.WeekDay;

CREATE PUBLIC SYNONYM WorkSchedulePs 
FOR Infernal.WorkSchedule;


/* Creating accounting_dep role */

ALTER TABLE Infernal.Employees
ADD SALARY NUMBER(6,-3);  

ALTER TABLE Infernal.Employees
MODIFY (SALARY NUMBER(6, -3) NOT NULL);


CREATE ROLE Accounting_dep
    IDENTIFIED BY thebestmen;
    
GRANT CREATE SESSION                    TO accounting_dep;

GRANT SELECT        ON AccessLevelsPs   TO accounting_dep;
GRANT SELECT        ON AssignedCasesPs  TO accounting_dep;

GRANT 
    SELECT,
    INSERT          ON CasesPs          TO accounting_dep;

GRANT SELECT        ON DepartmentsPs    TO accounting_dep;
GRANT 
    SELECT, 
    UPDATE(SALARY)  ON EmployeesPs      TO accounting_dep;
    
GRANT SELECT        ON OfficeHoursPs    TO accounting_dep;
GRANT SELECT        ON PeckingOrderPs   TO accounting_dep;
GRANT SELECT        ON PostsPs          TO accounting_dep;
GRANT SELECT        ON StatusStatesPs   TO accounting_dep;
GRANT SELECT        ON WeekDayPs        TO accounting_dep;
GRANT SELECT        ON WorkSchedulePs   TO accounting_dep;



/* Creating hr_dep role */

CREATE ROLE hr_dep
    IDENTIFIED BY whatdowewant;
    
GRANT CREATE SESSION                TO hr_dep;

GRANT SELECT ON AccessLevelsPs      TO hr_dep;
GRANT SELECT ON DepartmentsPs       TO hr_dep;

GRANT 
    SELECT,
    INSERT,
    DELETE      ON EmployeesPs      TO hr_dep;

GRANT SELECT    ON OfficeHoursPs    TO hr_dep;
GRANT SELECT    ON PeckingOrderPs   TO hr_dep;
GRANT SELECT    ON PostsPs          TO hr_dep;
GRANT SELECT    ON StatusStatesPs   TO hr_dep;
GRANT SELECT    ON WeekDayPs        TO hr_dep;
GRANT SELECT    ON WorkSchedulePs   TO hr_dep;



/* Creating leadership_dep role */

CREATE ROLE leadership_dep
    IDENTIFIED BY bigboss;
    
GRANT CREATE SESSION TO leadership_dep;

GRANT SELECT ON AccessLevelsPs      TO leadership_dep;

GRANT
    SELECT,
    INSERT,
    UPDATE,
    DELETE      ON AssignedCasesPs  TO leadership_dep;

GRANT 
    SELECT,
    INSERT, 
    UPDATE,
    DELETE      ON CasesPs          TO leadership_dep;

GRANT SELECT    ON DepartmentsPs    TO leadership_dep;

GRANT 
    SELECT,
    UPDATE
    (
        post_id,
        department_id, 
        access_level_id
    )           ON EmployeesPs      TO leadership_dep;

GRANT SELECT    ON OfficeHoursPs    TO leadership_dep;
GRANT SELECT    ON PeckingOrderPs   TO leadership_dep;
GRANT SELECT    ON PostsPs          TO leadership_dep;
GRANT SELECT    ON StatusStatesPs   TO leadership_dep;
GRANT SELECT    ON WeekDayPs        TO leadership_dep;

GRANT 
    SELECT,
    INSERT,
    UPDATE,
    DELETE      ON WorkSchedulePs   TO leadership_dep;


/* Creating employee_dep role */

CREATE ROLE employee_dep
    IDENTIFIED BY guyfox;
    
GRANT CREATE SESSION                TO employee_dep;

GRANT SELECT    ON AssignedCasesPs  TO employee_dep;
GRANT SELECT    ON CasesPs          TO employee_dep;
GRANT SELECT    ON WorkSchedulePs   TO employee_dep;
GRANT SELECT    ON OfficeHoursPs    TO employee_dep;
GRANT SELECT    ON WeekDayPs        TO employee_dep;





/* Creating medical_dep role */

ALTER TABLE Infernal.Employees
ADD med_rec CHAR(100);

ALTER TABLE Infernal.Employees
MODIFY (med_rec CHAR(100) NOT NULL);


CREATE ROLE medical_dep
    IDENTIFIED BY dexter;
    
GRANT CREATE SESSION                    TO medical_dep;

GRANT 
    SELECT, 
    INSERT,
    UPDATE          ON AssignedCasesPs  TO medical_dep;

GRANT 
    SELECT          ON CasesPs          TO medical_dep;

GRANT 
    SELECT,
    UPDATE(med_rec) ON EmployeesPs      TO medical_dep;
    
GRANT SELECT        ON OfficeHoursPs    TO medical_dep;
GRANT SELECT        ON WeekDayPs        TO medical_dep;
GRANT SELECT        ON WorkSchedulePs   TO medical_dep;




ALTER PROFILE password_prof LIMIT
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 1/24;
    
    
    

CREATE USER Nadya
    IDENTIFIED BY 1234
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    QUOTA 100M ON users;

GRANT accounting_dep TO Nadya;


CREATE USER John 
    IDENTIFIED BY 1234
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    QUOTA 100M ON users;
    
GRANT CREATE SESSION TO John;

GRANT employee_dep TO John;


CREATE USER Morgan 
    IDENTIFIED BY 1234
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    QUOTA 100M ON users;
    
GRANT CREATE SESSION TO Morgan;

GRANT medical_dep TO Morgan;


CREATE USER Skinner 
    IDENTIFIED BY 1234
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    QUOTA 100M ON users;
    
GRANT CREATE SESSION TO Skinner;

GRANT leadership_dep TO Skinner;





