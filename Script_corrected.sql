/* 1. Вывести количество фильмов в каждой категории, отсортировать по убыванию. */

SELECT name, sum(film_id) AS films_amount
FROM category
JOIN film_category USING (category_id)
GROUP BY name
ORDER BY films_amount DESC;


/* 2. Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию. */

SELECT concat(first_name, ' ', last_name) AS name, count(rental_id) AS rental_count
FROM actor a 
JOIN film_actor fa USING (actor_id)
JOIN inventory i USING (film_id)
JOIN rental r USING (inventory_id)
GROUP BY actor_id
ORDER BY rental_count DESC 
LIMIT 10;


/* 3. Вывести категорию фильмов, на которую потратили больше всего денег. */

SELECT name, sum(amount) AS sum_amount
FROM payment p  
JOIN rental r USING (rental_id)
JOIN inventory i USING (inventory_id)
JOIN film_category fc USING (film_id)
JOIN category USING (category_id)
GROUP BY name
ORDER BY sum_amount DESC
LIMIT 1;


/* 4. Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN. 
Вариант 1 */

SELECT title
FROM film
LEFT JOIN inventory i USING (film_id)
WHERE store_id IS NULL;


/* Вариант 2 */

SELECT title
FROM film f
LEFT JOIN inventory i USING (film_id)
WHERE i.film_id IS NULL;


/* 5. Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. Если у нескольких актеров одинаковое кол-во фильмов, вывести всех. */

WITH top_count AS (
	SELECT concat(first_name, ' ', last_name) AS actor_name, count(film_id) AS film_count
	FROM actor
	JOIN film_actor fa USING (actor_id)
	JOIN film_category USING (film_id)
	JOIN category USING (category_id)
	WHERE name = 'Children'
	GROUP BY actor_name 
	ORDER BY film_count DESC	
	LIMIT 3
),

	top_actors AS (
	SELECT concat(first_name, ' ', last_name) AS actor_name, count(film_id) AS film_count
	FROM actor
	JOIN film_actor fa USING (actor_id)
	JOIN film_category USING (film_id)
	JOIN category USING (category_id)
	WHERE name = 'Children' 
	GROUP BY actor_name 
	ORDER BY film_count DESC 
)

SELECT top_actors.actor_name, top_actors.film_count
FROM top_actors
JOIN top_count USING (film_count);


/* 6. Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). Отсортировать по количеству неактивных клиентов по убыванию. */

WITH active_customers AS (
SELECT city, count(customer_id) AS active_count
	FROM customer
	LEFT JOIN address USING (address_id)
	JOIN city USING (city_id)
	WHERE active = 1
	GROUP BY city
),
passive_customers AS (
	SELECT city, count(customer_id) AS passive_count
	FROM customer
	LEFT JOIN address USING (address_id)
	JOIN city USING (city_id)
	WHERE active = 0
	GROUP BY city
)
SELECT city, COALESCE (active_count, 0) AS active_count, COALESCE (passive_count, 0) AS passive_count
FROM active_customers
FULL JOIN passive_customers USING (city)
ORDER BY passive_count DESC;


/* 7. Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах 
 (customer.address_id в этом city), и которые начинаются на букву “a”. 
 То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе. */

WITH help_table AS(
SELECT rental_id, city, name, (return_date::timestamp - rental_date::timestamp) AS rental_time
FROM category
JOIN film_category fc USING (category_id)
JOIN inventory i USING (film_id)
JOIN rental r USING (inventory_id)
JOIN customer c USING (customer_id)
JOIN address a USING (address_id)
JOIN city c2 USING (city_id)
)
(SELECT name, SUM(rental_time) AS total_rental_time
FROM help_table
WHERE city LIKE 'a%'
GROUP BY name
ORDER BY total_rental_time DESC
LIMIT 1)

UNION ALL

(SELECT name, SUM(rental_time) AS total_rental_time
FROM help_table
WHERE city LIKE '%-%'
GROUP BY name
ORDER BY total_rental_time DESC
LIMIT 1)



