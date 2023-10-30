USE sakila;

-- Write SQL queries to perform the following tasks using the Sakila database:

-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system:

-- 1.1 Solution with JOIN:

SELECT COUNT(*) AS Hunchback_Impossible_copies
FROM inventory i
JOIN film f
USING (film_id)
WHERE f.title =  'Hunchback Impossible';

-- 1.2 Solution with Subquery:

SELECT COUNT(*) AS Hunchback_Impossible_copies
FROM inventory
WHERE film_id = (
  SELECT film_id
  FROM film
  WHERE title = 'Hunchback Impossible'
);

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database:

SELECT title, length
FROM film
WHERE length > (
  SELECT AVG(length)
  FROM film
);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip":

SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa
ON a.actor_id = fa.actor_id
WHERE fa.film_id = (
  SELECT film_id
  FROM film
  WHERE title = 'Alone Trip'
);

-- BONUS:

-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films:

SELECT f.title
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON fc.category_id = c.category_id
WHERE c.name = 'Family';

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys:

-- 5.1 Subquery:

SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
  SELECT address_id
  FROM address
  WHERE city_id IN (
    SELECT city_id
    FROM city
    WHERE country_id = (
      SELECT country_id
      FROM country
      WHERE country = 'Canada'
    )
  )
);

-- 5.2 JOIN:

SELECT c.first_name, c.last_name, c.email
FROM customer c
JOIN address a
USING (address_id)
JOIN city ci
USING (city_id)
JOIN country co
USING (country_id)
WHERE co.country = 'Canada';

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in:

-- 6.1 Solution 1:

-- Finding the most prolific actor:

SELECT fa.actor_id, a.first_name, a.last_name, COUNT(*) AS film_count
FROM film_actor fa
JOIN actor a
USING (actor_id)
GROUP BY actor_id
ORDER BY film_count DESC
LIMIT 1;

-- Once we know the actor_id, we apply it as follows:

SELECT f.title, a.first_name, a.last_name
FROM film f
JOIN film_actor fa 
USING (film_id)
JOIN actor a
USING (actor_id)
WHERE fa.actor_id = (107);

-- 6.2 Solution 2 (all together):

SELECT f.title, a.first_name, a.last_name
FROM film f
JOIN film_actor 
USING(film_id)
JOIN actor a 
USING (actor_id)
WHERE film_actor.actor_id = ( 
	SELECT actor_id
    FROM (
		SELECT actor_id, COUNT(*) AS film_count
		FROM film_actor
		GROUP BY actor_id
		ORDER BY film_count DESC
		LIMIT 1
	) AS most_prolific_act
);

-- 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

-- 7.1 Solution 1:

-- Finding the most profitable customer:

SELECT p.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_amount_paid
FROM payment p
JOIN customer c
USING (customer_id)
GROUP BY customer_id
ORDER BY total_amount_paid DESC
LIMIT 1;

-- Once we know the most profitable customer, we apply it as follows:

SELECT f.title
FROM film f
JOIN inventory i 
USING (film_id)
JOIN rental r 
USING (inventory_id)
WHERE r.customer_id = (526);

-- 7.2 Solution 2 (all together):

SELECT f.title, c.first_name, c.last_name
FROM film f
JOIN inventory i 
USING (film_id)
JOIN rental r 
USING (inventory_id)
JOIN customer c
USING (customer_id)
WHERE c.customer_id = (
  SELECT customer_id
  FROM payment
  GROUP BY customer_id
  ORDER BY SUM(amount) DESC
  LIMIT 1
);

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this:

SELECT customer_id, c.first_name, c.last_name, total_amount_spent
FROM (
  SELECT customer_id, SUM(amount) AS total_amount_spent
  FROM payment
  GROUP BY customer_id
) AS customer_payments
JOIN customer c
USING (customer_id)
WHERE total_amount_spent > (
  SELECT AVG(total_amount_spent)
  FROM (
    SELECT customer_id, SUM(amount) AS total_amount_spent
    FROM payment
    GROUP BY customer_id
  ) AS avg_payments
  
);



