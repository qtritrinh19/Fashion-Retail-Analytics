/*
CUSTOMER INSIGHT
*/

/*
Total Customers
*/

SELECT
	COUNT(DISTINCT o.user_id) AS Total_Customers
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
WHERE
	YEAR(o.created_at) = 2026
---Monthly
SELECT
	MONTH(o.created_at) AS monthly_c, 
	COUNT(DISTINCT o.user_id) AS Total_Customers
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
WHERE
	YEAR(o.created_at) = 2026
GROUP BY
	MONTH(o.created_at)
ORDER BY
	MONTH(o.created_at)
--- YoY %
WITH tb1 AS(
SELECT
	YEAR(o.created_at) AS yearly_c, 
	COUNT(DISTINCT o.user_id) AS Total_Customers
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
GROUP BY
	YEAR(o.created_at)
)
SELECT
	*, 
	ROUND((Total_Customers*1.0/LAG(Total_Customers) OVER(ORDER BY yearly_c)) - 1, 4) AS YoY_Growth_Customers
FROM
	tb1

/*
New Customers
*/

WITH new_c_tb AS(
SELECT
	o.user_id, 
	o.created_at,
	RANK() OVER(PARTITION BY o.user_id ORDER BY o.created_at) AS rnk
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
),
new_customers_fn As(
SELECT
	user_id, 
	created_at, 
	rnk
FROM
	new_c_tb
WHERE
	YEAR(created_at) = 2026 AND rnk = 1
)

SELECT
	COUNT(DISTINCT user_id) AS New_Customers
FROM
	new_customers_fn;


---Monthly

WITH new_c_tb AS(
SELECT
	o.user_id, 
	o.created_at,
	RANK() OVER(PARTITION BY o.user_id ORDER BY o.created_at) AS rnk
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
),
new_customers_fn As(
SELECT
	user_id, 
	created_at, 
	rnk
FROM
	new_c_tb
WHERE
	YEAR(created_at) = 2026 AND rnk = 1
)

SELECT
	MONTH(created_at) AS month_c,
	COUNT(DISTINCT user_id) AS New_Customers
FROM
	new_customers_fn
GROUP BY
	MONTH(created_at)
ORDER BY
	month_c ASC;

--- YoY % Growth

WITH new_c_tb AS(
SELECT
	o.user_id, 
	o.created_at,
	RANK() OVER(PARTITION BY o.user_id ORDER BY o.created_at) AS rnk
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
),
new_customers_fn As(
SELECT
	user_id, 
	created_at, 
	rnk
FROM
	new_c_tb
WHERE
	rnk = 1
),
yoy_tb AS(
SELECT
	YEAR(created_at) AS year_c,
	COUNT(DISTINCT user_id) AS New_Customers
FROM
	new_customers_fn
GROUP BY
	YEAR(created_at)
)

SELECT
	year_c, 
	New_Customers, 
	ROUND((New_Customers/LAG(New_Customers*1.0) OVER(ORDER BY year_c) - 1), 4) AS YoY_Growth_NewCustomers
FROM
	yoy_tb
ORDER BY
	year_c

/*
Returing Customers
*/

WITH new_c_tb AS(
SELECT
	o.user_id, 
	o.created_at,
	RANK() OVER(PARTITION BY o.user_id ORDER BY o.created_at) AS rnk
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
),
new_customers_fn As(
SELECT
	user_id, 
	created_at, 
	rnk
FROM
	new_c_tb
WHERE
	YEAR(created_at) = 2026 AND rnk = 1
), 

total_customers_fn AS(
SELECT
	user_id, 
	created_at, 
	rnk
FROM
	new_c_tb
WHERE
	YEAR(created_at) = 2026
)
SELECT
	(SELECT
		COUNT(DISTINCT user_id)
	FROM
		total_customers_fn) -
	(SELECT
		COUNT(DISTINCT user_id)
	FROM
		new_customers_fn) AS Returning_Customers;

--- Monthly

WITH new_c_tb AS(
SELECT
	o.user_id, 
	o.created_at,
	RANK() OVER(PARTITION BY o.user_id ORDER BY o.created_at) AS rnk
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
),
new_customers_fn AS(
SELECT
	user_id, 
	created_at, 
	rnk
FROM
	new_c_tb
WHERE
	YEAR(created_at) = 2026 AND rnk = 1
), 

total_customers_fn AS(
SELECT
	user_id, 
	created_at, 
	rnk
FROM
	new_c_tb
WHERE
	YEAR(created_at) = 2026
),

