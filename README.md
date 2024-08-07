## Проект "Медицинский центр"

### Структура репозитория

* homework - домашние работы по заданным темам
* misc - вспомогательные файлы
* MySQL_docker - необходимая структура папок и файлов для запуска docker контейнера MySQL
* PostgreSQL_docker - необходимая структура папок и файлов для запуска docker контейнера PostgreSQL

### Схема базы данных
![Схема базы данных](/misc/db_diagram.png)

### Примеры бизнес-задач, которые решает база
* Хранение перечня услуг и истории цен на них, учитывая возможность утановки цены на определённый период
* Хранение списка специалистов с привязкой оказываемых ими услуг
* Хранение списка клиетов
* Хранение истории посещений клиента с возможностью привязки участия специалистов, списка оказанных услуг и результатов проведённых исследований

### Описание таблиц и полей
* Специалисты
    * Идентификатор
    * Фамилия
    * Имя
    * Отчество
    * Специальность
* Список услуг
    * Идентификатор
    * Название услуги
* Цены на услуги
    * Идентификатор
    * Идентификатор услуги
    * Цена
    * Дата начала действия
    * Дата окончания действия
* Связь специалистов и услуг
    * Идентификатор
    * Идентификатор специалиста
    * Идентификатор услуги
* Клиенты
    * Идентификатор
    * Фамилия
    * Имя
    * Отчество
    * Телефон
* История посещений
    * Идентификатор
    * Идентификатор клиента
    * Дата
    * Цель визита
    * Комментарий
* История оказания услуг
    * Идентификатор
    * Идентификатор услуги
    * Идентификатор посещения
    * Дата
* Результаты исследований
    * Идентификатор
    * Идентификатор оказанной услуги
    * Дата
    * Результат исследования
* История участия специалистов в посещении
    * Идентификатор
    * Идентификатор посещения
    * Идентификатор специалиста
    * Комментарий специалиста

### Описание индексов в таблицах
* Специалисты
    * Индекс на фамилию. Нужен для быстрого поиска по фамилии специлиста
    * Индекс на специальность. Нужен для быстрого поиска по специальности
* Список услуг
    * Уникальный индекс на название услуги. Нужен для быстрого поиска по названию и исключению ситуации с дублированием услуг.
* Цены на услуги
    * Композитный уникальный индекс по полям "Идентификатор услуги", "Дата начала действия", "Дата окончания действия". Нужен для быстрого поиска актуальной цены на услугу. Исключает дублирование записей с периодом действия цены.
    * Ограничение по полям "Дата начала действия", "Дата окончания действия". Дата начала действия должна быть раньше, чем дата окончания.
* Связь специалистов и услуг
    * Композитный уникальный индекс по полям "Идентификатор услуги" и "Идентификатор специалиста". Нужен для ускорения выборки услуг по специалистам и исключению дублирования связей.
* Клиенты
    * Индекс по полю "Фамилия". Для ускорения поиска клиентов в списке.
    * Уникальный индекс по полю "Телефон". Для ускорения поиска клиента в базе по номеру телефона и исключения привязки нескольких клиентов к одному номеру.
* История посещений
    * Индекс по полю "Идентификатор клиента". Для ускорения выборки всех посещений конкретного клиента.
* История оказания услуг
    * Композитный индекс по полям "Идентификатор посещения" и "Идентификатор услуги". Нужен для ускорения выборки услуг по посещениям.
* Результаты исследований
    * Индекс по полю "Идентификатор оказанной услуги". Для ускорения выборки всех результатов по услуге.
* История участия специалистов в посещении
    * Композитный уникальный индекс по полям "Идентификатор посещения" и "Идентификатор специалиста". Нужен для ускорения выборки специалистов, участвовавших в посещении и исключению дублирования связей.