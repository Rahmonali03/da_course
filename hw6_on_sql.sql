/*Задача №1
1.Для каждого клиента посчитайте сумму продаж по годам и месяцам. Итоговая таблица должна содержать следующие поля: customer_id, full_name, monthkey (в числовом формате), total.
2.Дополните получившуюся таблицу, посчитав для каждого клиента какой процент от общих продаж за каждый месяц он принёс. Т.е. если например в феврале 2023-го общая сумма продаж всем клиентам составила 100, а сумма продаж клиенту Х составила 15, тогда процент расчитывается как 15/100.
3.Дополните таблицу, посчитав для каждого клиента нарастающий итог за каждый год.
4.Дополните таблицу, добавив для каждого клиента скользящее среднее за 3 последних периода (2 предыдущих периода и текущий период).
5.Дополните таблицу, посчитав для каждого клиента разницу между суммой текущего периода и суммой предыдущего периода.
 */
--1.
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    EXTRACT(YEAR FROM i.invoice_date) * 100 + EXTRACT(MONTH FROM i.invoice_date) AS monthkey,
    SUM(il.unit_price * il.quantity) AS total
FROM customer c, invoice i, invoice_line il
WHERE c.customer_id = i.customer_id 
AND i.invoice_id = il.invoice_id
GROUP BY c.customer_id, full_name, monthkey;

--2
WITH monthly_sales AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS full_name,
        EXTRACT(YEAR FROM i.invoice_date) * 100 + EXTRACT(MONTH FROM i.invoice_date) AS monthkey,
        SUM(il.unit_price * il.quantity) AS total
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    GROUP BY c.customer_id, full_name, monthkey
)
SELECT
    customer_id,
    full_name,
    monthkey,
    total,
    ROUND(
        (total * 100.0 / SUM(total) OVER (PARTITION BY monthkey)),2) AS month_percent
FROM monthly_sales
ORDER BY customer_id, monthkey;
---3 и 4
WITH monthly_sales AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS full_name,
        EXTRACT(YEAR FROM i.invoice_date) * 100 + EXTRACT(MONTH FROM i.invoice_date) AS monthkey,
        SUM(il.unit_price * il.quantity) AS total
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    GROUP BY c.customer_id, full_name, monthkey
),
with_monthly_percent AS (
    SELECT *,
        ROUND(
            total * 100.0 / SUM(total) OVER (PARTITION BY monthkey),
            2
        ) AS month_percent
    FROM monthly_sales
),
with_running_total AS (
    SELECT *,
        SUM(total) OVER (
            PARTITION BY customer_id, FLOOR(monthkey / 100)
            ORDER BY monthkey
        ) AS running_total
    FROM with_monthly_percent
),
with_moving_avg AS ( -- Теперь with_running_total объявлена до этого CTE
    SELECT *,
        ROUND(
            AVG(total) OVER (
                PARTITION BY customer_id
                ORDER BY monthkey
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ), 2
        ) AS moving_avg_period
    FROM with_running_total -- Ссылка на корректно объявленную CTE
)
SELECT 
    customer_id,
    full_name,
    monthkey,
    total,
    month_percent,
    running_total,
    moving_avg_period
FROM with_moving_avg
ORDER BY customer_id, monthkey;
--5.
WITH 
monthly_sales AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS full_name,
        EXTRACT(YEAR FROM i.invoice_date) * 100 + EXTRACT(MONTH FROM i.invoice_date) AS monthkey,
        SUM(il.unit_price * il.quantity) AS total
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    GROUP BY c.customer_id, full_name, monthkey
),
with_running_total AS (
    SELECT *,
        SUM(total) OVER (
            PARTITION BY customer_id, FLOOR(monthkey / 100)
            ORDER BY monthkey
        ) AS running_total
    FROM monthly_sales
),
with_moving_avg AS ( 
    SELECT *,
        ROUND(
            AVG(total) OVER (
                PARTITION BY customer_id
                ORDER BY monthkey
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ), 2
        ) AS moving_avg_3period
    FROM with_running_total
)
SELECT *,
    total - LAG(total, 1) OVER (
        PARTITION BY customer_id
        ORDER BY monthkey
    ) AS prev_month_diff
FROM with_moving_avg 
ORDER BY customer_id, monthkey;


/*Задача №2
Верните топ 3 продаваемых альбома за каждый год. Итоговая таблица должна содержать следующие поля: год, название альбома, имя исполнителя, количество проданных треков.
 */
WITH album_sales AS (
    SELECT
        EXTRACT(YEAR FROM i.invoice_date) AS year,
        a.album_id,
        a.title AS album_title,
        ar.name AS artist_name,
        COUNT(il.track_id) AS tracks_sold
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN album a ON t.album_id = a.album_id
    JOIN artist ar ON a.artist_id = ar.artist_id
    GROUP BY year, a.album_id, a.title, ar.name
),
ranked_albums AS ( 
    SELECT
        year,
        album_title,
        artist_name,
        tracks_sold,
        RANK() OVER (
            PARTITION BY year 
            ORDER BY tracks_sold DESC
        ) AS sales_rank
    FROM album_sales
)
SELECT
    year,
    album_title,
    artist_name,
    tracks_sold
FROM ranked_albums  
WHERE sales_rank <= 3
ORDER BY year DESC, sales_rank;

/* Задача №3
1.Посчитайте количество клиентов, закреплённых за каждым сотрудником. Итоговая таблица должна содержать следующие поля: id сотрудника, полное имя, количество клиентов
2.К предыдущему запросу добавьте поле, показывающее какой процент от общей клиентской базы обслуживает каждый сотрудник.*/
WITH employee_clients AS (
    SELECT
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name) AS full_name,
        COUNT(c.customer_id) AS client_count
    FROM employee e
    LEFT JOIN customer c ON e.employee_id = c.support_rep_id
    GROUP BY e.employee_id, e.first_name, e.last_name
)
SELECT
    employee_id,
    full_name,
    client_count,
    ROUND(
        (client_count * 100.0 / SUM(client_count) OVER ()), -- Добавлена закрывающая скобка
        2
    ) AS client_percent
FROM employee_clients
ORDER BY client_count DESC;

/* Задача №4
Для каждого клиента определите дату первой и последней покупки. Посчитайте разницу в годах между первой и последней покупкой.*/
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    MIN(i.invoice_date) AS first_purchase_date,
    MAX(i.invoice_date) AS last_purchase_date,
    EXTRACT(YEAR FROM AGE(MAX(i.invoice_date), MIN(i.invoice_date))) AS years_diff
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY c.customer_id;