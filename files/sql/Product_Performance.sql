/*
PRODUCT PERFORMANCE
*/

/*
Total Products, Categories and Brands
*/

SELECT
	YEAR(o.created_at) AS order_year,
	COUNT(DISTINCT p.id) AS Total_Products, 
	COUNT(DISTINCT p.category) AS Total_Categories, 
	COUNT(DISTINCT p.brand) AS Total_Brands
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
GROUP BY
	YEAR(o.created_at)
ORDER BY
	order_year ASC

/*
Category Performance
*/
WITH Revenue_Product AS(
SELECT
	p.category, 
	ROUND(SUM(p.retail_price), 2) AS Total_Revenue
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
	JOIN products p ON ot.product_id = p.id
WHERE
	o.status LIKE 'Complete' AND YEAR(o.created_at) = 2026
GROUP BY
	p.category
),

Orders_Product AS(
SELECT
	p.category, 
	COUNT(DISTINCT o.order_id) AS Total_Orders
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
	JOIN products p ON ot.product_id = p.id
WHERE
	YEAR(o.created_at) = 2026
GROUP BY
	p.category
)

SELECT
	r.category, 
	r.Total_Revenue, 
	o.Total_Orders
FROM
	Revenue_Product r JOIN Orders_Product o ON r.category = o.category
ORDER BY
	Total_Revenue DESC, 
	Total_Orders DESC

/*
Top 5 Categories with Highest Return Quantity
*/

SELECT TOP 5
	p.category, 
	COUNT(ot.product_id) AS returned_quantity
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
	JOIN products p ON ot.product_id = p.id
WHERE
	o.status LIKE 'Returned' AND YEAR(o.created_at) = 2026
GROUP BY
	p.category
ORDER BY
	returned_quantity DESC

/*
Top 5 Categories by Unsold Inventory Value
*/


SELECT TOP 5
	p.category, 
    SUM(p.cost) AS Total_Cost
FROM
    inventory_items it 
    JOIN products p ON it.product_id = p.id
WHERE
    it.sold_at IS NULL AND YEAR(it.created_at) = 2026
GROUP BY
    p.category
ORDER BY
    Total_Cost DESC;

/*
Top Brand Performance
*/
WITH revenue_profit AS(
SELECT
	p.brand AS Brand, 
	ROUND(SUM(p.retail_price), 2) AS Total_Revenue, 
	ROUND(SUM(p.retail_price - p.cost), 2) AS Total_Profit 
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
WHERE
	o.status LIKE 'Complete' AND YEAR(o.created_at) = 2026
GROUP BY
	p.brand
),

orders_p AS(
SELECT
	p.brand, 
	COUNT(DISTINCT o.order_id) AS Total_Orders
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
WHERE
	YEAR(o.created_at) = 2026
GROUP BY
	p.brand
)

SELECT TOP 10
	rp.Brand, 
	rp.Total_Revenue, 
	rp.Total_Profit, 
	op.Total_Orders
FROM
	revenue_profit rp JOIN orders_p op ON rp.Brand = op.brand
ORDER BY
	rp.Total_Profit DESC;


/*
Class Performance
*/
WITH new_products AS(
SELECT
	*, 
	CASE
		WHEN retail_price < 50 THEN 'Budget'
		WHEN retail_price < 150 THEN 'Mid-range'
		ELSE 'Premium' END AS Class
FROM
	products
),
revenue_class AS(
SELECT
	p.Class, 
	ROUND(SUM(p.retail_price), 2) AS Total_Revenue
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN new_products p ON ot.product_id = p.id
WHERE
	o.status LIKE 'Complete' AND YEAR(o.created_at) = 2026
GROUP BY
	p.Class
),
orders_class AS(
SELECT
	p.Class, 
	COUNT(DISTINCT o.order_id) AS Total_Orders
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN new_products p ON ot.product_id = p.id
WHERE
	YEAR(o.created_at) = 2026
GROUP BY
	p.Class
)

SELECT
	rc.Class, 
	rc.Total_Revenue, 
	oc.Total_Orders
FROM
	revenue_class rc JOIN orders_class oc ON rc.Class = oc.Class

/*
Revenue Share by Department
*/

SELECT
	p.department, 
	ROUND(SUM(p.retail_price), 2) AS Total_Revenue
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
WHERE
	o.status LIKE 'Complete' AND YEAR(o.created_at) = 2026
GROUP BY
	p.department