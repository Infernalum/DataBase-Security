-- 0. MERGE. Обновление таблицы посредством сведений из другой таблицы (или удаления устаревших по какому-либо условию). 
MERGE INTO WorkSchedule Ddd
USING (SELECT * FROM Employees) S
ON (Ddd.employee_id = S.employee_id)
WHEN MATCHED THEN UPDATE SET  ddd.office_hours_id = floor(dbms_random.value(1, 14));
WHEN NOT MATCHED THEN INSERT (Ddd.employee_id, Ddd.day_id, Ddd.office_hours_id)
VALUES (S.employee_id, floor(dbms_random.value(1, 7)), floor(dbms_random.value(1, 14)));


-- 1. PIVOT. В моей легенде можно на самом деле придумать достаточно много случаев применения матричного представления данных: в БД есть очень много по смылсу связанных атрибутов. 
-- Например, Найдем статистику отделов по кол-ву дел, которые они вели. Но не просто кол-во дел, которыми занимался каждый из отделов, а дополня статистику измерением статуса дел. То есть 
-- Сколько связанных с отделом дел закрыто, сколько открыто, сколько не раскрыто. Сделать без PIVOT это можно, например, так:
SELECT Employees.department_id, Cases.status_id, COUNT(1) cnt FROM Employees, AssignedCases, Cases
WHERE employees.employee_id = assignedcases.employee_id AND cases.case_id = assignedCases.case_id
GROUP BY department_id, status_id
ORDER BY department_id;
-- Соединили три таблицы дел и сотрудников, вытащили оттуда отдел каждого сотрудника, статус дела, и сгруппировали по двум атрибутам.
-- Однако такое представление какое-то... Не очень. Получилось два измерения, через которые мы должны "пройти", чтобы найти нужную нам запись. Причем, такая таблица 
-- Еще и достаточно избыточная, ибо на каждый из отделов приходится три строки с разными статусами дел. Итого, если примем, что на каждое из состояний дел будет упоминание в исходных таблицах,
-- То кол-во "ячеек" в таком запросе: N * M * 3, где N - кол-во отделов, M - кол-во состояний дела, 3 - общее кол-во атрибутов. Для нашего случая это 17 * 3 * 3 = 153 (дейстительности в моем запросе было 
-- 39 строк, ибо я все дела раздавал по отделам практически вразнобой, поэтому кому-то дел определенного состояния или вообще дел (как 3 отделу - бухгалтерии) не досталось; но 39 строк и 117 ячеек все равно дофига)


-- А теперь реализуем то же, только через PIVOT
SELECT * FROM
(
    SELECT Cases.status_id, Employees.department_id AS department FROM Employees, AssignedCases, Cases
    WHERE employees.employee_id = assignedcases.employee_id AND cases.case_id = assignedCases.case_id
)
    PIVOT 
    (
        count(status_id)
        for status_id in (1 AS "Открыты:", 2 AS "Закрыты:", 3 AS "Не раскрыты:")
    )
ORDER BY department;

-- Во это другое дело, красиво. Такое матричное представление двух измерений куда более читаемое. Кроме того, здесь 17 строк (отдела №3 нет) в сравнении с 39 строками из предыдущего запроса, и 68 ячеек против 117.
-- То есть она в 2 раза меньше, а информация осталась та же. Так что, матричные отчеты куда более локаничны и визуально проще читаемы. Кроме того, такой запрос еще и нули добавил, где не чего было считать.

-- How it works: 
-- 1) в подзапросе мы создаем таблицу, где хранится необходимая нам информация для анализа: статус дела и связанный с ним отдел служащего. Так как соединение внутрееное, в таблице будет только полные совпадения (без null-значений).
-- 2) Внутри самого "пивета" запрос считывает атрибут, который необходимо "повернуть", т.е. сделать все его значения, которые мы укажем в for ... in ..., атрибутами. В качестве агрегатной функции мы берем просто COUNT(), чтобы посчитать кол-во совпадающих строк
-- 3) В результате получается таблица: department, Открыты, Закрыты, Не раскрыты. И СУБД проходится по всему подзапросу, "закидыыая" по правилу агрегатной функции каждую строку туда, куда надо: жопустим, есть строка подзапроса: 2, 13 (status_id - department_id), то СУБД
-- работает с ячейкой [2, 13] нашей результирующей "матрицы" (первый индекс по горизонтали, индексация с нуля; второй - по вертикали, индексация с единицы. Кривовато, но визуально понятнно), в данном случае добавляет к [2, 13] единичку.
-- Примечание: насколько я понял, в подзапросе перед пиветом не обязательно должно быть 2 столбца: может быть и третий, например, какое-то число. И вместо COUNT() можно использовать что-то а-ля AVG(), чтобы посчитать среднее всех соотвествующих ячеек. Это так, общие наблюдения, что внутри пивета не только COUNT() может быть.

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
