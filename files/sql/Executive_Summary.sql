/*
EXECUTIVE SUMMARY
*/

/*
KPIs
*/
SELECT
	(SELECT
		ROUND(SUM(p.retail_price), 2) 
	FROM
		orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
	WHERE
		o.status LIKE 'Complete') AS Sales_Revenue, 

	(SELECT
		COUNT(DISTINCT order_id)
	FROM
		orders) AS Total_Orders, 

	(SELECT
		(SELECT
			ROUND(SUM(p.retail_price), 2) AS sales_revenue
		FROM
			orders o JOIN order_items ot ON o.order_id = ot.order_id
					 JOIN products p ON ot.product_id = p.id
		WHERE
			o.status LIKE 'Complete') / 
		(SELECT
			COUNT(DISTINCT order_id)
		FROM
			orders
		WHERE
			status LIKE 'Complete')) AS AOV,
			
	(SELECT
		ROUND(SUM(p.retail_price - p.cost), 2)
	FROM	
		orders o JOIN order_items ot ON o.order_id = ot.order_id
				JOIN products p ON ot.product_id = p.id
	WHERE
		o.status LIKE 'Complete') AS Profit



/*
YoY KPIs Growth
*/

WITH sales_revenue AS(
SELECT
	YEAR(created_at) AS order_year, 
	ROUND(SUM(p.retail_price), 2) AS Sales_Revenue, 
	COUNT(DISTINCT o.order_id) AS complete_order, 
	ROUND(SUM(p.retail_price - p.cost), 2) AS Profit
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
			 JOIN products p ON ot.product_id = p.id
WHERE
	o.status LIKE 'Complete'
GROUP BY
	YEAR(created_at)
),
total_orders AS
(SELECT
	YEAR(created_at) AS order_year, 
	COUNT(DISTINCT o.order_id) AS Total_Orders
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
			 JOIN products p ON ot.product_id = p.id
GROUP BY
	YEAR(created_at)
),
final_tb AS
(SELECT
	t.order_year, 
	s.Sales_Revenue, 
	t.Total_Orders,
	ROUND(s.Sales_Revenue / (s.complete_order*1.0), 2) AS AOV, 
	s.Profit
FROM
	sales_revenue s RIGHT JOIN total_orders t ON s.order_year = t.order_year
)

SELECT
	order_year, 
	Sales_Revenue, 
	ROUND((Sales_Revenue/LAG(Sales_Revenue) OVER(ORDER BY order_year ASC)) - 1, 4) AS YoY_Growth_Revenue, 
	Total_Orders, 
	CAST(ROUND(((Total_Orders*1.0)/LAG(Total_Orders*1.0) OVER(ORDER BY order_year ASC)) - 1, 4) AS DECIMAL(10, 4)) AS YoY_Growth_Order, 
	AOV, 
	ROUND((AOV/LAG(AOV) OVER(ORDER BY order_year ASC)) - 1, 4) AS YoY_Growth_AOV, 
	Profit, 
	ROUND((Profit/LAG(Profit) OVER(ORDER BY order_year ASC)) - 1, 4) AS YoY_Growth_Profit
FROM
	final_tb

/*
KPIs by time
*/

WITH sales_revenue AS(
SELECT
	MONTH(created_at) AS order_month,
	YEAR(created_at) AS order_year, 
	ROUND(SUM(p.retail_price), 2) AS Sales_Revenue, 
	COUNT(DISTINCT o.order_id) AS complete_order,
	ROUND(SUM(p.retail_price - p.cost), 2) AS Profit
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
			 JOIN products p ON ot.product_id = p.id
WHERE
	o.status LIKE 'Complete'
GROUP BY
	MONTH(created_at), 
	YEAR(created_at)
),
total_orders AS
(SELECT
	MONTH(created_at) AS order_month,
	YEAR(created_at) AS order_year, 
	COUNT(DISTINCT o.order_id) AS Total_Orders
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
			 JOIN products p ON ot.product_id = p.id
GROUP BY
	MONTH(created_at), 
	YEAR(created_at)
)

SELECT
	t.order_month, 
	t.order_year, 
	s.Sales_Revenue, 
	t.Total_Orders,
	ROUND(s.Sales_Revenue / (s.complete_order*1.0), 2) AS AOV, 
	s.Profit
FROM
	sales_revenue s RIGHT JOIN total_orders t ON s.order_year = t.order_year
										AND s.order_month = t.order_month
WHERE
	t.order_year = 2026
ORDER BY
	order_year ASC, 
	order_month ASC;


/*
Top 5 Categories by Revenue
*/
SELECT
	TOP 5
	p.category, 
	ROUND(SUM(p.retail_price), 2) AS Sales_Revenue
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
WHERE
	o.status LIKE 'Complete' AND YEAR(o.created_at) = 2026
GROUP BY
	p.category
ORDER BY
	Sales_Revenue DESC

/*
Top 5 Brands by Revenue
*/

SELECT
	TOP 5
	p.brand, 
	ROUND(SUM(p.retail_price), 2) AS Sales_Revenue
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
WHERE
	o.status LIKE 'Complete' AND YEAR(o.created_at) = 2026
GROUP BY
	p.brand
ORDER BY
	Sales_Revenue DESC

/*
Revenue and Profit Trend
*/

WITH sales_revenue AS(
SELECT
	YEAR(created_at) AS order_year, 
	ROUND(SUM(p.retail_price), 2) AS Sales_Revenue, 
	ROUND(SUM(p.retail_price - p.cost), 2) AS Profit
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
			 JOIN products p ON ot.product_id = p.id
WHERE
	o.status LIKE 'Complete'
GROUP BY
	MONTH(created_at), 
	YEAR(created_at)
)

SELECT
	order_year, 
	SUM(Sales_Revenue) AS Total_Revenue, 
	SUM(Profit) AS Total_Profit
FROM
	sales_revenue
GROUP BY
	order_year
ORDER BY
	order_year ASC

/*
Revenue by Country
*/

SELECT
	u.country, 
	ROUND(SUM(p.retail_price), 2) AS Sales_Revenue
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
				 JOIN users u ON o.user_id = u.id
WHERE
	o.status LIKE 'Complete' AND YEAR(o.created_at) = 2026
GROUP BY
	u.country
ORDER BY
	Sales_Revenue DESC