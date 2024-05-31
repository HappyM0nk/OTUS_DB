/*Напишите запрос по своей базе с регулярным выражением, добавьте пояснение, что вы хотите найти.
Напишите запрос по своей базе с использованием LEFT JOIN и INNER JOIN, как порядок соединений в FROM влияет на результат? Почему?
Напишите запрос на добавление данных с выводом информации о добавленных строках.
Напишите запрос с обновлением данные используя UPDATE FROM.
Напишите запрос для удаления данных с оператором DELETE используя join с другой таблицей с помощью using.

Задание со *:
Приведите пример использования утилиты COPY
*/

-- поиск клиента по фамилии с использованием регулярного выражения. Искомая подстрока может быть в любой части фамилии без учёта регистра букв
select id, surname, first_name, patronymic, phone
from directory.client
where surname ilike '%иван%';

-- поиск клиентов, которые были у конкретного специалиста в течении последнего месяца.
select cl.id, cl.surname, cl.first_name, cl.patronymic, cl.phone 
from directory.client as cl inner join directory.visit as v
    on cl.id = v.client_fk
inner join reference.visit_specialist as vs 
    on v.id = vs.visit_fk
inner join directory.specialist as s
	on s.id = vs.specialist_fk
where v.date <= now.addmonth