-- 1a. Display the first and last names of all actors from the table `actor`.
USE sakila;

SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

SELECT 
CONCAT(first_name, ' ', last_name) AS 'Actor Name'

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 

FROM actor;
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = "JOE";

-- 2b. Find all actors whose last name contain the letters `GEN`
SELECT actor_id, first_name, last_name FROM actor
WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters `LI`. Order the rows by last name and first name.
SELECT actor_id, first_name, last_name FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name ASC;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id, country FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- so create a column in the table `actor` named `description` and use the data type `BLOB` 
ALTER TABLE actor
ADD description BLOB;
    
-- Delete the `description` column.        
ALTER TABLE actor
DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name
SELECT last_name, 
COUNT(last_name) FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the # of actors who have that last name, but only for names that are shared by at least two actors.
SELECT last_name,
COUNT(last_name) FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name="GROUCHO" AND last_name="WILLIAMS";

-- 4d. if the first name of the actor is currently `HARPO`, change it to `GROUCHO`
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name="HARPO" AND last_name="WILLIAMS";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`
SELECT staff.first_name, staff.last_name, address.address
FROM staff 
	JOIN address ON staff.address_id = address.address_id;

 -- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`   
SELECT first_name, last_name, SUM(amount)
FROM staff
	JOIN payment ON staff.staff_id = payment.staff_id

WHERE payment_date BETWEEN "2005-08-01" AND "2005-08-31"
GROUP BY first_name, last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT film.title, SUM(film_actor.actor_id)
FROM film 
	INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.film_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film.title, COUNT(inventory.inventory_id)
FROM film
	INNER JOIN inventory ON film.film_id = inventory.film_id
WHERE film.title = "Hunchback Impossible";

-- 6e. Using the tables `payment`,`customer`,and the `JOIN` command, list the total paid, list the customers alphabetically by last name
SELECT customer.first_name, customer.last_name, SUM(payment.amount)
FROM customer
	INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY payment.customer_id
ORDER BY customer.last_name;

-- 7a. The music of Queen (What do you mean unlikely????)and Kris Kristofferson have seen an unlikely resurgence.
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT title
FROM FILM
WHERE
    (SELECT language_id
        FROM language
        WHERE name = 'ENGLISH')
			AND (title 
					LIKE 'K%' OR title LIKE 'Q%');
        
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.       
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
    (SELECT actor_id
		FROM film_actor
		WHERE film_id IN
			(SELECT film_id
				FROM film
				WHERE title = 'Alone Trip'));
                
-- 7c. You need the names and email addresses of all Canadian customers. Use joins to retrieve this information.                
SELECT country, first_name, last_name, email 
FROM customer 
	JOIN address ON (customer.address_id = address.address_id)
	JOIN city ON (address.city_id=city.city_id)
	JOIN country ON (city.country_id=country.country_id)
WHERE country = "CANADA";

-- 7d. Identify all movies categorized as _family_ films.
SELECT title 
FROM film
	JOIN film_category ON (film.film_id = film_category.film_id)
	JOIN category ON (film_category.category_id = category.category_id)
WHERE category.name = "FAMILY";

-- 7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(film.film_id) AS num_rental
FROM film
	JOIN inventory ON (film.film_id = inventory.film_id)
	JOIN rental ON (inventory.inventory_id = rental.inventory_id)
GROUP BY title ORDER BY num_rental DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, SUM(payment.amount) 
FROM payment 
	JOIN staff ON (payment.staff_id=staff.staff_id)
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country 
FROM store 
	JOIN address ON (store.address_id=address.address_id)
	JOIN city ON (address.city_id=city.city_id)
	JOIN country ON (city.country_id=country.country_id);
    
-- 7h. List the top five genres in gross revenue in descending order.
SELECT category.name, SUM(payment.amount) 
FROM category
	JOIN film_category ON (category.category_id = film_category.category_id)
	JOIN inventory ON (film_category.film_id = inventory.film_id)
	JOIN rental ON (inventory.inventory_id = rental.inventory_id)
	JOIN payment ON (rental.rental_id=payment.rental_id)
GROUP BY category.name ORDER BY SUM(payment.amount) DESC LIMIT 5;

-- 8a. Viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_revenue_generes AS
SELECT category.name AS "Top Five", SUM(payment.amount) AS "Revenue" 
FROM category
	JOIN film_category ON (category.category_id = film_category.category_id)
	JOIN inventory ON (film_category.film_id = inventory.film_id)
	JOIN rental ON (inventory.inventory_id = rental.inventory_id)
	JOIN payment ON (rental.rental_id=payment.rental_id)
GROUP BY category.name ORDER BY SUM(payment.amount) DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * from top_five_revenue_generes;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_revenue_generes;