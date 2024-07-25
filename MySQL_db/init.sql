CREATE database medical_center;
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