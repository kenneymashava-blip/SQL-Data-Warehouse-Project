/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
	3. Segments customers into categories (VIP, Regular, New) and age groups.
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

WITH base_query AS 
( -- Base Query: retrieves core columns from the tables
	SELECT f.order_number,
		   f.product_key,
		   f.order_date,
		   f.sales_amount,
		   f.quantity,
		   c.customer_key,
		   c.customer_number,
		   CONCAT(c.first_name,' ',c.last_name) AS customer_name,
		   DATEDIFF(YEAR,c.birthdate,GETDATE()) AS age
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_customers AS c
	ON f.customer_key = c.customer_key
	WHERE f.order_date IS NOT NULL
)
,
customer_aggregation AS
(  -- Customer Aggregations: summarizes key metrics at customer level
	SELECT customer_key,
		   customer_number,
		   customer_name,
		   age,
		   COUNT(DISTINCT order_number) AS total_orders,
		   SUM(sales_amount) AS total_sales,
		   SUM(quantity) AS total_quantity,
		   COUNT(DISTINCT product_key) AS total_products,
		   MAX(order_date) AS last_order,
		   DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS life_span
	FROM base_query
	GROUP BY customer_key,
			 customer_number,
			 customer_name,
			 age
)
SELECT 
	  customer_key,
      customer_number,
	  customer_name,
	  age,
	  -- Segments customers ages
	  -- customer ages were ranging from 40 to 110 years old
	  CASE WHEN age<40 THEN 'Under 40'
		   WHEN age BETWEEN 40 AND 49 THEN '40-49'
		   WHEN age BETWEEN 50 AND 59 THEN '50-59'
		   WHEN age BETWEEN 60 AND 69 THEN '60-69'
		   WHEN age BETWEEN 70 AND 79 THEN '70-79'
		   ELSE '80 and Above'
	  END AS age_group,
	  -- Segments customers into categories (VIP,Regular,New)
	  CASE WHEN total_sales>5000 AND life_span>=12 THEN 'VIP'
		   WHEN  total_sales<=5000 AND life_span>=12 THEN 'Regular'
		   ELSE 'NEW'
	  END AS customer_segment,
	  total_orders,
	  total_sales,
	  total_quantity,
	  total_products,
	  last_order,
	  -- KPI: recency (months since last order)
	  DATEDIFF(MONTH,last_order,GETDATE()) AS recency,
	  life_span,
	  -- KPI: compute average order value (AOV)
	  CASE WHEN total_orders = 0 THEN 0 -- avoid devision by zero
		   ELSE total_sales/total_orders
	  END AS avg_order_value,
	  -- KPI: compute average monthly spend (AMS)
	  CASE WHEN life_span = 0 THEN total_sales
		   ELSE total_sales/life_span
	  END AS avg_monthly_spend
FROM customer_aggregation