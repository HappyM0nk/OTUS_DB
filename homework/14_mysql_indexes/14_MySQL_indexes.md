# Индексы MySQL
## Анализ индексов

На мой взгляд к имеющимся индексам стоит добавить составной индекс для более быстрой выборки актуальных цен на услуги.

```sql
CREATE INDEX idx_service_dates
    ON price (begin_date, end_date);
```

До применения индекса
```sql
explain select * from price where CURRENT_DATE() between begin_date and end_date \G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: price
   partitions: NULL
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 12268
     filtered: 11.11
        Extra: Using where
1 row in set, 1 warning (0.01 sec)
```

После применения составного индекса по датам
```sql
explain select * from price where CURRENT_DATE() between begin_date and end_date \G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: price
   partitions: NULL
         type: ALL
possible_keys: idx_service_dates
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 12181
     filtered: 5.55
        Extra: Using where
1 row in set, 1 warning (0.00 sec)
```

## Полнотекстовый индекс

Для выполнения задания я добавил в таблицу service поле description типа text для хранения развёрнутой информации о предоставляемой улуге.
Таким образом можно созадать полнотекстовый индкс по полям с названием и описанием услуги.


```sql
CREATE FULLTEXT INDEX fulltext_idx_service_name_description
    ON service (name, description);
```

Анализ поиска по полям name и description
```sql
explain select * from service where match (name, description) against ('lorem') \G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: service
   partitions: NULL
         type: fulltext
possible_keys: fulltext_idx_service_name_description
          key: fulltext_idx_service_name_description
      key_len: 0
          ref: const
         rows: 1
     filtered: 100.00
        Extra: Using where; Ft_hints: sorted
1 row in set, 1 warning (0.00 sec)
```