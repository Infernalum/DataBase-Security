-- ����������. 

-- 1.1 ������ ����������� �������, ������� �� ������� �� � ����� �����.
SELECT * FROM Employees
WHERE employee_id NOT IN (SELECT DISTINCT employee_id FROM AssignedCases)
ORDER BY employee_id;

-- ����� ������� ��������� ������, �������, ��������, ����������� �� ���� ������ ������ 5 ��� (������ ���).
SELECT * FROM Employees
WHERE employee_id NOT IN (SELECT DISTINCT employee_id FROM AssignedCases) AND (SYSDATE - employment_date) > 365*5
ORDER BY employee_id;

-- 1.2 ����� �����, ���������� � ������� � ������ "��������" (�.�. ��, � ������� employment_date ������, ��� � ������ ������� ���� � ������� Cases).
SELECT * FROM Employees 
Where employment_date <
(
SELECT MIN(start_date) FROM Cases
);




-- ����������.

-- 2.1 ������� ���������� ����� ����������� �� ������� (���-�� ������� � ������ ������).
SELECT department_id, COUNT(*) AS staff FROM Employees
GROUP BY department_id
ORDER BY department_id;



-- Note: ����� ������ �� ����� ���������� ���������� ����� � �����-�� ������� (�������, ���� � ������� ������� � ��� ������ ����). � ������ ������ ����� �� �����, �.�. �� ���� ������� ������� ����������.
-- ������ ��������� �������� �� �� ���������� �� ����������:
SELECT post_id, COUNT(*) AS staff FROM Employees
GROUP BY post_id
ORDER BY post_id;

-- ��� �� �����, � ������� ���������� ������ post_id = 12, 13. �������� ���, ���������� ������ ����� ������� (left outer) ���������� � �������� Posts, ����� � ������� ���� ��� ��������.
-- Note x2: ���� ���������� ������� ������� ����������, ������� �� post_id = 12, 13 ������ null, �� ����� ����������� ��� ������ ����� ��� �� ����������� COUNT'�� ����� � ��������� ��������� 
-- ���� ���������. ���, �����������, �� ������ ��� ��������. ������� ���������� �������� ������������� null �������� ��� ���������.
SELECT Posts.post_id, COUNT(case when employee_id is not null then 0 end) AS staff FROM Posts
LEFT JOIN Employees ON employees.post_id = posts.post_id
GROUP BY Posts.post_id;

-- �� �����, ����� ����� ������������ ����� 'then', �.�. count ������� ������ ������, � �� �������� ��������. ���� ��, � �������, ������ COUNT ���� �� SUM, �� ���� ���� �� ��������� 1.

-- ������� ������ ������� ������� (������� � ����� ������� �������������), � ������� ������� ������������ �������������, � ��� ����� - ���������� � ����������� ���������� null ��������.
SELECT Posts.post_id, COALESCE(tabl1.res, 0) AS staff FROM 
(
    SELECT post_id, COUNT(*) AS res FROM Employees
    GROUP BY Employees.post_id
) tabl1
RIGHT JOIN Posts
ON tabl1.post_id = Posts.post_id
ORDER BY Posts.post_id;



-- 2.2 ������� ������� �. 1.1 �� ��, ��� ��������� ���������� ������ ����� � �����-�� ����� (��� ���������� �������� ������� ���������� � �������) 
-- �� ������ �� ������ ������ ����� ������� ���. �� ���� � ������ ������ ��� ���������� �������������� ���������� �� ������� Cases (��������� ����), � �� ������ ����� ��� employee_id �� Assigned Cases.
SELECT * FROM Employees
WHERE employee_id NOT IN 
(
    SELECT DISTINCT employee_id
    FROM Cases
    INNER JOIN AssignedCases ON AssignedCases.case_id = Cases.case_id
    WHERE status_id = 1 
)
ORDER BY employee_id;

-- ������� ������� ���������� ������, ������ �����������, ������� ���������� �� ������ ������ �� ������ ��� ����� ������ ������������. ��� ����� ����� ������ �����������,
-- ������� ��� �� ��������, � ������ �� �� ���� ����������� (��������� MINUS ������ 'WHERE employee_id NOT IN' ������ ���, ����� ����))

SELECT employee_id FROM Employees
MINUS
(
    SELECT employee_id FROM 
    (
      SELECT employee_id, COUNT(*) AS actual_cases
      FROM Cases
      INNER JOIN AssignedCases ON AssignedCases.case_id = Cases.case_id
      WHERE status_id = 1
     GROUP BY employee_id
    )
    WHERE actual_cases > 2
)
ORDER BY employee_id;


