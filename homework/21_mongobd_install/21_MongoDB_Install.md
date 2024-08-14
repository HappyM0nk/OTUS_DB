## Установка СУБД MongoDB

### Запуск MongoDB в docker контейнере
Самый простой способ запуска MongoDB в целях обучения и разработки - это docker контейнер.
Согласно документации на официальном сайте, для запуска MongoDB достаточно последовательно выполнить следующие команды:

```bash
docker pull mongodb/mongodb-community-server:latest

docker run --name mongodb -p 27017:27017 -d mongodb/mongodb-community-server:latest
```

После скачивания и запуска контейнера можно проверить его наличие в списке запущенных, статус и проброшенные порты.

```
>docker container ls

CONTAINER ID   IMAGE                                     COMMAND                  CREATED       STATUS         PORTS                      NAMES  
0dc9a80ee7eb   mongodb/mongodb-community-server:latest   "python3 /usr/local/…"   2 hours ago   Up 4 seconds   0.0.0.0:27017->27017/tcp   mongodb
```

Для подключения к запущенной СУБД удобнее всего использовать утилиту mongosh с указанием проброшенного порта. 

```
mongosh --port 27017
```

При успешном подключении будет автоматически выбрана база test.

###Заполненеие данными
Для создания и заполнения новой БД используются следующие команды:

```
use playground

db.clients.insertMany([ 
  {"_id": 1, "surname": "Иванов", "first_name": "Иван", "patronymic": "Иванович", "phone": "111111111" },
  {"_id": 2, "surname": "Силиванов", "first_name": "Пётр", "patronymic": "Петрович", "phone": "222222222" },
  {"_id": 3, "surname": "Сидоров", "first_name": "Сидор", "patronymic": "Сидорович", "phone": "333333333" }
] )

db = {
  "clients": [
    {"_id": 1, "surname": "Иванов", "first_name": "Иван", "patronymic": "Иванович", "phone": "111111111" },
    {"_id": 2, "surname": "Силиванов", "first_name": "Пётр", "patronymic": "Петрович", "phone": "222222222" },
    {"_id": 3, "surname": "Сидоров", "first_name": "Сидор", "patronymic": "Сидорович", "phone": "333333333" }
  ],
  "examination_results": [
    {
      "_id": 1,
      "client_id": 1,
      "date": "2024-01-10 13:30:00",
      "description": "Биохимический анализ крови",
      "results": [
        {"GLU": "1.52"},
        {"UREA": "8"}, 
        {"CREA": "88.2"}, 
        {"CHOL": "10.9"}
      ]
    },
    {
      "_id": 2,
      "client_id": 2,
      "date": "2024-01-10 13:40:00",
      "description": "Обследование глазного дна",
      "results": [
        {"DV": "135"}, 
        {"DA": "63.5"}, 
        {"KI": "1.09"}
      ]
    },
    {
      "_id": 3,
      "client_id": 1,
      "date": "2024-02-10 10:10:00",
      "description": "Биохимический анализ крови",
      "results": [
        {"GLU": "3.82"}, 
        {"UREA": "8"}, 
        {"CREA": "88.2"}, 
        {"CHOL": "10.9"}
      ]
    }
  ]
}
```


###Запросы на выборку данных

Простой запрос поиска клиента по номеру его телефона:
```
db.clients.find({"phone": "333333333"})
```
Результат:
```json
[
  {
    _id: 3,
    surname: 'Сидоров',
    first_name: 'Сидор',
    patronymic: 'Сидорович',
    phone: '333333333'
  }
]
```

Агригированный запрос выборки клиента по фамилии Иванов со всеми результатами его обследований:
```
db.clients.aggregate([ 
    { "$lookup": { "from": "examination_results", "localField": "_id", "foreignField": "client_id", "as": "examinations" }}, 
    { "$match": { "surname": "Иванов" } }
  ]
)
```

Результат:
```json
[
  {
    _id: 1,
    surname: 'Иванов',
    first_name: 'Иван',
    patronymic: 'Иванович',
    phone: '111111111',
    examinations: [
      {
        _id: 1,
        client_id: 1,
        date: '2024-01-10 13:30:00',
        description: 'Биохимический анализ крови',
        results: [
          { GLU: '1.52' },
          { UREA: '8' },
          { CREA: '88.2' },
          { CHOL: '10.9' }
        ]
      },
      {
        _id: 3,
        client_id: 1,
        date: '2024-02-10 10:10:00',
        description: 'Биохимический анализ крови',
        results: [
          { GLU: '3.82' },
          { UREA: '8' },
          { CREA: '88.2' },
          { CHOL: '10.9' }
        ]
      }
    ]
  }
]
```


###Запрос на обновление данных

Запрос на смену телефона клиента с id=1:
```
db.clients.updateOne({ "_id": 1 }, { "$set": { "phone": "123123123" } } )
```

При запросе информации о клиенте получим обновлённые данные:
```
db.clients.find({"_id": 1})
```

```json
[
  {
    _id: 1,
    surname: 'Иванов',
    first_name: 'Иван',
    patronymic: 'Иванович',
    phone: '123123123'
  }
]
```