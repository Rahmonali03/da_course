/*По каждому сотруднику компании предоставьте следующую информацию: 
id сотрудника, полное имя, позиция (title), id менеджера (reports_to), 
полное имя менеджера и через запятую его позиция*/
select 
	e.employee_id as "id_сотрудника"
	, concat(e.first_name,' ', e.last_name ) as full_name
	, e.title as "Позици"
	, e.reports_to as "id_менеджера"
	, concat(e.first_name, ' ', e.last_name, ' ', e.title) as "менеджер ( имя, позиция)"
from employee e
	left join employee  m 
		on e.reports_to = e.employee_id;


/*Вытащите список чеков, сумма которых была больше среднего чека за 2023 год. 
Итоговая таблица должна содержать следующие поля: 
invoice_id, invoice_date, monthkey (цифровой код состоящий из года и месяца), customer_id, total */

select 
	i.invoice_id
	, i.invoice_date
	, extract('year' from i.invoice_date)*100 + extract('month' from i.invoice_date) as "monthkey"
	, i.customer_id
	, i.total
from invoice i
where
	i.invoice_date >= '2023-01-01'
	and i.invoice_date < '2024-01-01'
	and i.total > (
		select avg(total)
			from invoice
			where 
				invoice_date >= '2023-01-01'
				and invoice_date < '2024-01-01');


/*Дополните предыдущую информацию email-ом клиента.
 */
select 
	i.invoice_id
	, i.invoice_date
	, extract('year' from i.invoice_date)*100 + extract('month' from i.invoice_date) as "monthkey"
	, i.customer_id
	, c.email
	, i.total
from invoice i
join customer c on i.customer_id = c.customer_id
where
	i.invoice_date >= '2023-01-01'
	and i.invoice_date < '2024-01-01'
	and i.total > (
		select avg(total)
			from invoice
			where 
				invoice_date >= '2023-01-01'
				and invoice_date < '2024-01-01');


/*Отфильтруйте результирующий запрос, чтобы в нём не было клиентов имеющих почтовый ящик в домене gmail.
*/
select 
	i.invoice_id
	, i.invoice_date
	, extract('year' from i.invoice_date)*100 + extract('month' from i.invoice_date) as "monthkey"
	, i.customer_id
	, c.email
	, i.total
from invoice i
join customer c on i.customer_id = c.customer_id
where
	i.invoice_date >= '2023-01-01'
	and i.invoice_date < '2024-01-01'
	and i.total > (
		select avg(total)
			from invoice
			where 
				invoice_date >= '2023-01-01'
				and invoice_date < '2024-01-01')
	and c.email not like '%gmail.com%';

/*Посчитайте какой процент от общей выручки за 2024 год принёс каждый чек.*/
with total_revenue as (
	select
		sum(total) as total_rev
	from invoice 
	where 
		invoice_date >= '2024-01-01'
		and invoice_date < '2025-01-01')
select 
	i.invoice_id
	, i.invoice_date
	, i.total
	, (i.total / tr.total_rev * 100) as percentage_0f_revenue
from invoice i
cross join total_revenue tr
where 
	i.invoice_date >= '2024-01-01'
		and i.invoice_date < '2025-01-01';
/*Посчитайте какой процент от общей выручки за 2024 год принёс каждый клиент компании.
 */	

WITH total_revenue_2024 AS (
    SELECT SUM(total) AS total
    FROM invoice
    WHERE EXTRACT(YEAR FROM invoice_date) = 2024
)
SELECT
    customer_id,
    SUM(total) AS customer_total,
    ROUND((SUM(total) / (SELECT total FROM total_revenue_2024) * 100), 2) AS revenue_percent
FROM invoice
WHERE EXTRACT(YEAR FROM invoice_date) = 2024
GROUP BY customer_id;




