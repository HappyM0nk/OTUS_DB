Для выполнения домашней работы используются Docker контейнеры 16 версии postgresql.
Для простоты настройка контейнеров сделана в  файле docker-compose.yaml. Два контейнера работают в одной сети внутри docker.
Внутри контейнеров уже есть кластера по умолчанию, они и будут использоваться для репликации.

## Физическая репликация

### Настройка master

Конфигурация файла /var/lib/postgresql/data/pg_hba.conf для обеспечения доступа с реплики на мастер.

```bash
echo 'host all all 0.0.0.0/0 md5' >> /var/lib/postgresql/data/pg_hba.conf
echo 'host replication all 0.0.0.0/0 md5' >> /var/lib/postgresql/data/pg_hba.conf
```

Конфигурация файла /var/lib/postgresql/data/postgresql.conf для установки настроек репликации.

```bash
echo 'wal_level = replica' >> /var/lib/postgresql/data/postgresql.conf
echo 'hot_standby = on' >> /var/lib/postgresql/data/postgresql.conf
echo 'hot_standby_feedback = on' >> /var/lib/postgresql/data/postgresql.conf
echo 'recovery_min_apply_delay = 5min' >> /var/lib/postgresql/data/postgresql.conf
```
Добавление слота и проверка его наличия

```sql
select pg_create_physical_replication_slot('standby_slot');
select * from pg_replication_slots; 

select slot_name, slot_type, active, active_pid,wal_status from pg_replication_slots;
```

```
  slot_name   | slot_type | active | active_pid | wal_status
--------------+-----------+--------+------------+------------
 standby_slot | physical  | t      |         80 | reserved
(1 строка)
```

Для применения всех настроек нужно перезапустить конетйнер.

### Настройка replica

На контейнере реплики достаточно выполнить команду, которая инициирует репликацию с master сервера и ввести пароль пользователя.

```bash
pg_basebackup -p 5432 -h master -U pguser -S standby_slot -R -D /var/lib/postgresql/data
```

После этого все изменения, производимые на master сервере реплицируются на сервер replica с задержкой 5 минут.

Статистика master:

```sql
SELECT * FROM pg_stat_replication \gx
-[ RECORD 1 ]----+------------------------------
pid              | 56
usesysid         | 10
usename          | pguser
application_name | walreceiver
client_addr      | 172.21.0.3
client_hostname  |
client_port      | 53382
backend_start    | 2024-07-14 07:41:06.32441+00
backend_xmin     |
state            | streaming
sent_lsn         | 0/342AE88
write_lsn        | 0/342AE88
flush_lsn        | 0/342AE88
replay_lsn       | 0/342AE88
write_lag        |
flush_lag        |
replay_lag       |
sync_priority    | 0
sync_state       | async
reply_time       | 2024-07-14 08:11:06.889233+00
```

Статистика replica:

```sql
select * from pg_stat_wal_receiver \gx
-[ RECORD 1 ]---------+---------------------
pid                   | 31
status                | streaming
receive_start_lsn     | 0/3000000
receive_start_tli     | 1
written_lsn           | 0/342AE88
flushed_lsn           | 0/342AE88
received_tli          | 1
last_msg_send_time    | 2024-07-14 08:12:25.459848+00
last_msg_receipt_time | 2024-07-14 08:12:25.459999+00
latest_end_lsn        | 0/342AE88
latest_end_time       | 2024-07-14 07:46:25.005009+00
slot_name             | standby_slot
sender_host           | master
sender_port           | 5432
conninfo              | user=pguser password=******** channel_binding=prefer dbname=replication host=master port=5432 fallback_application_name=walreceiver sslmode=prefer sslcompression=0 sslcertmode=allow sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres gssdelegation=0 target_session_attrs=any load_balance_hosts=disable
        
```


## Логическая репликация
### Настройка master

Конфигурация логической репликации, после чего необходимо перезапустить сервер (или контейнер).

```sql
ALTER SYSTEM SET wal_level = logical;
```

Добавление базы данных с таблицей сгенерированных данных.
```sql
create database otus;
\c otus

create table important_data as
select
  generate_series(1,10) as id,
  md5(random()::text)::char(20) as data_value;
```

Добавление публикации и вывод информации о ней.

```sql
CREATE PUBLICATION important_pub FOR TABLE important_data;
\dRp+

                                Публикация important_pub
 Владелец | Все таблицы | Добавления | Изменения | Удаления | Опустошения | Через корень
----------+-------------+------------+-----------+----------+-------------+--------------
 pguser   | f           | t          | t         | t        | t           | f
Таблицы:
    "public.important_data"
```

### Настройка replica

На реплике необходимо создать базу данных и таблицу с такой же структурой, как на сервере с публикацией.

```sql
create database otus;
\c otus
create table important_data (
	id integer,
	data_value character(20)
); 
```

Создание подписки с указание строки подключения к публикации на первом сервере.

```sql
CREATE SUBSCRIPTION important_subscr
CONNECTION 'host=master port=5432 user=pguser password=pgpwd dbname=otus'
PUBLICATION important_pub WITH (copy_data = true);
```

Вывод список подписок.

```
\dRs
                     Список подписок
       Имя        | Владелец | Включён |   Публикация
------------------+----------+---------+-----------------
 important_subscr | pguser   | t       | {important_pub}
(1 строка)
```
А так же статистика по данной подписке.

```sql
SELECT * FROM pg_stat_subscription \gx
-[ RECORD 1 ]---------+------------------------------
subid                 | 16398
subname               | important_subscr
pid                   | 40
leader_pid            |
relid                 |
received_lsn          | 0/1DA3890
last_msg_send_time    | 2024-07-14 08:41:16.741176+00
last_msg_receipt_time | 2024-07-14 08:41:16.741409+00
latest_end_lsn        | 0/1DA3890
latest_end_time       | 2024-07-14 08:41:16.741176+00
```

После успешного добавления подписки на публикацию, все изменения таблицы important_data с сервера master успешно реплицируются в аналогичнуцю таблицу на сервере replica.