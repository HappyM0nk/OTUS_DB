# Транзакции MySQL
## Пример транзакци для нескольких таблиц.

**Задача: Описать пример транзакции из своего проекта с изменением данных в нескольких таблицах. Реализовать в виде хранимой процедуры.**

Для базы данных медицинского центра такую хранимую процедуру можно написать для добавления информации о предоставленной услуге и результатах обследования в рамках одной транзакции. Таким образом мы гарантируем, что в базу не попадёт запись о предоставленной услуге, а запись с результатами не добавится из-за какой-то ошибки.

Добавление хранимой процедуры.

```sql
DROP PROCEDURE IF EXISTS AddServiceProvidedAndResult;

DELIMITER $$
CREATE PROCEDURE AddServiceProvidedAndResult(
  IN service_id int,  
  IN visit_id int,  
  IN comment text,
  IN results json
)
BEGIN
  DECLARE last_id INT DEFAULT 0;	
  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
    END;

  START TRANSACTION;
  INSERT INTO service_provided (service_fk, visit_fk, date)
  	VALUES(service_id, visit_id, NOW());  

  SELECT LAST_INSERT_ID() INTO last_id;
  
  INSERT INTO examination_result (service_provided_fk, date, comment, results)
  	VALUES(last_id, NOW(), comment, results);
   
  COMMIT;	
 
END$$
DELIMITER ;
```

Вызов процедуры и проверка добавленных данных в двух таблицах
```sql
CALL AddServiceProvidedAndResult(3, 3, 'Результат добавлен хранимой процедурой', '{"Param1": 63.5, "Param2": 135, "Param3": 1.09}');

SELECT sp.id, sp.service_fk, sp.visit_fk, sp.date as serv_date, er.id as res_id, er.service_provided_fk, er.date as res_date, er.comment, er.results
FROM service_provided sp
INNER JOIN examination_result er 
  ON sp.id = er.service_provided_fk 
WHERE sp.visit_fk = 3;

id|service_fk|visit_fk|serv_date          |res_id|service_provided_fk|res_date           |comment                               |results                                        |
--+----------+--------+-------------------+------+-------------------+-------------------+--------------------------------------+-----------------------------------------------+
 4|         3|       3|2024-07-25 18:25:04|     4|                  4|2024-07-25 18:25:04|Результат добавлен хранимой процедурой|{"Param1": 63.5, "Param2": 135, "Param3": 1.09}|

```

## Загрузка данных из CSV
Загрузить данные из приложенных в материалах csv.
Реализовать следующими путями:
LOAD DATA

Задание со *: загрузить используя
mysqlimport

```sql

```