# Архитектура MySQL
## Запуск MySQL в Docker

Для выполнения домашней работы используются матриалы из репозитория https://github.com/aeuge/otus-mysql-docker.
Для запуска контейнера используется команда:

```bash
docker-compose up otusdb
```

После успешного запуска окнтейнера, к нему можно подключиться и внутри него зайти в систему управления СУБД mysql и подключиться к БД otus.

```bash
mysql -u root -p12345 otus
```

Для проверки подключения к СУБД можно запросить её версию и получить результат:

```sql
mysql> select version();
+-----------+
| version() |
+-----------+
| 8.0.15    |
+-----------+
1 row in set (0.00 sec)
```

## Заполнение файла init.sql
Данный файл используется для инициализации базы данных при создании контейнера. 
Данный файл находится в текущей папке с домашним заданием (/homework/09_MySQL_install/init.sql)
Результатом работы данного скрипта будет наличие созданной базы данных сразу после разврачивания контейнера.

```sql
mysql> show tables;
+--------------------------+
| Tables_in_medical_center |
+--------------------------+
| client                   |
| examination_result       |
| price                    |
| service                  |
| service_provided         |
| specialist               |
| specialist_service       |
| visit                    |
| visit_specialist         |
+--------------------------+
9 rows in set (0.00 sec)
```


## Конфигурация сервера (my.cnf)
Настроить сервер можно через файл конфигурации custom.conf/my.cnf, который размещается в контейнере по пути /etc/mysql/conf.d
Для примера можно изменить параметры innodb_buffer_pool_size, max_connections и max_allowed_packet.
Тестовый файл конфигурации находится в текущей папке с домашним заданием (/homework/09_MySQL_install/my.cnf).

```
innodb_buffer_pool_size = 512M
max_connections = 128
max_allowed_packet  = 16M
```

Кастомный файл конфигурации у меня не захотел сразу применяться, пришлось вручную задать на него права. После перезапуска контейнера новые параметры применились.

```bash
chmod 644 /etc/mysql/conf.d/my.cnf
```

Проверка применения данных параметров:
```sql
mysql> show variables like '%max_connections%';
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| max_connections        | 128   |
| mysqlx_max_connections | 100   |
+------------------------+-------+
2 rows in set (0.01 sec)
```

```sql
mysql> show variables like '%innodb_buffer_pool_size%';
+-------------------------+-----------+
| Variable_name           | Value     |
+-------------------------+-----------+
| innodb_buffer_pool_size | 536870912 |
+-------------------------+-----------+
1 row in set (0.00 sec)
```

```sql
mysql> show variables like '%max_allowed_packet%';
+---------------------------+------------+
| Variable_name             | Value      |
+---------------------------+------------+
| max_allowed_packet        | 16777216   |
| mysqlx_max_allowed_packet | 67108864   |
| slave_max_allowed_packet  | 1073741824 |
+---------------------------+------------+
3 rows in set (0.01 sec)
```
