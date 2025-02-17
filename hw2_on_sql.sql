
--Напишите код, который из таблицы invoice вернёт дату самой первой и самой последней покупки.
select 	
	min(invoice_date) as first_purchase
	, max(invoice_date) as last_purchase
from invoice;


--Напишите код, который вернёт размер среднего чека для покупок из США.
select 
	AVG(total) as avg_check_in_USA
from invoice	
where
	billing_country = 'USA';


--Напишите код, который вернёт список городов в которых имеется более одного клиента.
select 
	billing_city
from invoice
where  
	customer_id > 1 ;

--Из таблицы customer вытащите список телефонных номеров, не содержащих скобок;
select *
from customer
where 
	phone not like '%(%'
	and phone not like '%)%';


--Измените текст 'lorem ipsum' так чтобы только первая буква первого слова была в верхнем регистре а всё остальное в нижнем;
select 
	concat
	(UPPER(LEFT('lorem ipsum', 1)),
    LOWER(SUBSTRING('lorem ipsum', 2))) as  result;


--Из таблицы track вытащите список названий песен, которые содежат слово 'run';
select *
from track
where
	name like '%run%';


--Вытащите список клиентов с почтовым ящиком в 'gmail';
select *
from customer
where 
	email like '%gmail%';


--Из таблицы track найдите произведение с самым длинным названием.
select *
from track
order by length(name) desc
limit 1;


--Посчитайте общую сумму продаж за 2021 год, в разбивке по месяцам. Итоговая таблица должна содержать следующие поля: month_id, sales_sum
select 
	extract(month from invoice_date) as month_id
	, sum(total) as sales_sum
from invoice 
where
	extract(year from invoice_date) =2021
group by extract (month from invoice_date)	
order by month_id;

/*К предыдущему запросу (вопрос №6) добавьте также поле с названием месяца (для этого функции to_char в качестве второго аргумента нужно передать слово 'month'). 
Итоговая таблица должна содержать следующие поля: month_id, month_name, sales_sum. Результат должен быть отсортирован по номеру месяца.*/
select 
	extract(month from "invoice_date") as month_id
	, trim(to_char("invoice_date", 'month')) as month_name
	, sum("total") as sales_sum
from invoice 
where
	extract(year from "invoice_date") =2021
group by 
	extract (month from "invoice_date")
	, trim(to_char("invoice_date", 'month'))
order by month_id;


--

/*Вытащите список 3 самых возрастных сотрудников компании. 
Итоговая таблица должна содержать следующие поля: full_name (имя и фамилия), birth_date, age_now (возраст в годах в числовом формате)*/
select 
	concat(first_name, ' ', last_name) as full_name
	, birth_date 
	, extract(year from age(birth_date)) as age_now
from employee
order by age(birth_date) desc
limit 3;


--Посчитайте каков будет средний возраст сотрудников через 3 года и 4 месяца.
select 
	avg(extract(year from age((current_date + interval '3 years 4 months'), birth_date)))
from employee;


/*Посчитайте сумму продаж в разбивке по годам и странам. Оставьте только те строки где сумма продажи больше 20. 
Результат отсортируйте по году продажи (по возрастанию) и сумме продажи (по убыванию).*/
select 
	extract(year from "invoice_date") as sale_year
	, "billing_country" as country
	, sum ("total") as sales_sum
from invoice
group by sale_year, billing_country
having sum ("total") >20
order by sale_year asc, sales_sum desc;



