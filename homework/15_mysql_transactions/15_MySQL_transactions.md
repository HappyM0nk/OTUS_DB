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
create database funny_data_loading;
use funny_data_loading;

CREATE TABLE funny_data_loading(
   Handle                                    VARCHAR(55) NOT NULL PRIMARY KEY
  ,Title                                     VARCHAR(55)
  ,"Body HTML"                               VARCHAR(10733)
  ,Vendor                                    VARCHAR(24)
  ,Type                                      VARCHAR(23)
  ,Tags                                      VARCHAR(206)
  ,Published                                 VARCHAR(5)
  ,"Option1 Name"                            VARCHAR(12)
  ,"Option1 Value"                           VARCHAR(38)
  ,"Option2 Name"                            VARCHAR(8)
  ,"Option2 Value"                           VARCHAR(19)
  ,"Option3 Name"                            VARCHAR(30)
  ,"Option3 Value"                           VARCHAR(30)
  ,"Variant SKU"                             VARCHAR(93)
  ,"Variant Grams"                           INTEGER 
  ,"Variant Inventory Tracker"               VARCHAR(7)
  ,"Variant Inventory Qty"                   INTEGER 
  ,"Variant Inventory Policy"                VARCHAR(8)
  ,"Variant Fulfillment Service"             VARCHAR(6)
  ,"Variant Price"                           NUMERIC(7,2)
  ,"Variant Compare At Price"                NUMERIC(7,2)
  ,"Variant Requires Shipping"               VARCHAR(5)
  ,"Variant Taxable"                         VARCHAR(4)
  ,"Variant Barcode"                         VARCHAR(14)
  ,"Image Src"                               VARCHAR(145)
  ,"Image Alt Text"                          VARCHAR(16)
  ,"Gift Card"                               VARCHAR(5)
  ,"SEO Title"                               VARCHAR(30)
  ,"SEO Description"                         VARCHAR(160)
  ,"Google Shopping Google Product Category" VARCHAR(94)
  ,"Google Shopping Gender"                  VARCHAR(6)
  ,"Google Shopping Age Group"               VARCHAR(5)
  ,"Google Shopping MPN"                     INTEGER 
  ,"Google Shopping AdWords Grouping"        VARCHAR(18)
  ,"Google Shopping AdWords Labels"          VARCHAR(18)
  ,"Google Shopping Condition"               VARCHAR(3)
  ,"Google Shopping Custom Product"          VARCHAR(5)
  ,"Google Shopping Custom Label 0"          VARCHAR(30)
  ,"Google Shopping Custom Label 1"          VARCHAR(30)
  ,"Google Shopping Custom Label 2"          VARCHAR(30)
  ,"Google Shopping Custom Label 3"          VARCHAR(30)
  ,"Google Shopping Custom Label 4"          VARCHAR(30)
  ,"Variant Image"                           VARCHAR(145)
  ,"Variant Weight Unit"                     VARCHAR(2)
);
```