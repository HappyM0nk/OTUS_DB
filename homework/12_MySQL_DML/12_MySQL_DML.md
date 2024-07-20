# Выборки MySQL
## Анализ таблиц проекта

На мой взгляд самыми большими таблицами во всём проекте будут visit, service_provided и examination_result.
Скорее всего в подавляющем большинстве случаев поиск по таблице examination_result будет вестись по первичному ключу, т.к. сами по себе результаты обследований без привязки к оказанным услугам и посещениям чаще всего не представлют интереса.
В то же время таблицы visit и service_provided могу быть активно использованы для различной отчётности. Например востребованность каких-то услуг за период времени или список визитов клиента за всё время наблюдения. Исходя из этого предполагаю, что партиционирование данных таблиц по по полю даты может дать прирост производительности в операциях построения различной отчётности.


## Конфигурация партиций выбранных таблиц
Для партиционирования выбраны таблицы visit и service_provided по полю date.


```sql
CREATE TABLE visit (
  `id` int NOT NULL,
  `client_fk` int,
  `date` datetime,
  `purpose` text,
  `comment` text,
  PRIMARY KEY (id, date)
);

ALTER TABLE visit PARTITION BY RANGE (TO_DAYS(date))
(
    PARTITION p202407 VALUES LESS THAN (TO_DAYS('2024-08-01')),
    PARTITION p202408 VALUES LESS THAN (TO_DAYS('2024-09-01')),
    PARTITION p202409 VALUES LESS THAN (TO_DAYS('2024-10-01')),
    PARTITION p202410 VALUES LESS THAN (TO_DAYS('2024-11-01')),
    PARTITION newer VALUES LESS THAN (TO_DAYS('9999-12-31'))
);
```

Аналогичным образом применяются портиционирование к таблице service_provided.
После вставки данных они будут разделены на партиции по датам и построение отчётности станет быстрее.

```sql
insert into visit 
    (id, client_fk, date, purpose, comment)
values 
    (1, 1, '2024-07-20', '', '111111111'),
    (2, 2, '2024-08-20', '', '222222222'),
    (3, 1, '2025-06-10', '', '333333333');
```

```sql
select partition_name, table_rows from information_schema.partitions where table_name = 'visit';
+----------------+------------+
| PARTITION_NAME | TABLE_ROWS |
+----------------+------------+
| newer          |          1 |
| p202407        |          1 |
| p202408        |          1 |
| p202409        |          0 |
| p202410        |          0 |
+----------------+------------+
```

```sql
explain select * from visit where date between '2024-07-01 00:00:00' and '2024-08-31 23:59:59';
+----+-------------+-------+-----------------+------+---------------+------+---------+------+------+----------+-------------+
| id | select_type | table | partitions      | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
+----+-------------+-------+-----------------+------+---------------+------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | visit | p202407,p202408 | ALL  | NULL          | NULL | NULL    | NULL |    2 |    50.00 | Using where |
+----+-------------+-------+-----------------+------+---------------+------+---------+------+------+----------+-------------+
1 row in set, 1 warning (0.00 sec)
```