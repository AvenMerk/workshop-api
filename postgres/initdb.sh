#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "postgres" <<-EOSQL
CREATE USER workshop;
CREATE DATABASE workshop;
GRANT ALL PRIVILEGES ON DATABASE workshop TO workshop;
ALTER USER workshop WITH encrypted password 'workshop';
ALTER USER workshop SET search_path TO workshop, public;
EOSQL

psql -v ON_ERROR_STOP=1 --username "workshop" --dbname "workshop" <<-EOSQL
CREATE TABLE category (
  category_id   INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  name          VARCHAR(60) NOT NULL UNIQUE
);

CREATE TYPE CUSTOMER_LOCALE AS ENUM ('RU', 'ENG');
CREATE TABLE customer (
  customer_id      INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  creation_time    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  first_name       VARCHAR(60) NOT NULL,
  last_name        VARCHAR(60) NOT NULL,
  middle_name      VARCHAR(60)              DEFAULT '',
  locale           CUSTOMER_LOCALE NOT NULL DEFAULT 'RU',
  email            VARCHAR(60) NOT NULL,
  phone            VARCHAR(60) NOT NULL
);

CREATE TABLE product (
  product_id        INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  name              VARCHAR(200)   NOT NULL UNIQUE,
  category_id       INT REFERENCES category (category_id),
  creation_time     TIMESTAMP  NOT NULL  DEFAULT CURRENT_TIMESTAMP,
  price             NUMERIC(10, 2) NOT NULL CHECK (price >= 0) DEFAULT 0,
  short_description VARCHAR(240) NOT NULL,
  description       TEXT NOT NULL
);

CREATE TABLE cart (
  cart_id          INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  creation_time    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  customer_id      INT REFERENCES customer   (customer_id),
  price            NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
  description      VARCHAR(240) NOT NULL,
  shipping_address TEXT NOT NULL
);

CREATE TABLE purchase (
  purchase_id      INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  creation_time    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cart_id          INT REFERENCES cart (cart_id) ON UPDATE CASCADE ON DELETE CASCADE,
  product_id       INT REFERENCES product (product_id) ON UPDATE CASCADE,
  quantity         INT NOT NULL CHECK (quantity >= 0) DEFAULT 1
);

INSERT INTO category (name) VALUES ('Simpsons'),('Adventure time'), ('Rick&Morty');

INSERT INTO product (name, category_id, price, short_description, description) VALUES
  ('Beer', '1', 11.1, 'Beer... Now there\'s a temporary solution', 'What can be more awesome, than a bottle-two of cold beer after busy day?Just take some Duff\'s beer and be happy!'),
  ('Krusty Burger', '1', 11.2, 'Original Krusty Burger\'s poster', 'Just take this big yummy burger! Or two! Eat \'em and stop worrying about everything!'),
  ('Donut', '1', 11.3, 'Would you like some fresh yummy donuts?', 'Just imagine that:  softly crispy doughnut on the outside with a sweet chocolate iceing spread out evenly over the top, nice soft dough but not undercooked on the inside with some sweet creamy custard filling on the inside as well, not too gooey thatd be gross but not too thin cuz it would fall out when you bit into the doughnut.'),
  ('Jake', '2', 12.1, 'One of the most famous Jake\'s quotes', 'Dude, sukin\' at something is the first step to being sorta good at something'),
  ('BMO', '2', 12.2, 'Who wants to play video games?', 'Let\'s help little BMO to find someone?''),
  ('Ice king', '2', 12.3, 'I just want to be loved', '"I just want to be loved" - as we all'),
  ('Morty', '3', 13.1, 'You\'re both pieces of shit! I can prove it mathematically', 'Wubba lubba dub dub!'),
  ('Angry Rick', '3', 13.2, 'Get your shit together!', 'Just... Nothing to add ^_^'),
  ('Contemtuous Morty', '3', 13.3, 'I\'m sorry, but your opinion means very little to me', 'So just shut up.');

INSERT INTO customer (first_name, last_name, middle_name, locale, email, phone) VALUES
  ('test_customer_first_name_1', 'test_customer_last_name_1', '', 'RU', 'test@test.ru', '111111'),
  ('test_customer_first_name_2', 'test_customer_last_name_2', '', 'RU', 'test@test.ru', '222222'),
  ('test_customer_first_name_3', 'test_customer_last_name_3', 'middle_name_test_3', 'RU', 'test@test.ru', '333333');

INSERT INTO cart(creation_time, customer_id, price, description, shipping_address) VALUES
  (now(), 1, 50000, 'description_1', 'shipping_address_1'),
  (now(), 2,  50000,'description_2','shipping_address_2'),
  (now(), 2, 100000,'description_3', 'shipping_address_3'),
  (now(), 3, 100000,'description_4', 'shipping_address_4');

INSERT INTO purchase (cart_id, product_id, quantity) VALUES
  (1, 1, 10),
  (1, 4, 1),
  (1, 8, 54),
  (2, 3, 13),
  (2, 9, 12),
  (2, 4, 34),
  (3, 7, 17),
  (3, 2, 15),
  (3, 6, 10);
EOSQL