new_c_monthly AS(
SELECT
	MONTH(created_at) AS month_c,
	COUNT(DISTINCT user_id) AS New_Customers
FROM
	new_customers_fn
GROUP BY
	MONTH(created_at)
), 

total_c_monthly AS(
SELECT
	MONTH(created_at) AS month_c,
	COUNT(DISTINCT user_id) AS Total_Customers
FROM
	total_customers_fn
GROUP BY
	MONTH(created_at)
)

SELECT
	ncm.month_c, 
	tcm.Total_Customers - ncm.New_Customers AS Returing_Customers
FROM
	new_c_monthly ncm JOIN total_c_monthly tcm ON ncm.month_c = tcm.month_c
ORDER BY
	month_c ASC

--- YoY Growth Rate

WITH new_c_tb AS(
SELECT
	o.user_id, 
	o.created_at,
	RANK() OVER(PARTITION BY o.user_id ORDER BY o.created_at) AS rnk
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
),
new_customers_fn AS(
SELECT
	user_id, 
	created_at, 
	rnk
FROM
	new_c_tb
WHERE
	rnk = 1
), 

total_customers_fn AS(
SELECT
	user_id, 
	created_at, 
	rnk
FROM
	new_c_tb
),

new_c_yearly AS(
SELECT
	YEAR(created_at) AS year_c,
	COUNT(DISTINCT user_id) AS New_Customers
FROM
	new_customers_fn
GROUP BY
	YEAR(created_at)
), 

total_c_yearly AS(
SELECT
	YEAR(created_at) AS year_c,
	COUNT(DISTINCT user_id) AS Total_Customers
FROM
	total_customers_fn
GROUP BY
	YEAR(created_at)
),
yoy_tb AS(
SELECT
	ncm.year_c, 
	CASE
		WHEN tcm.Total_Customers - ncm.New_Customers = 0 THEN NULl
		ELSE tcm.Total_Customers - ncm.New_Customers END AS Returning_Customers
FROM
	new_c_yearly ncm JOIN total_c_yearly tcm ON ncm.year_c = tcm.year_c
)

SELECT
	year_c, 
	ROUND(Returning_Customers*1.0/LAG(Returning_Customers*1.0) OVER(ORDER BY year_c) - 1, 4) AS YoY_Growth_ReturningCustomers
FROM
	yoy_tb

/*
ACV
*/

SELECT
	(SELECT
		ROUND(SUM(p.retail_price), 2) AS Total_Revenue
	FROM
		orders o JOIN order_items ot ON o.order_id = ot.order_id
					 JOIN products p ON ot.product_id = p.id
	WHERE
		o.status LIKE 'Complete' AND YEAR(o.created_at) = 2026)/
	COUNT(DISTINCT o.user_id) AS ACV
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
WHERE
	YEAR(o.created_at) = 2026

--- Monthly
WITH revenue_tb AS(
SELECT
	MONTH(o.created_at) AS rev_month, 
	ROUND(SUM(p.retail_price), 2) AS Total_Revenue
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
WHERE
	o.status LIKE 'Complete' AND YEAR(o.created_at) = 2026
GROUP BY
	MONTH(o.created_at)
), 
customers_tb AS(
SELECT
	MONTH(o.created_at) AS cus_month,
	COUNT(DISTINCT o.user_id) AS Total_Customers
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
WHERE
	YEAR(o.created_at) = 2026
GROUP BY
	MONTH(o.created_at)
)
SELECT
	rt.rev_month AS month_acv, 
	ROUND(rt.Total_Revenue/(ct.Total_Customers*1.0), 2) AS ACV
FROM
	revenue_tb rt JOIN customers_tb ct ON rt.rev_month = ct.cus_month

--- YoY Growth Rate
WITH revenue_tb AS(
SELECT
	YEAR(o.created_at) AS rev_year, 
	ROUND(SUM(p.retail_price), 2) AS Total_Revenue
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
WHERE
	o.status LIKE 'Complete'
GROUP BY
	YEAR(o.created_at)
), 
customers_tb AS(
SELECT
	YEAR(o.created_at) AS cus_year,
	COUNT(DISTINCT o.user_id) AS Total_Customers
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
GROUP BY
	YEAR(o.created_at)
),
yoy_tb AS(
SELECT
	rt.rev_year AS year_acv, 
	ROUND(rt.Total_Revenue/(ct.Total_Customers*1.0), 2) AS ACV
FROM
	revenue_tb rt JOIN customers_tb ct ON rt.rev_year = ct.cus_year
)
SELECT
	year_acv, 
	ROUND(ACV/LAG(ACV) OVER(ORDER BY year_acv) - 1, 4) AS YoY_Growth_ACV
