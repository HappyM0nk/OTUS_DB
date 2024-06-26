-- 1. Напишите запрос по своей базе с регулярным выражением, добавьте пояснение, что вы хотите найти.

-- поиск клиента по фамилии с использованием регулярного выражения. Искомая подстрока может быть в любой части фамилии без учёта регистра букв
select id, surname, first_name, patronymic, phone
from directory.client
where surname ilike '%иван%';

/*
"id"	"surname"	"first_name"	"patronymic"	"phone"
1	    "Иванов"	"Иван"	        "Иванович"	    "111111111"
2	    "Силиванов"	"Пётр"	        "Петрович"	    "222222222"
*/

-- 2. Напишите запрос по своей базе с использованием LEFT JOIN и INNER JOIN, как порядок соединений в FROM влияет на результат? Почему?

/* При использовании INNER JOIN будет выведено столько строк, сколько было визитов, т.к. для клиентов без визитов условие свзывания не будет выполнено*/
select cl.id, cl.surname, cl.first_name, cl.patronymic, cl.phone, v.purpose, v.comment
from directory.client as cl inner join directory.visit as v
    on cl.id = v.client_fk;

/*
"id"	"surname"	"first_name"	"patronymic"	"phone"	        "purpose"	        "comment"
1	    "Иванов"	"Иван"	        "Иванович"	    "111111111"	    "Обследование"	    "111"
2	    "Силиванов"	"Пётр"	        "Петрович"	    "222222222"	    "Медкомиссия"	    "222"
1	    "Иванов"	"Иван"	        "Иванович"	    "111111111"	    "Повторный осмотр"	"333"
*/

/* При замене соединения на LEFT JOIN будут дополнительно выведены записи с информацией о клиентах у которых не было ни одного визита. 
При данном виде соединения в первую очередь выбираются записи клиентов и к ним объединяются записи визитов (недостающие записи визитов будут заменены на Null)*/
select cl.id, cl.surname, cl.first_name, cl.patronymic, cl.phone, v.purpose, v.comment
from directory.client as cl left join directory.visit as v
    on cl.id = v.client_fk;

/*
"id"	"surname"	"first_name"	"patronymic"	"phone"	        "purpose"	        "comment"
1	    "Иванов"	"Иван"	        "Иванович"	    "111111111"	    "Обследование"	    "111"
2	    "Силиванов"	"Пётр"	        "Петрович"	    "222222222"	    "Медкомиссия"	    "222"
1	    "Иванов"	"Иван"	        "Иванович"	    "111111111"	    "Повторный осмотр"	"333"
3	    "Сидоров"	"Сидор"	        "Сидорович"	    "333333333"				
*/

/*При замене порядка соединений в FROM в даннм случае будут выведены резутаты, аналогичные INNER JOIN, 
поскольку будут выбраны все записи визитов и для всех них существуют записи клиентов.*/
select cl.id, cl.surname, cl.first_name, cl.patronymic, cl.phone, v.purpose, v.comment
from  directory.visit as v left join directory.client as cl
    on cl.id = v.client_fk;

/*
"id"	"surname"	"first_name"	"patronymic"	"phone"	        "purpose"	        "comment"
1	    "Иванов"	"Иван"	        "Иванович"	    "111111111"	    "Обследование"	    "111"
2	    "Силиванов"	"Пётр"	        "Петрович"	    "222222222"	    "Медкомиссия"	    "222"
1	    "Иванов"	"Иван"	        "Иванович"	    "111111111"	    "Повторный осмотр"	"333"
*/

-- 3. Напишите запрос на добавление данных с выводом информации о добавленных строках.

/*Добавление двух новых клиентов. В выводе получим идентификаторы, фамилии и имена добавленных записей.

insert into directory.client (id, surname, first_name, patronymic, phone)
values 
(4, 'Семенов', 'Семен', 'Семенович', '44444444'),
(5, 'Петров', 'Пётр', 'Петрович', '55555555')
returning id, surname, first_name;
*/

-- 4. Напишите запрос с обновлением данные используя UPDATE FROM.

/*Запрос записывает в поле комментария визита данные о специалисте, в виде "Фамилия И.О."

update directory.visit v
set comment = s.surname || ' ' || left(s.first_name, 1) || '.' || ' ' || left(s.patronymic, 1) || '.'
from directory.specialist s
	join reference.visit_specialist vs
	on vs.specialist_fk = s.id
where v.id = vs.visit_fk;
*/

-- 5. Напишите запрос для удаления данных с оператором DELETE используя join с другой таблицей с помощью using.

/*Запрос удаляет все записи из таблицы price, если они ещё не актуальны и относятся к услуге, содержащей в имени словов "первичный".
Например, таким образом будет отменено предстоящее измнение цены на первичный осмотр.

delete from directory.price	p
	using directory.service s
where p.begin_date > now() and s.name ILike '%первичный%';
*/

-- Задание со *: Приведите пример использования утилиты COPY

/*Скрипт копирует содержимое выборки визитов в файл "C:\Otus_db\visits.txt". Можно применять как выгрузку статистики в файл за определённый период времени.

Так же можно использовать команду COPY FROM, чтобы добавить данные из файла к имеющимся записям в таблице. Например если предоставлены новые цены на услуги, которые нужно добавить в БД.

copy (select (c.surname || ' ' || left(c.first_name, 1) || '.' || ' ' || left(c.patronymic, 1) || '.') as client_name, v.date, v.purpose, v.comment
		from directory.client c join directory.visit v
		on v.client_fk = c.id)
to 'C:\Otus_db\visits.txt'
*/