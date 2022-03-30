INSERT INTO employees 
(employee_id, department_id, post_id, access_level_id, first_name, second_name, patronymic, age, employment_date) 
VALUES 
(36, 15, 14, 44, 'Walter', 'Sergei', 'Skinner', 69, '11.09.86:00:00:00');





--2.1,2.2,2.3
--SELECT Employees.first_name, Employees.patronymic, Cases.case_id, Cases.status_id, Cases.case_name, Cases.description
--FROM    Employees,
--        Cases,
--        AssignedCases
--WHERE 
--        Employees.employee_id = 30
--AND
--        AssignedCases.employee_id = Employees.employee_id
--AND 
--        AssignedCases.case_id = Cases.case_id
--ORDER BY status_id;
     
     
--     
--SELECT Employees.first_name, Employees.patronymic, Cases.case_id, Cases.status_id, Cases.case_name, Cases.description
--FROM  AssignedCases
--INNER JOIN cases
--ON (assignedcases.employee_id = 28 OR assignedcases.employee_id = 30) AND cases.case_id = assignedcases.case_id 
--INNER JOIN employees
--ON employees.employee_id = assignedcases.employee_id
--ORDER BY status_id;



--2.4,2.5
SELECT Cases.status_id, ROUND(COUNT(*) / 
(
    SELECT
    COUNT(*) 
    FROM Cases
) * 100, 0) AS sum
FROM Cases
GROUP BY status_id;

--2.6
SELECT DISTINCT employees.post_id 
FROM Employees
ORDER BY post_id;

--2.7
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') AS "NOW"
FROM DUAL;