FROM
	yoy_tb


/*
Customer Base Growth Trends
*/

WITH new_c_tb AS(
SELECT
	o.user_id, 
	o.created_at,
	RANK() OVER(PARTITION BY o.user_id ORDER BY o.created_at) AS rnk
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
),
new_customers_fn AS(
SELECT
	user_id, 
	created_at, 
	rnk
FROM
	new_c_tb
WHERE
	rnk = 1
), 

total_customers_fn AS(
SELECT
	user_id, 
	created_at, 
	rnk
FROM
	new_c_tb
),

new_c_yearly AS(
SELECT
	YEAR(created_at) AS year_c,
	COUNT(DISTINCT user_id) AS New_Customers
FROM
	new_customers_fn
GROUP BY
	YEAR(created_at)
), 

total_c_yearly AS(
SELECT
	YEAR(created_at) AS year_c,
	COUNT(DISTINCT user_id) AS Total_Customers
FROM
	total_customers_fn
GROUP BY
	YEAR(created_at)
)

SELECT
	ncy.year_c,
	ncy.New_Customers, 
	tcy.Total_Customers - ncy.New_Customers AS Returing_Customers
FROM
	new_c_yearly ncy JOIN total_c_yearly tcy ON ncy.year_c = tcy.year_c
ORDER BY
	year_c ASC;

/*
Create RFM table for Customer Segmentation
*/
WITH tb1 AS(
SELECT
	o.user_id,
	MAX(o.created_at) OVER(PARTITION BY o.user_id) AS Last_Purchase_Date, 
	MAX(o.created_at) OVER() AS AnalysisDate, 
	ROW_NUMBER() OVER(PARTITION BY o.user_id, o.order_id ORDER BY o.order_id ASC) AS Row_order, 
	SUM(p.retail_price) OVER(PARTITION BY o.user_id) AS Total_Spend
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
WHERE
	o.status <> 'Cancelled' AND o.status <> 'Returned'
), 
RFM AS(
SELECT
	DISTINCT user_id, 
	DATEDIFF(DAY, Last_Purchase_Date, AnalysisDate) AS Recency, 
	SUM(Row_order) OVER(PARTITION BY user_id) AS Frequency, 
	ROUND(Total_Spend, 2) AS Monetary
FROM
	tb1
WHERE
	Row_order = 1
),
percentiles_r AS (
SELECT DISTINCT
	PERCENTILE_CONT(0.2)
		WITHIN GROUP (ORDER BY Recency) OVER () AS P20_r,
	PERCENTILE_CONT(0.4)
		WITHIN GROUP (ORDER BY Recency) OVER () AS P40_r,
	PERCENTILE_CONT(0.6)
		WITHIN GROUP (ORDER BY Recency) OVER () AS P60_r,
	PERCENTILE_CONT(0.8)
		WITHIN GROUP (ORDER BY Recency) OVER () AS P80_r
FROM RFM
),
percentiles_f AS (
SELECT DISTINCT
	PERCENTILE_CONT(0.2)
		WITHIN GROUP (ORDER BY Frequency) OVER () AS P20_f,
	PERCENTILE_CONT(0.4)
		WITHIN GROUP (ORDER BY Frequency) OVER () AS P40_f,
	PERCENTILE_CONT(0.6)
		WITHIN GROUP (ORDER BY Frequency) OVER () AS P60_f,
	PERCENTILE_CONT(0.8)
		WITHIN GROUP (ORDER BY Frequency) OVER () AS P80_f
FROM RFM
),
percentiles_m AS (
SELECT DISTINCT
	PERCENTILE_CONT(0.2)
		WITHIN GROUP (ORDER BY Monetary) OVER () AS P20_m,
	PERCENTILE_CONT(0.4)
		WITHIN GROUP (ORDER BY Monetary) OVER () AS P40_m,
	PERCENTILE_CONT(0.6)
		WITHIN GROUP (ORDER BY Monetary) OVER () AS P60_m,
	PERCENTILE_CONT(0.8)
		WITHIN GROUP (ORDER BY Monetary) OVER () AS P80_m
FROM RFM
), 
RFM_fn AS(
SELECT
    r.*,
	CASE
        WHEN r.Recency <= pr.P20_r THEN 5
        WHEN r.Recency <= pr.P40_r THEN 4
        WHEN r.Recency <= pr.P60_r THEN 3
        WHEN r.Recency <= pr.P80_r THEN 2
        ELSE 1
    END AS Recency_Score, 
	CASE
        WHEN r.Frequency <= pf.P20_f THEN 1
        WHEN r.Frequency <= pf.P40_f THEN 2
        WHEN r.Frequency <= pf.P60_f THEN 3
        WHEN r.Frequency <= pf.P80_f THEN 4
        ELSE 5
    END AS Frequency_Score,
    CASE
        WHEN r.Monetary <= pm.P20_m THEN 1
        WHEN r.Monetary <= pm.P40_m THEN 2
        WHEN r.Monetary <= pm.P60_m THEN 3
        WHEN r.Monetary <= pm.P80_m THEN 4
        ELSE 5
    END AS Monetary_Score
FROM RFM r
	CROSS JOIN percentiles_r pr
	CROSS JOIN percentiles_f pf
	CROSS JOIN percentiles_m pm
)
SELECT
	*,
	CASE
		WHEN Recency_Score >= 4 AND Frequency_Score >= 4 AND Monetary_Score >= 4
		THEN 'Champions'
		WHEN Recency_Score >= 3 AND Frequency_Score >= 3 AND Monetary_Score >= 3
		THEN 'Loyal'
		WHEN Recency_Score >= 3
		THEN 'Potential'
		WHEN Recency_Score = 2
		THEN 'At Risk'
		ELSE 'Lost' END AS Customer_Segmentation
