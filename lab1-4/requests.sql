-- 0. MERGE. ���������� ������� ����������� �������� �� ������ ������� (��� �������� ���������� �� ������-���� �������). 
MERGE INTO WorkSchedule Ddd
USING (SELECT * FROM Employees) S
ON (Ddd.employee_id = S.employee_id)
WHEN MATCHED THEN UPDATE SET  ddd.office_hours_id = floor(dbms_random.value(1, 14));
WHEN NOT MATCHED THEN INSERT (Ddd.employee_id, Ddd.day_id, Ddd.office_hours_id)
VALUES (S.employee_id, floor(dbms_random.value(1, 7)), floor(dbms_random.value(1, 14)));


-- 1. PIVOT. � ���� ������� ����� �� ����� ���� ��������� ���������� ����� ������� ���������� ���������� ������������� ������: � �� ���� ����� ����� �� ������ ��������� ���������. 
-- ��������, ������ ���������� ������� �� ���-�� ���, ������� ��� ����. �� �� ������ ���-�� ���, �������� ��������� ������ �� �������, � ������� ���������� ���������� ������� ���. �� ���� 
-- ������� ��������� � ������� ��� �������, ������� �������, ������� �� ��������. ������� ��� PIVOT ��� �����, ��������, ���:
SELECT Employees.department_id, Cases.status_id, COUNT(1) cnt FROM Employees, AssignedCases, Cases
WHERE employees.employee_id = assignedcases.employee_id AND cases.case_id = assignedCases.case_id
GROUP BY department_id, status_id
ORDER BY department_id;
-- ��������� ��� ������� ��� � �����������, �������� ������ ����� ������� ����������, ������ ����, � ������������� �� ���� ���������.
-- ������ ����� ������������� �����-��... �� �����. ���������� ��� ���������, ����� ������� �� ������ "������", ����� ����� ������ ��� ������. ������, ����� ������� 
-- ��� � ���������� ����������, ��� �� ������ �� ������� ���������� ��� ������ � ������� ��������� ���. �����, ���� ������, ��� �� ������ �� ��������� ��� ����� ���������� � �������� ��������,
-- �� ���-�� "�����" � ����� �������: N * M * 3, ��� N - ���-�� �������, M - ���-�� ��������� ����, 3 - ����� ���-�� ���������. ��� ������ ������ ��� 17 * 3 * 3 = 153 (��������������� � ���� ������� ���� 
-- 39 �����, ��� � ��� ���� �������� �� ������� ����������� ���������, ������� ����-�� ��� ������������� ��������� ��� ������ ��� (��� 3 ������ - �����������) �� ���������; �� 39 ����� � 117 ����� ��� ����� ������)


-- � ������ ��������� �� ��, ������ ����� PIVOT
SELECT * FROM
(
    SELECT Cases.status_id, Employees.department_id AS department FROM Employees, AssignedCases, Cases
    WHERE employees.employee_id = assignedcases.employee_id AND cases.case_id = assignedCases.case_id
)
    PIVOT 
    (
        count(status_id)
        for status_id in (1 AS "�������:", 2 AS "�������:", 3 AS "�� ��������:")
    )
ORDER BY department;

-- �� ��� ������ ����, �������. ����� ��������� ������������� ���� ��������� ���� ����� ��������. ����� ����, ����� 17 ����� (������ �3 ���) � ��������� � 39 �������� �� ����������� �������, � 68 ����� ������ 117.
-- �� ���� ��� � 2 ���� ������, � ���������� �������� �� ��. ��� ���, ��������� ������ ���� ����� ��������� � ��������� ����� �������. ����� ����, ����� ������ ��� � ���� �������, ��� �� ���� ���� �������.

-- How it works: 
-- 1) � ���������� �� ������� �������, ��� �������� ����������� ��� ���������� ��� �������: ������ ���� � ��������� � ��� ����� ���������. ��� ��� ���������� ����������, � ������� ����� ������ ������ ���������� (��� null-��������).
-- 2) ������ ������ "������" ������ ��������� �������, ������� ���������� "���������", �.�. ������� ��� ��� ��������, ������� �� ������ � for ... in ..., ����������. � �������� ���������� ������� �� ����� ������ COUNT(), ����� ��������� ���-�� ����������� �����
-- 3) � ���������� ���������� �������: department, �������, �������, �� ��������. � ���� ���������� �� ����� ����������, "���������" �� ������� ���������� ������� ������ ������ ����, ���� ����: ��������, ���� ������ ����������: 2, 13 (status_id - department_id), �� ����
-- �������� � ������� [2, 13] ����� �������������� "�������" (������ ������ �� �����������, ���������� � ����; ������ - �� ���������, ���������� � �������. ���������, �� ��������� ��������), � ������ ������ ��������� � [2, 13] ��������.
-- ����������: ��������� � �����, � ���������� ����� ������� �� ����������� ������ ���� 2 �������: ����� ���� � ������, ��������, �����-�� �����. � ������ COUNT() ����� ������������ ���-�� �-�� AVG(), ����� ��������� ������� ���� �������������� �����. ��� ���, ����� ����������, ��� ������ ������ �� ������ COUNT() ����� ����.

SELECT * FROM
    (
        SELECT Employees.*, Cases.status_id AS status FROM Employees, AssignedCases, Cases
        WHERE Employees.employee_id = AssignedCases.employee_id AND Cases.case_id = AssignedCases.case_id
    )
    PIVOT 
    (
        COUNT(status)
        FOR status IN (1 AS "Opened", 2 AS "Closed", 3 AS "Unsolved")
    )
ORDER BY employee_id;

-- 

SELECT * FROM
(
    SELECT employees.*, COALESCE(cnt, 0) AS cnt FROM Employees
    LEFT JOIN
    (
        SELECT AssignedCases.employee_id, SUM(CASE Cases.status_id WHEN 3 THEN -2 ELSE Cases.status_id END) AS cnt FROM AssignedCases, Cases
        WHERE AssignedCases.case_id = Cases.case_id
        GROUP BY employee_id
    ) ctl 
    ON ctl.employee_id = Employees.employee_id;
)
MATCH_RECOGNIZE 
(   
    ORDER BY age
    MEASURES LAST(UP.employee_id) AS employee, LAST(UP.cnt) AS core, STRT.age as start_age, LAST(DOWN.age) as last_age
    ONE ROW PER MATCH
    AFTER MATCH SKIP TO LAST DOWN
    PATTERN (STRT UP+ DOWN+) 
    DEFINE 
    UP AS UP.cnt > PREV(UP.cnt),
    DOWN AS DOWN.cnt < PREV(DOWN.cnt)
);      
