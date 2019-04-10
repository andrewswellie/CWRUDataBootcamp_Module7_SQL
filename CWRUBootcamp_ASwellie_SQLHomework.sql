# Set the database as Sakila and turn off safe updates
USE sakila;
SET SQL_SAFE_UPDATES=0;

#  1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM sakila.actor;

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
ALTER TABLE actor ADD Full_Name VARCHAR(50);
UPDATE actor SET Full_Name = CONCAT(UPPER(first_name),' ',UPPER(last_name));

# 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT * FROM actor
WHERE first_name LIKE ("JOE%");

# 2b. Find all actors whose last name contain the letters `GEN`:
SELECT * FROM actor
WHERE last_name LIKE ("%GEN%");

# 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM actor
WHERE last_name LIKE ("%LI%");

# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country 
FROM country
WHERE country IN('Afghanistan', 'Bangladesh', 'China');

# 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data 
# type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER table actor ADD column description BLOB;

# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;

# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT DISTINCT last_name, COUNT(last_name) FROM actor
GROUP BY last_name;

# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT DISTINCT last_name, COUNT(last_name) AS count 
FROM actor
GROUP BY last_name
HAVING count > 2

# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor 
SET Full_Name = 'HARPO WILLIAMS', first_name = 'HARPO' 
WHERE Full_Name = 'GROUCHO WILLIAMS';

# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor 
SET Full_Name = 'GROUCHO WILLIAMS', first_name = 'GROUCHO' 
WHERE first_name = 'HARPO';

# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address

# Opened the value of "Create Table" in the character viewer and copied this code out so the table would be exactly the same as the original  
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address, address.address_id
FROM staff
LEFT JOIN address ON staff.address_id = address.address_id;

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT staff.first_name, staff.last_name, payment.payment_date, payment.amount
FROM staff
LEFT JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment.payment_date like ('2005-08%');

# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT film.title, (SELECT count(*) 
FROM film_actor 
WHERE film_actor.film_id = film.film_id) AS number_of_actors
FROM film;

# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film.title, count(inventory.film_id) as number_of_copies
FROM film
LEFT JOIN inventory ON film.film_id = inventory.film_id
WHERE title = "Hunchback Impossible"

# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS "Total Amount Paid"
FROM payment
INNER JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY payment.customer_id
ORDER BY customer.last_name ASC;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
# Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
	SELECT title 
	FROM film 
	WHERE language_id IN(
		SELECT language_id
	    FROM language 
	    WHERE name = 'English') 
	AND (title LIKE 'K%') OR  (title LIKE 'Q%');

# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT * 
FROM actor
WHERE actor_id IN(
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN(
		SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'
));

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email
FROM customer
LEFT JOIN address ON customer.address_id = address.address_id
LEFT JOIN city ON address.city_id = city.city_id 
LEFT JOIN country ON city.country_id = country.country_id
WHERE country.country = 'Canada';

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT title, description, name
FROM film
LEFT JOIN film_category ON film.film_id = film_category.film_id
LEFT JOIN category ON film_category.category_id = category.category_id
WHERE name = 'Family'; 

# 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental.rental_id) AS total_rentals
FROM film
LEFT JOIN inventory ON film.film_id = inventory.film_id
LEFT JOIN rental ON rental.inventory_id = inventory.inventory_id
GROUP BY film.film_id
ORDER BY COUNT(rental_id) DESC;

# 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM sales_by_store 

# 7g. Write a query to display for each store its store ID, city, and country.
SELECT SID, city, country
FROM staff_list

# 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name, SUM(payment.amount) AS gross_revenue 
FROM filmsales_by_film_category
LEFT JOIN film_category ON film_category.film_id = film.film_id
LEFT JOIN category ON film_category.category_id = category.category_id
LEFT JOIN inventory ON inventory.film_id = film.film_id
LEFT JOIN rental ON rental.inventory_id = inventory.inventory_id
LEFT JOIN payment ON payment.rental_id = rental.rental_id 
WHERE payment.amount IS NOT NULL 
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC
LIMIT 5

# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
# If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS (
	SELECT category.name, SUM(payment.amount) AS gross_revenue 
	FROM film
	LEFT JOIN film_category ON film_category.film_id = film.film_id
	LEFT JOIN category ON film_category.category_id = category.category_id
	LEFT JOIN inventory ON inventory.film_id = film.film_id
	LEFT JOIN rental ON rental.inventory_id = inventory.inventory_id
	LEFT JOIN payment ON payment.rental_id = rental.rental_id 
	WHERE payment.amount IS NOT NULL 
	GROUP BY category.name
	ORDER BY SUM(payment.amount) DESC
	LIMIT 5);
    
# 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres

# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres