CREATE DATABASE IF NOT EXISTS medical_center;
USE medical_center;

CREATE TABLE `specialist` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `surname` varchar(255),
  `first_name` varchar(255),
  `patronymic` varchar(255),
  `speciality` varchar(255)
);

CREATE TABLE `service` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `name` varchar(255)
);

CREATE TABLE `price` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `service_fk` int,
  `price` decimal,
  `begin_date` datetime,
  `end_date` datetime
);

CREATE TABLE `specialist_service` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `specialist_fk` int,
  `service_fk` int
);

CREATE TABLE `client` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `surname` varchar(255),
  `first_name` varchar(255),
  `patronymic` varchar(255),
  `phone` varchar(255)
);

CREATE TABLE `visit` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `client_fk` int,
  `date` datetime,
  `purpose` varchar(255),
  `comment` varchar(255)
);

CREATE TABLE `service_provided` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `service_fk` int,
  `visit_fk` int,
  `date` datetime
);

CREATE TABLE `examination_result` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `service_provided_fk` int,
  `date` datetime,
  `result` varchar(255)
);

CREATE TABLE `visit_specialist` (
  `id` int UNIQUE PRIMARY KEY NOT NULL,
  `visit_fk` int,
  `specialist_fk` int,
  `comment` varchar(255)
);

CREATE INDEX `specialist_index_0` ON `specialist` (`surname`);

CREATE INDEX `specialist_index_1` ON `specialist` (`speciality`);

CREATE UNIQUE INDEX `service_index_2` ON `service` (`name`);

CREATE UNIQUE INDEX `price_index_3` ON `price` (`service_fk`, `begin_date`, `end_date`);

CREATE UNIQUE INDEX `specialist_service_index_4` ON `specialist_service` (`service_fk`, `specialist_fk`);

CREATE INDEX `client_index_5` ON `client` (`surname`) USING HASH;

CREATE UNIQUE INDEX `client_index_6` ON `client` (`phone`);

CREATE INDEX `visit_index_7` ON `visit` (`client_fk`);

CREATE INDEX `service_provided_index_8` ON `service_provided` (`visit_fk`, `service_fk`);

CREATE INDEX `examination_result_index_9` ON `examination_result` (`service_provided_fk`);

CREATE INDEX `visit_specialist_index_10` ON `visit_specialist` (`specialist_fk`, `visit_fk`);

ALTER TABLE `price` ADD FOREIGN KEY (`service_fk`) REFERENCES `service` (`id`);

ALTER TABLE `specialist_service` ADD FOREIGN KEY (`specialist_fk`) REFERENCES `specialist` (`id`);

ALTER TABLE `specialist_service` ADD FOREIGN KEY (`service_fk`) REFERENCES `service` (`id`);

ALTER TABLE `visit` ADD FOREIGN KEY (`client_fk`) REFERENCES `client` (`id`);

ALTER TABLE `service_provided` ADD FOREIGN KEY (`service_fk`) REFERENCES `service` (`id`);

ALTER TABLE `service_provided` ADD FOREIGN KEY (`visit_fk`) REFERENCES `visit` (`id`);

ALTER TABLE `examination_result` ADD FOREIGN KEY (`service_provided_fk`) REFERENCES `service_provided` (`id`);

ALTER TABLE `visit_specialist` ADD FOREIGN KEY (`visit_fk`) REFERENCES `visit` (`id`);

ALTER TABLE `visit_specialist` ADD FOREIGN KEY (`specialist_fk`) REFERENCES `specialist` (`id`);


-- Заполнение тестовыми данными

-- insert into client (id, surname, first_name, patronymic, phone)
-- values (1, 'Иванов', 'Иван', 'Иванович', '111111111'),
-- (2, 'Силиванов', 'Пётр', 'Петрович', '222222222'),
-- (3, 'Сидоров', 'Сидор', 'Сидорович', '333333333');

-- insert into visit (id, client_fk, date, purpose, comment)
-- values (1, 1, '2024-04-20', 'Обследование', '111111111'),
-- (2, 2, '2024-05-20', 'Медкомиссия', '222222222'),
-- (3, 1, '2024-06-10', 'Повторный осмотр', '333333333');

-- insert into specialist (id, surname, first_name, patronymic, speciality)
-- values
-- (1, 'Илизаров', 'Гавриил', 'Абрамович', 'Хирург-ортопед'),
-- (2, 'Мечников', 'Илья', 'Ильич', 'Микробиолог');

-- insert into visit_specialist (id, visit_fk, specialist_fk, comment)
-- values
-- (1, 1, 1, ''),
-- (2, 2, 2, ''),
-- (3, 3, 1, '');

-- INSERT INTO service (id, name)
-- VALUES 
-- 	(1,'Первичный остмотр'),
-- 	(2,'Повторный приём');

-- INSERT INTO price(id, service_fk, price, begin_date, end_date)
-- VALUES 
-- 	(1, 1, 100, '2024-04-20', null),
-- 	(2, 2, 120, '2024-04-20', null),
-- 	(3, 1, 130, '2024-07-20', null);

-- INSERT INTO service_provided (id, service_fk, visit_fk, `date`)
-- values
-- (1, 1, 1, '2024-01-10 13:30:00'),
-- (2, 2, 2, '2024-01-10 13:40:00'),
-- (3, 1, 3, '2024-02-10 10:10:00');

-- INSERT INTO examination_result
--   (id, service_provided_fk, date, comment, results)
-- VALUES
--   (1, 1, '2024-01-10 13:30:00', 'Биохимический анализ крови','{"GLU": 1.52, "UREA": 8, "CREA": 88.2, "CHOL": 10.9}'),
--   (2, 2, '2024-01-10 13:40:00', 'Обследование глазного дна','{"DV": 135, "DA": 63.5, "KI": 1.09}'),
--   (3, 3, '2024-02-10 10:10:00', 'Биохимический анализ крови','{"GLU": 3.82, "UREA": 8, "CREA": 88.2, "CHOL": 10.9}');