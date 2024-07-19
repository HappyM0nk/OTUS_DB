# Типы данных MySQL
## Анализ типов данных проекта

### Таблица специалистов. 

Поля ФИО получили ограничение по 50 символов, маловероятно потребуется больше на каждое из них. 
Поле специальности стало text. У врача может быть несколько смежных специальностей и квалификаций, лучше хранить как текст для дальнейшей организации поиска.

```sql
CREATE TABLE `specialist` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `surname` varchar(50),
  `first_name` varchar(50),
  `patronymic` varchar(50),
  `speciality` text
);
```

### Таблица клиентов. 

Поля ФИО получили ограничение по 50 символов, маловероятно потребуется больше на каждое из них. 
Поле номера телефона ограничено 18 символами, длиннее телефон не может быть.

```sql
CREATE TABLE `client` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `surname` varchar(50),
  `first_name` varchar(50),
  `patronymic` varchar(50),
  `phone` varchar(18)
);
```

### Таблица посещений. 

Поля причины визита и комментария преобразованы в text для более правильного хранения сравнительно небольшого объёма текста.

```sql
CREATE TABLE `visit` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `client_fk` int,
  `date` datetime,
  `purpose` text,
  `comment` text
);
```


### Таблица результатов обследований. 

Поле комментария преобразовано в text.

```sql
CREATE TABLE `examination_result` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `service_provided_fk` int,
  `date` datetime,
  `comment` text
);
```


### Таблица связи посещения клиента и специалистов. 

Поле комментария преобразовано в text для более правильного хранения сравнительно небольшого объёма текста.
Добавлено поле для рекоммендаций, в которое врач-специалист может вносить назначения, рекомендации и т.п.
Реокмендации выдаются для пациента, комментарий остаётся в системе для других специалистов и администратора.

```sql
CREATE TABLE `visit_specialist` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `visit_fk` int,
  `specialist_fk` int,
  `comment` text,
  `recommendations` mediumtext
);
```

## Добавление типа json

Полезнее всего данный тип может быть использован в таблице результатов обследований.
После добавления поля results, в него можно записывать json с различным набором данных, относящихся к конкртеному обследованию.

```sql
CREATE TABLE `examination_result` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `service_provided_fk` int,
  `date` datetime,
  `comment` text,
  `results` json
);
```
Например клиент может сдать общий биохимический анализ крови и проверить глазное дно. Обе записи будут записаны в одну таблицу с указанием идентификатора обследования и собственным набором результатов в виде json.

```sql
INSERT INTO examination_result
  (id, service_provided_fk, date, comment, results)
VALUES
  (1, 1, '2024-01-10 13:30:00', 'Биохимический анализ крови','{"GLU": 1.52, "UREA": 8, "CREA": 88.2, "CHOL": 10.9}'),
  (2, 2, '2024-01-10 13:40:00', 'Обследование глазного дна','{"DV": 135, "DA": 63.5, "KI": 1.09}'),
  (3, 3, '2024-02-10 10:10:00', 'Биохимический анализ крови','{"GLU": 3.82, "UREA": 8, "CREA": 88.2, "CHOL": 10.9}');
```

Следующим запросом можно узнать динамику изменения уровня сахара у конкретного пциента с указанием даты сдачи анализа.

```sql
SELECT
  er.date,
  er.results->>'$.GLU' AS Glucose
FROM examination_result er
INNER JOIN service_provided sp ON er.service_provided_fk = sp.id
INNER JOIN visit v ON sp.visit_fk = v.id
WHERE v.client_fk = 1 and sp.service_fk = 1
ORDER BY er.date;
```

```
+---------------------+---------+
| date                | Glucose |
+---------------------+---------+
| 2024-01-10 13:30:00 | 1.52    |
| 2024-02-10 10:10:00 | 3.82    |
+---------------------+---------+
```