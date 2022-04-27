-- Подзапросы. 

-- 1.1 Найдем сотрудников участка, которые не связаны ни с одним делом.
SELECT * FROM Employees
WHERE employee_id NOT IN (SELECT DISTINCT employee_id FROM AssignedCases)
ORDER BY employee_id;

-- Можно немного усложнить запрос, добавив, например, ограниечние на стаж работы больше 5 лет (просто так).
SELECT * FROM Employees
WHERE employee_id NOT IN (SELECT DISTINCT employee_id FROM AssignedCases) AND (SYSDATE - employment_date) > 365*5
ORDER BY employee_id;

-- 1.2 Найти людей, работающих в участке с самого "открытия" (т.е. те, у которых employment_date меньше, чем у самого раннего дела в таблице Cases).
SELECT * FROM Employees 
Where employment_date <
(
SELECT MIN(start_date) FROM Cases
);




-- Соединения.

-- 2.1 Выведем статискику штата сотрудников по отделам (кол-во человек в каждом отделе).
SELECT department_id, COUNT(*) AS staff FROM Employees
GROUP BY department_id
ORDER BY department_id;



-- Note: такой запрос не будет показывать отсутствие штата у каких-то отделов (логично, ведь в таблице записей о них вообще нету). В данном случае этого не видно, т.к. во всех отделах имеются сотрудники.
-- Однако попробуем написать ту же статистику по должностям:
SELECT post_id, COUNT(*) AS staff FROM Employees
GROUP BY post_id
ORDER BY post_id;

-- Как мы видим, в запросе отсутсвуют записи post_id = 12, 13. Исправим это, реализовав запрос через внешнее (left outer) соединение с таблицей Posts, чтобы в таблице были все дожности.
-- Note x2: если попытаться сначала сделать соединение, получив на post_id = 12, 13 строки null, то после группировки эти строки точно так же посчитаются COUNT'ом будто в должности находится 
-- один сотрудник. Это, естественно, не должно так работать. Поэтому необходимо добавить игнорирование null значений при агрегации.
SELECT Posts.post_id, COUNT(case when employee_id is not null then 0 end) AS staff FROM Posts
LEFT JOIN Employees ON employees.post_id = posts.post_id
GROUP BY Posts.post_id;

-- Не важно, какое число использовать росле 'then', т.к. count считает именно строки, а не значения атрибута. Если бы, к примеру, вместо COUNT было бы SUM, то надо было бы поставить 1.

-- Немного другой вариант запроса (который я хотел сделать первоначально), в котором сначала производится агрегирование, а уже затем - соединение с необходимой обработкой null значений.
SELECT Posts.post_id, COALESCE(tabl1.res, 0) AS staff FROM 
(
    SELECT post_id, COUNT(*) AS res FROM Employees
    GROUP BY Employees.post_id
) tabl1
RIGHT JOIN Posts
ON tabl1.post_id = Posts.post_id
ORDER BY Posts.post_id;



-- 2.2 Изменим условие п. 1.1 на то, что выбранные сотрудники вместо связи с каким-то делом (что фактически означает наличие сотрудника в таблице) 
-- не должны на данный момент вести никаких дел. То есть в данном случае нам необходима дополнительная информация из таблицы Cases (состояние дела), а не только найти все employee_id из Assigned Cases.
SELECT * FROM Employees
WHERE employee_id NOT IN 
(
    SELECT DISTINCT employee_id
    FROM Cases
    INNER JOIN AssignedCases ON AssignedCases.case_id = Cases.case_id
    WHERE status_id = 1 
)
ORDER BY employee_id;

-- Изменив немного предыдущий запрос, найдем сотрудников, которые занимаются на данный момент не больше чем двумя делами одновременно. Для этого снова найдем сотрудников,
-- которые нам не подходят, и вычтем их из всех сотрудников (используя MINUS вместо 'WHERE employee_id NOT IN' просто так, чтобы было))

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


-- Иерархические запросы.

-- С нимми были небольшие проблемы, т.к. в моей БД всунуть иерархическое наследование было некуда (в ту структуру, которая была у меня). Поэтому, я решил просто создать специально для этого типа запросов новую таблицу
-- иерархической сестемы персонала (Заодно дополним БД новой инфой). Она включает в себя поля id (для уникальности строк, т.к. отношение таблицы к Posts будет 0..n), post_id и pid (идентификатор родителя, на который ссылается даная должность в этой же таблице).
-- (Note: ниваажна, что оно может выглядеть не логичным; я попытался описать максимально правдоподобную структуру должностей; и я хз, нормально ли, что в одной таблице два внешних ключа, которые ссылаются на один и тот же атрибут).

-- Создадим таблицу
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

-- Заполняем ее (я ее заполнял через sql developer, но вот как она выглядит в конце):

-- Сам запрос (идея "отрисовки" дерева через lpad честно и полностью скомунизжена с Хабра):
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


-- Все же проще было эту иерархию сделать напрямую в таблице Employees по id "босса" каждого сотрудника; однако, никто же не запрещает потом поменять таблицы
-- (хотя, по сути оба варианта не особо полезны; кроме проверки того, какую должность надо давать сотруднику при повышении, я больше назначений ей не вижу). Поэтому, пусть пока останется она, и в будущем если что будем ее использовать для того, чтобы
-- можно было добавить pid в таблицу Employees и наглядно расставить их значения всем сотрудникам (в зависимости от должности).


-- 4. Аналитические функции..
-- Предположим, нам необходимо вывести вместе с информацией о сотруднике (будем выводить только employee_id) дополнительную аналитику, например, кол-во сотрудников в его отделе.
-- В данномм случае, можно написать подзапрос со статистикой каждого отдела, и соединить его с родительской таблицей Employees. Это выглядит довольно 
-- громоздко: 
SELECT employee_id, Employees.department_id, tabl2.staff FROM Employees
INNER JOIN
(
SELECT department_id, COUNT(*) AS STAFF FROM Employees
GROUP BY department_id
) tabl2
ON 
Employees.department_id = tabl2.department_id;

-- Выглядит довольно... Громоздко. А предположим еще, что нам нужен не один аналитический столбец (и представляем нагромождение JOIN'ов). Чтобы облегчить себе жизнь,
-- рационально испоользовать аналитические функции (ORDER BY сделаем, чтобы порядок строк в запросе был такой же, как в предыдущем варианте):

SELECT Employee_id, department_id, COUNT(*) OVER (PARTITION BY department_id) AS staff FROM Employees
ORDER BY employee_id;

-- Кроме того, возвращаясь к вопросу о нескольких аналитических столбцах, в одной выборке SELECT можно использовать несколько аналитичсеких функций. Выведем, к примеру, 
-- к размеру штата сотрудников отделов, кол-во сотрудников соответсвующих должностей и средний возраст сотрудников отдела:

SELECT Employee_id, department_id, COUNT(*) OVER (PARTITION BY department_id) AS department_staff, AVG(age) OVER (PARTITION BY department_id) AS AVG_age,  post_id, COUNT(*) OVER (PARTITION BY post_id) AS post_staff FROM Employees
ORDER BY employee_id;

-- В данных случаях мы использовали аналитические функции чтобы упростить запросы и сделать их более понятными и комплексными (ибо как мы поняли, по сути любой запрос можно представить множеством соединений)

