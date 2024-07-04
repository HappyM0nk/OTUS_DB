-- 1. Создать индекс к какой-либо из таблиц вашей БД

create index ix_client_fk on directory.visit (client_fk);
/*
Простой индекс для таблицы визитов по полю идентификатора клиента. Ускорит выборку истории всех визитов клиента в учреждение.
*/

-- 2. Прислать текстом результат команды explain, в которой используется данный индекс

explain (costs, verbose, format text, analyse) select * from directory.visit;
/*
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

 Не смотря на небольшое количество записей в таблице, индекс дал некоторый прирост скорости выполнения запроса.
*/

-- 3. Реализовать индекс для полнотекстового поиска

create extension pg_trgm; --установка расширения 
create index ix_purpose_search on directory.visit using GIN (purpose gin_trgm_ops);
/*
Полнотекстовый индекс, позволяющий быстро искать все визиты клиетов по полю причины посещения. 
Выбрано расширение pg_trgm, позволяющее создать индекс на основе триграмм из имеющихся слов. 
Это даёт возможность искать похожие строки, даже если они не совпадают буквально.
*/

-- 4. Реализовать индекс на часть таблицы или индекс на поле с функцией

create index ix_actula_prices on directory.price (end_date) where end_date is null;
/*
Индекс строится только по актуальным ценам на услуги. Ускорит выборку цен по услугам при формировании актуального прайс-листа.
*/

-- 5. Создать индекс на несколько полей

create unique index ix_specialist_service on reference.specialist_service (specialist_fk, service_fk);
/*
Создаётся уникальный индекс по двум полям - specialist_fk, service_fk. 
Данный индекс предотращает повторную привязку услуги к специалисту. 
*/