-- ������������� �������.

-- � ����� ���� ��������� ��������, �.�. � ���� �� ������� ������������� ������������ ���� ������ (� �� ���������, ������� ���� � ����). �������, � ����� ������ ������� ���������� ��� ����� ���� �������� ����� �������
-- ������������� ������� ��������� (������ �������� �� ����� �����). ��� �������� � ���� ���� id (��� ������������ �����, �.�. ��������� ������� � Posts ����� 0..n), post_id � pid (������������� ��������, �� ������� ��������� ����� ��������� � ���� �� �������).
-- (Note: ��������, ��� ��� ����� ��������� �� ��������; � ��������� ������� ����������� �������������� ��������� ����������; � � ��, ��������� ��, ��� � ����� ������� ��� ������� �����, ������� ��������� �� ���� � ��� �� �������).

-- �������� �������
CREATE TABLE PeckingOrder 
(
    post_id,
    pid NUMBER(2,0),
    CONSTRAINT PeckingOrder_pk PRIMARY KEY (post_id),
    CONSTRAINT PeckingOrder_fk_post
        FOREIGN KEY (post_id) 
        REFERENCES Posts(post_id),
    CONSTRAINT PeckingOrder_fk_pid
        FOREIGN KEY (pid) 
        REFERENCES Posts(post_id)
);

-- ��������� �� (� �� �������� ����� sql developer, �� ��� ��� ��� �������� � �����):

-- ��� ������ (���� "���������" ������ ����� lpad ������ � ��������� ������������ � �����):
SELECT LPAD(' ', 3*LEVEL)||post_name AS pecking_order
FROM
(
SELECT Posts.post_id, PeckingOrder.pid, Posts.post_name FROM Posts
INNER JOIN PeckingOrder
ON Posts.post_id = PeckingOrder.post_id
)
CONNECT BY PRIOR post_id = pid
START WITH pid is null
ORDER SIBLINGS BY post_name;


-- ��� �� ����� ���� ��� �������� ������� �������� � ������� Employees �� id "�����" ������� ����������; ������, ����� �� �� ��������� ����� �������� �������
-- (����, �� ���� ��� �������� �� ����� �������; ����� �������� ����, ����� ��������� ���� ������ ���������� ��� ���������, � ������ ���������� �� �� ����). �������, ����� ���� ��������� ���, � � ������� ���� ��� ����� �� ������������ ��� ����, �����
-- ����� ���� �������� pid � ������� Employees � �������� ���������� �� �������� ���� ����������� (� ����������� �� ���������).


-- 4. ������������� �������..
-- �����������, ��� ���������� ������� ������ � ����������� � ���������� (����� �������� ������ employee_id) �������������� ���������, ��������, ���-�� ����������� � ��� ������.
-- � ������� ������, ����� �������� ��������� �� ����������� ������� ������, � ��������� ��� � ������������ �������� Employees. ��� �������� �������� 
-- ���������: 
SELECT employee_id, Employees.department_id, tabl2.staff FROM Employees
INNER JOIN
(
SELECT department_id, COUNT(*) AS STAFF FROM Employees
GROUP BY department_id
) tabl2
ON 
Employees.department_id = tabl2.department_id;

-- �������� ��������... ���������. � ����������� ���, ��� ��� ����� �� ���� ������������� ������� (� ������������ ������������� JOIN'��). ����� ��������� ���� �����,
-- ����������� ������������� ������������� ������� (ORDER BY �������, ����� ������� ����� � ������� ��� ����� ��, ��� � ���������� ��������):

SELECT Employee_id, department_id, COUNT(*) OVER (PARTITION BY department_id) AS staff FROM Employees
ORDER BY employee_id;

-- ����� ����, ����������� � ������� � ���������� ������������� ��������, � ����� ������� SELECT ����� ������������ ��������� ������������� �������. �������, � �������, 
-- � ������� ����� ����������� �������, ���-�� ����������� �������������� ���������� � ������� ������� ����������� ������:

SELECT Employee_id, department_id, COUNT(*) OVER (PARTITION BY department_id) AS department_staff, AVG(age) OVER (PARTITION BY department_id) AS AVG_age,  post_id, COUNT(*) OVER (PARTITION BY post_id) AS post_staff FROM Employees
ORDER BY employee_id;

-- � ������ ������� �� ������������ ������������� ������� ����� ��������� ������� � ������� �� ����� ��������� � ������������ (��� ��� �� ������, �� ���� ����� ������ ����� ����������� ���������� ����������)

