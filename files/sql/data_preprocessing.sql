/*
Check whether product's cost or retail price changes over time or 
across orders in order_items and inventory_items table
*/

SELECT
	*
FROM
(SELECT
	product_id, 
	sale_price,
	DENSE_RANK() OVER(PARTITION BY product_id ORDER BY sale_price DESC) AS rank
FROM
	order_items) AS tb1
WHERE
	rank > 1;

SELECT
	*
FROM
(SELECT
	*, 
	DENSE_RANK() OVER(PARTITION BY product_id ORDER BY cost DESC) AS rank_cost, 
	DENSE_RANK() OVER(PARTITION BY product_id ORDER BY product_retail_price DESC) AS rank_retail_price
FROM
	inventory_items) AS tb1
WHERE
	rank_cost > 1 OR rank_retail_price > 1;

/*
Drop redundant columns in order_items table
*/

ALTER TABLE order_items
DROP COLUMN user_id, status, created_at, shipped_at, delivered_at, returned_at, sale_price;

/*
Drop redundant columns in orders table
*/

ALTER TABLE orders
DROP COLUMN gender, num_of_item;

/*
Drop redundant columns in orders table
*/

ALTER TABLE orders
DROP COLUMN gender, num_of_item;

/*
Drop redundant columns in inventory_items table
*/

ALTER TABLE inventory_items
DROP COLUMN cost, 
			product_category, 
			product_name, 
			product_brand, 
			product_retail_price, 
			product_department, 
			product_sku, 
			product_distribution_center_id;

/*
Convert all date columns back to Date format in orders table
*/

UPDATE orders
SET 
    delivered_at = LEFT(delivered_at, 10),
    shipped_at = LEFT(shipped_at, 10),
    created_at = LEFT(created_at, 10),
	returned_at = LEFT(returned_at, 10);

ALTER TABLE orders
ALTER COLUMN delivered_at DATE;

ALTER TABLE orders
ALTER COLUMN shipped_at DATE;

ALTER TABLE orders
ALTER COLUMN created_at DATE;

ALTER TABLE orders
ALTER COLUMN returned_at DATE;

/*
Convert all date columns back to Date format in inventory_items table
*/

UPDATE inventory_items
SET 
    created_at = LEFT(created_at, 10), 
	sold_at = LEFT(sold_at, 10);

ALTER TABLE inventory_items
ALTER COLUMN created_at DATE;

ALTER TABLE inventory_items
ALTER COLUMN sold_at DATE;

/*
Convert date column back to Date format in users table
*/

UPDATE users
SET 
    created_at = LEFT(created_at, 10);

ALTER TABLE users
ALTER COLUMN created_at DATE;

/*
Convert date column back to Date format in events table
*/

UPDATE events
SET 
    created_at = LEFT(created_at, 10);

ALTER TABLE events
ALTER COLUMN created_at DATE;