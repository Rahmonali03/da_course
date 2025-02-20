create schema store;


set search_path to store;

create table customers(
 	customer_id serial primary key
 	, customer_name varchar(50) not null
 	, email varchar(260)
 	, address text
 	, product serial
 );
insert into store.customers (customer_id, customer_name, email, address)
select 
    customer_id, 
    first_name || ' ' || last_name as customer_name, 
    email, 
    country || ' ' || coalesce(state, '') || ' ' || city || ' ' || address as address
from customer;
create table products (
    product_id serial primary key
    , product_name varchar(100)
    , price decimal not null 
);
insert into products (product_name, price) values
    ('Ноутбук Lenovo Thinkpad', 12000),
    ('Мышь для компьютера, беспроводная', 90),
    ('Подставка для ноутбука', 300),
    ('Шнур электрический для ПК', 160);
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    sale_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO sales (customer_id, product_id, quantity) VALUES
    (3, 4, 1 ),
    (56, 2, 3 ),
    (11, 2, 1 ),
    (31, 2, 1),
    (24, 2, 3),
    (27, 2, 1),
    (37, 3, 2),
    (35, 1, 2),
    (21, 1, 2),
    (31, 2, 2),
    (15, 1, 1),
    (29, 2, 1),
    (12, 2, 1);
ALTER TABLE sales ADD COLUMN discount DECIMAL;
UPDATE sales
SET discount = 0.2
WHERE product_id = 1;

CREATE VIEW v_usa_customers AS
SELECT * FROM customers WHERE address LIKE '%USA%';