INTO RFM
FROM
	RFM_fn;

/*
Customer Base Composition
*/

WITH tb1 AS(
SELECT
	o.order_id, 
	o.status, 
	o.created_at,
	o.user_id,
	rfm.Customer_Segmentation
FROM
	orders o JOIN RFM rfm ON o.user_id = rfm.user_id
WHERE
	YEAR(o.created_at) = 2026
)
SELECT
	Customer_Segmentation, 
	COUNT(DISTINCT user_id) AS Total_Customer
FROM
	tb1
GROUP BY
	Customer_Segmentation


/*
Customer Base Composition
*/
SELECT
	rfm.Customer_Segmentation, 
	ROUND(SUM(p.retail_price), 2) AS Total_Revenue
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
	JOIN products p ON ot.product_id = p.id
	JOIN RFM rfm ON rfm.user_id = o.user_id
WHERE
	o.status LIKE 'Complete' AND YEAR(o.created_at) = 2026
GROUP BY
	rfm.Customer_Segmentation

/*
Revenue Breakdown
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
)
SELECT
	p.Class,
	rfm.Customer_Segmentation, 
	ROUND(SUM(p.retail_price), 2) AS Total_Revenue
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN new_products p ON ot.product_id = p.id
				 JOIN RFM rfm ON o.user_id = rfm.user_id
WHERE
	o.status LIKE 'Complete' AND YEAR(o.created_at) = 2026
GROUP BY
	p.Class, 
	rfm.Customer_Segmentation
ORDER BY
	p.Class, 
	rfm.Customer_Segmentation;

/*
Customer Retention Trends
*/
WITH tb1 AS(
SELECT
	DISTINCT o.order_id, 
	o.user_id,  
	o.status,
	DATEFROMPARTS(YEAR(created_at), MONTH(created_at), 1) AS month_year
FROM
	orders o JOIN order_items ot ON o.order_id = ot.order_id
				 JOIN products p ON ot.product_id = p.id
WHERE
	status <> 'Cancelled' AND status <> 'Returned'
), 

tb2 AS(
SELECT
	*,
	LAG(month_year) OVER(PARTITION BY user_id ORDER BY month_year) AS prev_date
FROM
	tb1
),
tb3 AS(
SELECT
	*,
	DATEDIFF(MONTH, prev_date, month_year) AS month_diff
FROM
	tb2
WHERE
	YEAR(month_year) = 2026
), tb2_s AS(
SELECT
	month_year, 
	COUNT(DISTINCT user_id) AS Total_Customers
FROM
	tb1
GROUP BY
	month_year
), 
tb3_s AS(
SELECT
	*, 
	LAG(Total_Customers) OVER(ORDER BY month_year) AS prev_month_customers
FROM
	tb2_s
),
retained_tb AS(
SELECT
	month_year, 
	COUNT(*) AS Total_Retained
FROM
	tb3
WHERE
	month_diff = 1
GROUP BY
	month_year
), 
prev_month_customer AS(
SELECT
	month_year, 
	prev_month_customers
FROM
	tb3_s
WHERE
	YEAR(month_year) = 2026
)
SELECT
	rtb.month_year, 
	rtb.Total_Retained*1.0/pmc.prev_month_customers AS Retention_Rate
FROM
	retained_tb rtb JOIN prev_month_customer pmc ON rtb.month_year = pmc.month_year
ORDER BY
	rtb.month_year;
