CREATE TABLE WeekDay
(
    day_id NUMBER(1,0),
    description VARCHAR2(20) NOT NULL,
    CONSTRAINT WeekDay_pk PRIMARY KEY (day_id)
);

CREATE TABLE OfficeHours
(
    office_hours_id NUMBER(2,0),
    start_time DATE NOT NULL,
    end_time DATE NOT NULL,
    CONSTRAINT OfficeHours_pk PRIMARY KEY (office_hours_id)
);

CREATE TABLE StatusStates
(
    status_id  NUMBER(1,0),
    description VARCHAR2(100) NOT NULL,
    CONSTRAINT StatusStates_pk PRIMARY KEY (status_id)
);

CREATE TABLE AccessLevels
(
    access_level_id  NUMBER(1,0),
    access_level NUMBER(2,0) NOT NULL,
    description VARCHAR2(200) NOT NULL,
    CONSTRAINT AccessLevels_pk PRIMARY KEY (access_level_id)
);

CREATE TABLE Posts
(
    post_id  NUMBER(2,0),
    access_level_id NOT NULL,
    post_name VARCHAR2(20) NOT NULL,
    CONSTRAINT Posts_pk 
        PRIMARY KEY (post_id),
    CONSTRAINT Posts_fk 
        FOREIGN KEY (access_level_id) 
        REFERENCES AccessLevels(access_level_id)
);

CREATE TABLE Departments
(
    department_id  NUMBER(2,0),
    department_name VARCHAR2(20) NOT NULL,
    description VARCHAR2(50) NOT NULL,
    CONSTRAINT Departments_pk PRIMARY KEY (department_id)
);


CREATE TABLE Cases
(
    case_id  NUMBER(7,0),
    department_id NOT NULL,
    status_id NOT NULL,
    access_level_id NOT NULL,
    start_date DATE,
    close_date DATE,
    CONSTRAINT Cases_pk PRIMARY KEY (case_id),
    CONSTRAINT Cases_fk_department
        FOREIGN KEY (department_id) 
        REFERENCES Departments(department_id),
    CONSTRAINT Cases_fk_status
        FOREIGN KEY (status_id) 
        REFERENCES StatusStates(status_id),
    CONSTRAINT Cases_fk_access
        FOREIGN KEY (access_level_id) 
        REFERENCES AccessLevels(access_level_id)
);

CREATE TABLE Employees
(
    employee_id  NUMBER(7,0),
    department_id NOT NULL,
    post_id NOT NULL,
    firsr_name VARCHAR2(15) NOT NULL,
    second_name VARCHAR2(15) NOT NULL,
    patronymic VARCHAR2(15),
    age NUMBER(2, 0) NOT NULL,
    employment_date DATE NOT NULL,
    CONSTRAINT Employees_pk PRIMARY KEY (employee_id),
    CONSTRAINT Employee_fk_department
        FOREIGN KEY (department_id) 
        REFERENCES Departments(department_id),
    CONSTRAINT Employees_fk_post
        FOREIGN KEY (post_id) 
        REFERENCES Posts(post_id)
        
);

CREATE TABLE WorkSchedule
(
    employee_id,
    day_id,
    office_hours_id,
    CONSTRAINT WorkSchedule_pk PRIMARY KEY (employee_id, day_id),
    CONSTRAINT WorkSchedule_fk_office_hours
        FOREIGN KEY (office_hours_id) 
        REFERENCES OfficeHours(office_hours_id),
    CONSTRAINT WorkSchedule_fk_employee
        FOREIGN KEY (employee_id) 
        REFERENCES Employees(employee_id),
    CONSTRAINT WorkSchedule_fk_day
        FOREIGN KEY (day_id) 
        REFERENCES WeekDay(day_id)
);

CREATE TABLE AssignedCases
(
    employee_id,
    case_id,
    CONSTRAINT AssignedCases_pk PRIMARY KEY (employee_id, case_id),
    CONSTRAINT AssignedCases_fk_employee
        FOREIGN KEY (employee_id) 
        REFERENCES Employees(employee_id),
    CONSTRAINT AssignedCases_fk_case
        FOREIGN KEY (case_id) 
        REFERENCES Cases(case_id)
        
);
