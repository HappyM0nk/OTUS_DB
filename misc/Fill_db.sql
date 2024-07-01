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