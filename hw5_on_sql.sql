/* 1. Посчитайте количество клиентов, закреплённых за каждым сотрудником 
 (подсказка: в таблице customer есть поле support_rep_id, которое хранит employee_id сотрудника, за которым закреплён клиент). 
 Итоговая таблица должна содержать следующие поля: id сотрудника, полное имя, количество клиентов.
2. Добавьте к получившейся таблице поле, показывающее какой процент от общей клиентской базы обслуживает каждый сотрудник.*/
--1.
select 
    e.employee_id AS id
    , concat(e.first_name, ' ', e.last_name) as full_name
    , (select 
    	count(*) from customer c 
    		where c.support_rep_id = e.employee_id) AS client_count
from  employee e;
--2.
WITH total_clients AS (
    SELECT COUNT(*) AS total FROM customer)
select 
    e.employee_id AS id
    , concat(e.first_name, ' ', e.last_name) as full_name
    , (select 
    	count(*) from customer c 
    		where c.support_rep_id = e.employee_id) AS client_count
    , round((select
    			count(*) from customer c
    				where c.support_rep_id = e.employee_id) *100 /
    					(select total 
    						from total_clients), 2) as client_percent
from  employee e;
    
    
    
   /* Верните список альбомов, треки из которых вообще не продавались. 
   Итоговая таблица должна содержать следующие поля: название альбома, имя исполнителя.*/
SELECT 
    a.title AS album_title,
    ar.name AS artist_name
FROM album a
INNER JOIN artist ar ON a.artist_id = ar.artist_id
WHERE NOT EXISTS (
    SELECT 1
    FROM track t
    INNER JOIN invoice_line il ON t.track_id = il.track_id
    WHERE t.album_id = a.album_id
); 

/* Выведите список сотрудников у которых нет подчинённых.*/
SELECT 
    employee_id AS id,
    CONCAT(first_name, ' ', last_name) AS full_name
FROM employee
WHERE employee_id NOT IN (
    SELECT DISTINCT reports_to 
    FROM employee
    WHERE reports_to IS NOT NULL
);

/* Верните список треков, которые продавались как в США так и в Канаде. 
 Итоговая таблица должна содержать следующие поля: id трека, название трека.*/

SELECT
    t.track_id AS "id трека",
    t.name AS "название трека"
FROM track t
JOIN invoice_line il ON t.track_id = il.track_id
JOIN invoice i ON il.invoice_id = i.invoice_id
WHERE i.billing_country IN ('USA', 'Canada')
GROUP BY t.track_id
HAVING COUNT(DISTINCT i.billing_country) = 2;


/* Верните список треков, которые продавались в Канаде, но не продавались в США. 
 Итоговая таблица должна содержать следующие поля: id трека, название трека.
*/

SELECT
    t.track_id AS "id трека",
    t.name AS "название трека"
FROM track t
JOIN invoice_line il ON t.track_id = il.track_id
JOIN invoice i ON il.invoice_id = i.invoice_id
GROUP BY t.track_id
HAVING 
    SUM(CASE WHEN i.billing_country = 'Canada' THEN 1 ELSE 0 END) >= 1
    AND SUM(CASE WHEN i.billing_country = 'USA' THEN 1 ELSE 0 END) = 0;