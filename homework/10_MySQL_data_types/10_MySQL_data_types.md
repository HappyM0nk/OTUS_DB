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

Поля причины визита и комментария преобразованы в text для более правильного хранения срвнительно небольшого объёма текста.

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

Поле результата обследования может содержать .

```sql
CREATE TABLE `examination_result` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `service_provided_fk` int,
  `date` datetime,
  `result` mediumtext
);
```


### Таблица связи посещения клиента и специалистов. 

Поле комментария преобразовано в text для более правильного хранения срвнительно небольшого объёма текста.

```sql
CREATE TABLE `visit_specialist` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `visit_fk` int,
  `specialist_fk` int,
  `comment` text
);
```
