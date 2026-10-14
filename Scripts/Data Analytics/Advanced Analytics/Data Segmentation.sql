-- Group Customers into three segments based on thier spending behavior:
--   VIP:       Atleast 12 months of history and spending more than 5000
--   Regular:   Atleast 12 months but spending 5000 or less.
--   New:		lifespan less than 12 months
--   Count the number of customers in each segment



WITH customer_spending AS (
	SELECT 
		   dc.customer_key,
		   SUM(fs.sales_amount) AS total_spending,
		   MIN(fs.order_date) AS first_order,
		   MAX(fs.order_date) AS last_order, 
		   DATEDIFF(MONTH,MIN(fs.order_date),MAX(fs.order_date)) AS lifespan
	FROM gold.fact_sales AS fs
	LEFT JOIN gold.dim_customers dc
	ON dc.customer_key = fs.customer_key
	GROUP BY dc.customer_key )

SELECT 
	    customer_segment,
		COUNT(customer_key) AS total_customers ,
	    SUM(total_spending) AS total_spending
	  
FROM (
SELECT  customer_key,
		total_spending,
		lifespan,
		CASE WHEN total_spending>5000 AND lifespan>=12 THEN 'VIP'
			 WHEN  total_spending<=5000 AND lifespan>=12 THEN 'Regular'
			 ELSE 'NEW'
		END AS customer_segment
FROM customer_spending ) AS t
GROUP BY customer_segment
ORDER BY SUM(total_spending) DESC
