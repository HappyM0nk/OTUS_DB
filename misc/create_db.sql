CREATE DATABASE medical_center;
\c medical_center;

CREATE SCHEMA directory;
CREATE SCHEMA reference;

CREATE TABLE directory.specialist (
  "id" int UNIQUE PRIMARY KEY NOT NULL,
  "surname" varchar,
  "first_name" varchar,
  "patronymic" varchar,
  "speciality" varchar
);

CREATE TABLE directory.service (
  "id" int UNIQUE PRIMARY KEY NOT NULL,
  "name" varchar
);

CREATE TABLE directory.price (
  "id" int UNIQUE PRIMARY KEY NOT NULL,
  "service_fk" int,
  "price" decimal,
  "begin_date" timestamp,
  "end_date" timestamp
);

CREATE TABLE reference.specialist_service (
  "id" int UNIQUE PRIMARY KEY NOT NULL,
  "specialist_fk" int,
  "service_fk" int
);

CREATE TABLE directory.client (
  "id" int UNIQUE PRIMARY KEY NOT NULL,
  "surname" varchar,
  "first_name" varchar,
  "patronymic" varchar,
  "phone" varchar
);

CREATE TABLE directory.visit (
  "id" int UNIQUE PRIMARY KEY NOT NULL,
  "client_fk" int,
  "date" timestamp,
  "purpose" varchar,
  "comment" varchar
);

CREATE TABLE reference.service_provided (
  "id" int UNIQUE PRIMARY KEY NOT NULL,
  "service_fk" int,
  "visit_fk" int,
  "date" timestamp
);

CREATE TABLE directory.examination_result (
  "id" int UNIQUE PRIMARY KEY NOT NULL,
  "service_provided_fk" int,
  "date" timestamp,
  "result" varchar
);

CREATE TABLE reference.visit_specialist (
  "id" int UNIQUE PRIMARY KEY NOT NULL,
  "visit_fk" int,
  "specialist_fk" int,
  "comment" varchar
);

ALTER TABLE directory.price ADD FOREIGN KEY ("service_fk") REFERENCES directory.service ("id");

ALTER TABLE reference.specialist_service ADD FOREIGN KEY ("specialist_fk") REFERENCES directory.specialist ("id");

ALTER TABLE reference.specialist_service ADD FOREIGN KEY ("service_fk") REFERENCES directory.service ("id");

ALTER TABLE directory.visit ADD FOREIGN KEY ("client_fk") REFERENCES directory.client ("id");

ALTER TABLE reference.service_provided ADD FOREIGN KEY ("service_fk") REFERENCES directory.service ("id");

ALTER TABLE reference.service_provided ADD FOREIGN KEY ("visit_fk") REFERENCES directory.visit ("id");

ALTER TABLE directory.examination_result ADD FOREIGN KEY ("service_provided_fk") REFERENCES reference.service_provided ("id");

ALTER TABLE reference.visit_specialist ADD FOREIGN KEY ("visit_fk") REFERENCES directory.visit ("id");

ALTER TABLE reference.visit_specialist ADD FOREIGN KEY ("specialist_fk") REFERENCES directory.specialist ("id");