# Выборки MySQL
## Запрос с использованием INNER JOIN

Следующий запрос выведет запрошенные поля таблиц клиентов и визитов для клиентов, у которых были визиты в центр.

```sql
select cl.id, cl.surname, cl.first_name, cl.patronymic, cl.phone, v.purpose, v.comment
from client as cl 
inner join visit as v
    on cl.id = v.client_fk;

|id |surname  |first_name|patronymic|phone    |purpose         |comment  |
|---|---------|----------|----------|---------|----------------|---------|
|1  |Иванов   |Иван      |Иванович  |111111111|Обследование    |111111111|
|2  |Силиванов|Пётр      |Петрович  |222222222|Медкомиссия     |222222222|
|1  |Иванов   |Иван      |Иванович  |111111111|Повторный осмотр|333333333|
```

## Запрос с использованием LEFT JOIN

Следующий запрос выведет данные таблиц клиентов и визитов для клиентов, при этом если у клиента не было визитов, соответствующие поля будут пустыми (NULL).


```sql
select cl.id, cl.surname, cl.first_name, cl.patronymic, cl.phone, v.purpose, v.comment
from client as cl left join visit as v
    on cl.id = v.client_fk
order by cl.id;

|id |surname  |first_name|patronymic|phone    |purpose         |comment  |
|---|---------|----------|----------|---------|----------------|---------|
|1  |Иванов   |Иван      |Иванович  |111111111|Обследование    |111111111|
|1  |Иванов   |Иван      |Иванович  |111111111|Повторный осмотр|333333333|
|2  |Силиванов|Пётр      |Петрович  |222222222|Медкомиссия     |222222222|
|3  |Сидоров  |Сидор     |Сидорович |333333333|                |         |

```

## Запрос с использованием WHERE

Запрос выводит последние 5 визитов для конкретного клиента по его id. Может быть полезно для администратора центра, к которому обратился данный клиент.

```sql
select v.date, cl.surname, cl.first_name, cl.patronymic, cl.phone, v.purpose, v.comment
from client as cl left join visit as v
    on cl.id = v.client_fk
where cl.id = 1
order by v.date desc
limit 5;

|date               |surname|first_name|patronymic|phone    |purpose         |comment  |
|-------------------|-------|----------|----------|---------|----------------|---------|
|2024-06-10 00:00:00|Иванов |Иван      |Иванович  |111111111|Повторный осмотр|333333333|
|2024-04-20 00:00:00|Иванов |Иван      |Иванович  |111111111|Обследование    |111111111|


```

Вывод всех посещений центра, которые произошли за определённый период. Полезно для отчтёности за месяц или квартал.

```sql
select v.date, cl.surname, cl.first_name, cl.patronymic, cl.phone, v.purpose, v.comment
from client as cl inner join visit as v
    on cl.id = v.client_fk 
where v.date between '2024-05-01 00:00:00' and '2024-05-31 23:59:59';

|date               |surname  |first_name|patronymic|phone    |purpose    |comment  |
|-------------------|---------|----------|----------|---------|-----------|---------|
|2024-05-20 00:00:00|Силиванов|Пётр      |Петрович  |222222222|Медкомиссия|222222222|

```

Запрос выводит специалистов, визитов к которым было менее 10 за месяц. Можно отслеживать востребованность специалистов центра.

```sql
select * from
	(select s.surname, s.first_name, s.patronymic, count(v.id) as visits_count
	from specialist s inner join visit_specialist vs
	    on s.id = vs.specialist_fk 
	inner join visit v
		on v.id = vs.visit_fk
	group by s.id) r
where r.visits_count < 10;
```

Аналогичный результат можно получить используя оператор HAVING.

```sql
select s.surname, s.first_name, s.patronymic, count(v.id) as visits_count
from specialist s inner join visit_specialist vs
    on s.id = vs.specialist_fk 
inner join visit v
	on v.id = vs.visit_fk
group by s.id
having visits_count < 10;

|surname |first_name|patronymic|visits_count|
|--------|----------|----------|------------|
|Илизаров|Гавриил   |Абрамович |2           |
|Мечников|Илья      |Ильич     |1           |

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

|date               |Glucose|
|-------------------|-------|
|2024-01-10 13:30:00|1.52   |
|2024-02-10 10:10:00|3.82   |

```

Запрос на плановое повышение цены в полтора раза через месяц на все услуги, цена которых менее 100. В примере повысится цена только на одну услугу, с 90 до 135.

```sql
INSERT INTO price 
  (service_fk, price, begin_date)
SELECT
    service_fk,
    price * 1.5,
    DATE_ADD(CURRENT_DATE(), INTERVAL 1 MONTH)
  FROM price
  WHERE price < 100;

|id |service_fk|price|begin_date         |end_date|
|---|----------|-----|-------------------|--------|
|1  |1         |90   |2024-04-20 00:00:00|        |
|2  |2         |120  |2024-04-20 00:00:00|        |
|3  |1         |135  |2024-08-20 00:00:00|        |

```