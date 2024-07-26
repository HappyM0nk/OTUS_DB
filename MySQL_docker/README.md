Поднять сервис db_va можно командой:

`docker-compose up medical_center_db`

Для подключения к БД используйте команду:

`docker-compose exec medical_center_db mysql -u root -p12345 medical_center`

Для использования в клиентских приложениях можно использовать команду:

`mysql -u root -p12345 --port=3309 --protocol=tcp medical_center`