CREATE DATABASE IF NOT EXISTS sales;

SET foreign_key_checks = 0;
DROP TABLE IF EXISTS region;
DROP TABLE IF EXISTS chief;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS sales;
SET foreign_key_checks = 1;


CREATE TABLE category
(
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255),
    PRIMARY KEY(id),
    CONSTRAINT uc_name UNIQUE (name),
	UNIQUE INDEX `name_idx` (`name`)
)
ENGINE=INNODB;

CREATE TABLE region
(
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255),
    PRIMARY KEY(id),
    CONSTRAINT uc_name UNIQUE (name),
	UNIQUE INDEX `name_idx` (`name`)
)
ENGINE=INNODB;

CREATE TABLE chief
(
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255),
	fk_region INT NOT NULL,
    PRIMARY KEY(id),
    CONSTRAINT uc_name UNIQUE (name),
	FOREIGN KEY (`fk_region`) REFERENCES `region`(`id`),
	UNIQUE INDEX `name_idx` (`name`)
)
ENGINE=INNODB;

CREATE TABLE employee
(
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255),
	fk_chief INT NOT NULL,
    PRIMARY KEY(id),
    CONSTRAINT uc_name UNIQUE (name),
	FOREIGN KEY (`fk_chief`) REFERENCES `chief`(`id`),
	UNIQUE INDEX `name_idx` (`name`)
)
ENGINE=INNODB;

CREATE TABLE sales
(
    id INT NOT NULL AUTO_INCREMENT,
	dateSale DATE NOT NULL,
	totalSale INT NOT NULL,
	salesNumber INT NOT NULL,
	cb INT NOT NULL,
	`check` INT NOT NULL,
	fk_employee INT NOT NULL,
	fk_category INT NOT NULL,
    PRIMARY KEY(id),
	FOREIGN KEY (`fk_employee`) REFERENCES `employee`(`id`),
	FOREIGN KEY (`fk_category`) REFERENCES `category`(`id`),
	INDEX `dateSale_idx` (`dateSale`)
)
ENGINE=INNODB;


