insert into directory.client (id, surname, first_name, patronymic, phone)
values (1, 'Иванов', 'Иван', 'Иванович', '111111111'),
(2, 'Силиванов', 'Пётр', 'Петрович', '222222222'),
(3, 'Сидоров', 'Сидор', 'Сидорович', '333333333');

insert into directory.visit (id, client_fk, date, purpose, comment)
values (1, 1, '2024-04-20', 'Обследование', '111111111'),
(2, 2, '2024-05-20', 'Медкомиссия', '222222222'),
(3, 1, '2024-06-10', 'Повторный осмотр', '333333333');

insert into directory.specialist (id, surname, first_name, patronymic, speciality)
values
(1, 'Илизаров', 'Гавриил', 'Абрамович', 'Хирург-ортопед'),
(2, 'Мечников', 'Илья', 'Ильич', 'Микробиолог');

insert into reference.visit_specialist (id, visit_fk, specialist_fk, comment)
values
(1, 1, 1, ''),
(2, 2, 2, ''),
(3, 3, 1, '');

INSERT INTO directory.service (id, name)
VALUES 
	(1,'Первичный остмотр'),
	(2,'Повторный приём');

INSERT INTO directory.price(id, service_fk, price, begin_date, end_date)
VALUES 
	(1, 1, 100, '2024-04-20', null),
	(2, 2, 120, '2024-04-20', null),
	(3, 1, 130, '2024-07-20', null);

-- insert into price (service_fk, price, begin_date, end_date) 
-- select service_fk, price*1.1, ADDDATE(begin_date, INTERVAL 1 MONTH), ADDDATE(end_date, INTERVAL 1 MONTH) from price;


INSERT INTO service_provided (id, service_fk, visit_fk, `date`)
values
(1, 1, 1, '2024-01-10 13:30:00'),
(2, 2, 2, '2024-01-10 13:40:00'),
(3, 1, 3, '2024-02-10 10:10:00');

INSERT INTO examination_result
  (id, service_provided_fk, date, comment, results)
VALUES
  (1, 1, '2024-01-10 13:30:00', 'Биохимический анализ крови','{"GLU": 1.52, "UREA": 8, "CREA": 88.2, "CHOL": 10.9}'),
  (2, 2, '2024-01-10 13:40:00', 'Обследование глазного дна','{"DV": 135, "DA": 63.5, "KI": 1.09}'),
  (3, 3, '2024-02-10 10:10:00', 'Биохимический анализ крови','{"GLU": 3.82, "UREA": 8, "CREA": 88.2, "CHOL": 10.9}');