USE sakila;

# 1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(*)
FROM inventory i
JOIN film f ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';

# 2. List all films whose length is longer than the average of all the films.
SELECT title, length
FROM film
WHERE length > (
    SELECT AVG(length)
    FROM film
)
ORDER BY length DESC;

# 3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name 
FROM actor 
WHERE actor_id IN 
  (SELECT actor_id 
   FROM film_actor
   WHERE film_id = 
     (SELECT film_id 
      FROM film 
      WHERE title = 'Alone Trip')
  );

# 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id IN (
  SELECT film_id 
  FROM film_category 
  WHERE category_id = (
    SELECT category_id 
    FROM category 
    WHERE name = 'Family'
  )
);

# 5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
SELECT first_name, last_name, email 
FROM customer 
WHERE address_id IN (
  SELECT address_id 
  FROM address 
  WHERE city_id IN (
    SELECT city_id 
    FROM city 
    WHERE country_id IN (
      SELECT country_id 
      FROM country 
      WHERE country = 'Canada'
    )
  )
);

# now with joins
SELECT c.first_name, c.last_name, c.email 
FROM customer c
JOIN address a ON c.address_id = a.address_id 
JOIN city ci ON a.city_id = ci.city_id 
JOIN country co ON ci.country_id = co.country_id 
WHERE co.country = 'Canada';

# 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT 
  f.title 
FROM 
  film f 
  JOIN film_actor fa ON f.film_id = fa.film_id 
  JOIN (
    SELECT 
      a.actor_id 
    FROM 
      actor a 
      JOIN film_actor fa ON a.actor_id = fa.actor_id 
    GROUP BY 
      a.actor_id 
    ORDER BY 
      COUNT(*) DESC 
    LIMIT 1
  ) AS ap ON ap.actor_id = fa.actor_id;


# 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
SELECT 
  film.title 
FROM 
  film 
  JOIN inventory ON film.film_id = inventory.film_id 
  JOIN rental ON inventory.inventory_id = rental.inventory_id 
  JOIN (
    SELECT 
      customer.customer_id 
    FROM 
      customer 
      JOIN payment ON customer.customer_id = payment.customer_id 
    GROUP BY 
      customer.customer_id 
    ORDER BY 
      SUM(payment.amount) DESC 
    LIMIT 1
  ) AS most_profitable_customer ON rental.customer_id = most_profitable_customer.customer_id;


# 8. Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
SELECT 
  customer_id, 
  SUM(amount) AS total_amount_spent 
FROM 
  payment 
GROUP BY 
  customer_id 
HAVING 
  SUM(amount) > (
    SELECT 
      AVG(total_amount_spent) 
    FROM 
      (
        SELECT 
          customer_id, 
          SUM(amount) AS total_amount_spent 
        FROM 
          payment 
        GROUP BY 
          customer_id
      ) AS subquery
  );
