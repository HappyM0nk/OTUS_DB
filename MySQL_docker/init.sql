CREATE DATABASE medical_center CHARACTER SET utf8mb4;
USE medical_center;

CREATE TABLE `specialist` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `surname` varchar(50),
  `first_name` varchar(50),
  `patronymic` varchar(50),
  `speciality` mediumtext
);

CREATE TABLE `service` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(255),
  `description` text
);

CREATE TABLE `price` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `service_fk` int,
  `price` decimal,
  `begin_date` datetime,
  `end_date` datetime
);

CREATE TABLE `specialist_service` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `specialist_fk` int,
  `service_fk` int
);

CREATE TABLE `client` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `surname` varchar(50),
  `first_name` varchar(50),
  `patronymic` varchar(50),
  `phone` varchar(18)
);

CREATE TABLE `visit` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `client_fk` int,
  `date` datetime,
  `purpose` text,
  `comment` text
);

CREATE TABLE `service_provided` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `service_fk` int,
  `visit_fk` int,
  `date` datetime
);

CREATE TABLE `examination_result` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `service_provided_fk` int,
  `date` datetime,
  `comment` text,
  `results` json
);

CREATE TABLE `visit_specialist` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `visit_fk` int,
  `specialist_fk` int,
  `comment` text,
  `recommendations` mediumtext
);

CREATE INDEX `idx_specialist_surname` ON `specialist` (`surname`);

CREATE INDEX `idx_specialist_speciality` ON `specialist` (`speciality`);

CREATE UNIQUE INDEX `uniq_idx_service_name` ON `service` (`name`);

CREATE UNIQUE INDEX `uniq_idx_price_service_dates` ON `price` (`service_fk`, `begin_date`, `end_date`);

CREATE UNIQUE INDEX `uniq_idx_specialist_service_service_specialist` ON `specialist_service` (`service_fk`, `specialist_fk`);

CREATE INDEX `idx_client_surname` ON `client` (`surname`) USING HASH;

CREATE UNIQUE INDEX `uniq_idx_client_phone` ON `client` (`phone`);

CREATE INDEX `idx_visit_client` ON `visit` (`client_fk`);

CREATE INDEX `idx_service_provided_visit_service` ON `service_provided` (`visit_fk`, `service_fk`);

CREATE INDEX `idx_examination_result_service_provided` ON `examination_result` (`service_provided_fk`);

CREATE INDEX `idx_visit_specialist_visit_specialist` ON `visit_specialist` (`specialist_fk`, `visit_fk`);

CREATE INDEX idx_service_dates ON `price` (`begin_date`, `end_date`);

CREATE FULLTEXT INDEX fulltext_idx_service_name_description ON `service` (`name`, `description`);

ALTER TABLE `price` ADD FOREIGN KEY (`service_fk`) REFERENCES `service` (`id`);

ALTER TABLE `specialist_service` ADD FOREIGN KEY (`specialist_fk`) REFERENCES `specialist` (`id`);

ALTER TABLE `specialist_service` ADD FOREIGN KEY (`service_fk`) REFERENCES `service` (`id`);

ALTER TABLE `visit` ADD FOREIGN KEY (`client_fk`) REFERENCES `client` (`id`);

ALTER TABLE `service_provided` ADD FOREIGN KEY (`service_fk`) REFERENCES `service` (`id`);

ALTER TABLE `service_provided` ADD FOREIGN KEY (`visit_fk`) REFERENCES `visit` (`id`);

ALTER TABLE `examination_result` ADD FOREIGN KEY (`service_provided_fk`) REFERENCES `service_provided` (`id`);

ALTER TABLE `visit_specialist` ADD FOREIGN KEY (`visit_fk`) REFERENCES `visit` (`id`);

ALTER TABLE `visit_specialist` ADD FOREIGN KEY (`specialist_fk`) REFERENCES `specialist` (`id`);

ALTER TABLE `visit` PARTITION BY RANGE (TO_DAYS(`date`))
(
    PARTITION older VALUES LESS THAN (TO_DAYS('2024-07-01')),
    PARTITION p202407 VALUES LESS THAN (TO_DAYS('2024-08-01')),
    PARTITION p202408 VALUES LESS THAN (TO_DAYS('2024-09-01')),
    PARTITION p202409 VALUES LESS THAN (TO_DAYS('2024-10-01')),
    PARTITION p202410 VALUES LESS THAN (TO_DAYS('2024-11-01')),
    PARTITION newer VALUES LESS THAN (TO_DAYS('9999-12-31'))
);

-- Заполнение тестовыми данными

insert into client (surname, first_name, patronymic, phone)
values 
  ('Иванов', 'Иван', 'Иванович', '111111111'),
  ('Силиванов', 'Пётр', 'Петрович', '222222222'),
  ('Сидоров', 'Сидор', 'Сидорович', '333333333');

insert into visit (client_fk, date, purpose, comment)
values 
  (1, '2024-07-20', 'Обследование', '111111111'),
  (2, '2024-08-20', 'Медкомиссия', '222222222'),
  (1, '2025-06-10', 'Повторный осмотр', '333333333');

insert into specialist (surname, first_name, patronymic, speciality)
values
  ('Илизаров', 'Гавриил', 'Абрамович', 'Хирург-ортопед'),
  ('Мечников', 'Илья', 'Ильич', 'Микробиолог');

insert into visit_specialist (visit_fk, specialist_fk, comment)
values
  (1, 1, ''),
  (2, 2, ''),
  (3, 1, '');

INSERT INTO service (name)
VALUES 
	('Первичный остмотр'),
	('Повторный приём');

INSERT INTO price (service_fk, price, begin_date, end_date)
VALUES 
	(1, 100, '2024-04-20', null),
	(2, 120, '2024-04-20', null),
	(1, 130, '2024-07-20', null);

INSERT INTO service_provided (service_fk, visit_fk, `date`)
values
(1, 1, '2024-01-10 13:30:00'),
(2, 2, '2024-01-10 13:40:00'),
(1, 3, '2024-02-10 10:10:00');

INSERT INTO examination_result
  (service_provided_fk, date, comment, results)
VALUES
  (1, '2024-01-10 13:30:00', 'Биохимический анализ крови','{"GLU": 1.52, "UREA": 8, "CREA": 88.2, "CHOL": 10.9}'),
  (2, '2024-01-10 13:40:00', 'Обследование глазного дна','{"DV": 135, "DA": 63.5, "KI": 1.09}'),
  (3, '2024-02-10 10:10:00', 'Биохимический анализ крови','{"GLU": 3.82, "UREA": 8, "CREA": 88.2, "CHOL": 10.9}');