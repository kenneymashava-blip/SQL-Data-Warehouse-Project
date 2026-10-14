/*
-----------------------------------------------------------------
Product Report
-----------------------------------------------------------------
Purpose: 
	- This report consolidates key product metrics and behaviours

Highlights: 
	1. Gathers essential fields such as:
		- product key
		- product name
		- category
		- subcategory 
		- cost

	2. Aggregates product level metrics such as:
		- total orders
		- totals sales
		- total quantity sold
		- total customers (Unique)
		- lifespan (in months)

	3. Segments products by revenue to identify High-Perfomers, Mid-Range and Low-Perfomers
	4. Calculates valuable KPI's such as:
		- Recency (months since last sale)
		- Average Order Revenue (AOR)
		- Average Monthly Revenue
-----------------------------------------------------------------
*/
IF OBJECT_ID('gold.report_products','V') IS NOT NULL
	DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS 

WITH base_query AS 
( -- 1. Base Query: Gather essential fields from the fact and dimension tables
	SELECT	   
			   f.order_number,
			   f.order_date,
			   f.customer_key,
			   f.sales_amount,
			   f.quantity,
			   p.product_key,
			   p.product_name,
			   p.category,
			   p.subcategory,
			   p.cost
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
	ON p.product_key = f.product_key
	WHERE f.order_date IS NOT NULL 
)
,
product_aggregations AS 
(
-- 2. Aggregates product level metric
SELECT product_key,
	   product_name,
	   category,
	   subcategory,
	   COUNT(DISTINCT order_number) AS total_orders,
	   MAX(order_date) AS last_order_date,
	   COUNT( DISTINCT customer_key) AS total_customers,
	   SUM(sales_amount) AS total_sales,
	   SUM(quantity) AS quantity_sold,
	   DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan,
	   SUM(cost) AS total_cost,
	   AVG(sales_amount/NULLIF(quantity,0)) AS avg_sale_price
FROM base_query
GROUP BY product_key,
	     product_name,
	     category,
	     subcategory
)
SELECT product_key,
	   product_name,
	   category,
	   subcategory,
       last_order_date,
	   total_orders,
	   total_customers,
	   quantity_sold,
	   total_sales,
	   -- Segments products by revenue
	   CASE WHEN total_sales<10000 THEN 'Low-Perfomer'
			WHEN total_sales BETWEEN 10000 AND 50000 THEN 'Mid-Perfomer'
			ELSE 'High-Perfomer'
	   END AS product_segment,
	   total_cost,
	   avg_sale_price,
	   lifespan,
	   -- KPI: Recency (months since last order)
	   DATEDIFF(MONTH,last_order_date,GETDATE()) AS recency,
	   -- KPI: Average Order Revenue
	   CASE WHEN total_orders = 0 THEN 0
			ELSE total_sales/total_orders
	   END AS avg_order_rev,
		-- KPI: Average Monthly Revenue
	   CASE WHEN lifespan = 0 THEN total_sales
			ELSE total_sales/lifespan
	   END AS avg_monthly_rev
		
FROM product_aggregations