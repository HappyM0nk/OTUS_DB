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
**Задача: Загрузить данные из приложенных в материалах csv.**

Для удобства в имеющийся compose файл было добавлено монтирование папки mysql-files в директрию /var/lib/mysql-files docker контейнера. Все необходимые csv файлы были размещены в этой папке, чтобы иметь возможность загрузить из них данные в таблицу.

Подготовка к загрузке данных. Создаётся база данных и таблица с необходимыми полями.

```sql
create database funny_data_loading;
use funny_data_loading;

CREATE TABLE funny_data_loading(
   Handle                                    TEXT
  ,Title                                     TEXT
  ,`Body HTML`                               TEXT
  ,Vendor                                    TEXT
  ,Type                                      TEXT
  ,Tags                                      TEXT
  ,Published                                 TEXT
  ,`Option1 Name`                            TEXT
  ,`Option1 Value`                           TEXT
  ,`Option2 Name`                            TEXT
  ,`Option2 Value`                           TEXT
  ,`Option3 Name`                            TEXT
  ,`Option3 Value`                           TEXT
  ,`Variant SKU`                             TEXT
  ,`Variant Grams`                           TEXT 
  ,`Variant Inventory Tracker`               TEXT
  ,`Variant Inventory Qty`                   TEXT 
  ,`Variant Inventory Policy`                TEXT
  ,`Variant Fulfillment Service`             TEXT
  ,`Variant Price`                           TEXT
  ,`Variant Compare At Price`                TEXT
  ,`Variant Requires Shipping`               TEXT
  ,`Variant Taxable`                         TEXT
  ,`Variant Barcode`                         TEXT
  ,`Image Src`                               TEXT
  ,`Image Alt Text`                          TEXT
  ,`Gift Card`                               TEXT
  ,`SEO Title`                               TEXT
  ,`SEO Description`                         TEXT
  ,`Google Shopping Google Product Category` TEXT
  ,`Google Shopping Gender`                  TEXT
  ,`Google Shopping Age Group`               TEXT
  ,`Google Shopping MPN`                     TEXT 
  ,`Google Shopping AdWords Grouping`        TEXT
  ,`Google Shopping AdWords Labels`          TEXT
  ,`Google Shopping Condition`               TEXT
  ,`Google Shopping Custom Product`          TEXT
  ,`Google Shopping Custom Label 0`          TEXT
  ,`Google Shopping Custom Label 1`          TEXT
  ,`Google Shopping Custom Label 2`          TEXT
  ,`Google Shopping Custom Label 3`          TEXT
  ,`Google Shopping Custom Label 4`          TEXT
  ,`Variant Image`                           TEXT
  ,`Variant Weight Unit`                     TEXT
);
```

Загрузка данных. Все предложенные csv файлы имеют одинаковую структуру, поэтому все они были загружены в одну талицу последовательными запросами.

```mysql
LOAD DATA
  INFILE '/var/lib/mysql-files/Apparel.csv'
  IGNORE
  INTO TABLE funny_data_loading
  FIELDS TERMINATED BY ",";

LOAD DATA
  INFILE '/var/lib/mysql-files/Bicycles.csv'
  IGNORE
  INTO TABLE funny_data_loading
  FIELDS TERMINATED BY ",";

LOAD DATA
  INFILE '/var/lib/mysql-files/Fashion.csv'
  IGNORE
  INTO TABLE funny_data_loading
  FIELDS TERMINATED BY ",";

LOAD DATA
  INFILE '/var/lib/mysql-files/jewelry.csv'
  IGNORE
  INTO TABLE funny_data_loading
  FIELDS TERMINATED BY ",";

LOAD DATA
  INFILE '/var/lib/mysql-files/SnowDevil.csv'
  IGNORE
  INTO TABLE funny_data_loading
  FIELDS TERMINATED BY ",";  
```

Проверка общего количества загруженных строк.
```sql
select count(*) from funny_data_loading;
+----------+
| count(*) |
+----------+
|    14050 |
+----------+
1 row in set (0.02 sec)
```