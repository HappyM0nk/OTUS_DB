-- 1. Создать индекс к какой-либо из таблиц вашей БД

/*
create index ix_client_fk on directory.visit (client_fk);

*/

-- 2. Прислать текстом результат команды explain, в которой используется данный индекс

/*
explain (costs, verbose, format text, analyse) select * from directory.visit;

Без индекса
-------------------------------------------------------------------------------------------------------------
 Seq Scan on directory.visit  (cost=0.00..17.50 rows=750 width=80) (actual time=0.005..0.005 rows=3 loops=1)
   Output: id, client_fk, date, purpose, comment
 Planning Time: 0.284 ms
 Execution Time: 0.015 ms


С индексом
----------------------------------------------------------------------------------------------------------
 Seq Scan on directory.visit  (cost=0.00..1.03 rows=3 width=80) (actual time=0.005..0.005 rows=3 loops=1)
   Output: id, client_fk, date, purpose, comment
 Planning Time: 0.264 ms
 Execution Time: 0.011 ms
*/

-- 3. Реализовать индекс для полнотекстового поиска
-- 4. Реализовать индекс на часть таблицы или индекс на поле с функцией
-- 5. Создать индекс на несколько полей
Написать комментарии к каждому из индексов
Описать что и как делали и с какими проблемами столкнулись
