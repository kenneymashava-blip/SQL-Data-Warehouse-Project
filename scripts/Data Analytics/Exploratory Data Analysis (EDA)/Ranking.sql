-- Ranking 
-- Order the values of dimensions by measure
-- Top N perfomers| Bottom N perfomers


-- Which 5 products generate the highest revenue

select top 5 product_key,
		sum(sales_amount) AS total_sales
from gold.fact_sales
group by product_key
order by sum(sales_amount) desc

-- similarly

SELECT TOP 5 p.product_key,p.product_name,
	   SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales as f

LEFT JOIN gold.dim_products as p
ON p.product_key = f.product_key

GROUP BY p.product_key,p.product_name
ORDER BY SUM(f.sales_amount) DESC

-- What are the 5 worst-perfoming products in terms of sales

SELECT TOP 5 p.product_key,p.product_name,
	   SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales as f

LEFT JOIN gold.dim_products as p
ON p.product_key = f.product_key

GROUP BY p.product_key,p.product_name
ORDER BY SUM(f.sales_amount) 

-- Simarly with Subquery
--    Which 5 products generate the highest revenue

SELECT     product_name,
	       total_sales,
           top_sales
FROM
(
SELECT p.product_key,p.product_name,
	   SUM(f.sales_amount) AS total_sales,
	   ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC ) AS top_sales
FROM gold.fact_sales as f

LEFT JOIN gold.dim_products as p
ON p.product_key = f.product_key

GROUP BY p.product_key,p.product_name
) t
WHERE top_sales<6


-- Similarly with Common Table Expression
--   Which 5 products generate the highest revenue

WITH cte AS 
(
SELECT p.product_key,p.product_name,
	   SUM(f.sales_amount) AS total_sales,
	   ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC ) AS top_sales
FROM gold.fact_sales as f

LEFT JOIN gold.dim_products as p
ON p.product_key = f.product_key

GROUP BY p.product_key,p.product_name
)
SELECT        product_key,
			  product_name,
	          total_sales,
              top_sales
FROM cte
WHERE top_sales<=5


-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10	c.customer_key,
				c.first_name,
				c.last_name,
				SUM(f.sales_amount) AS total_sales
		
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key

GROUP BY c.customer_key, c.first_name,c.last_name
ORDER BY SUM(f.sales_amount) DESC

-- Similarly 
-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10	c.customer_key,
				c.first_name,
				c.last_name,
				SUM(f.sales_amount) AS total_sales,
				RANK() OVER( ORDER BY SUM(f.sales_amount) DESC) AS sales_rank
		
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name,c.last_name



-- Find the 3 customers who have generated the lowest revenue

SELECT TOP 3	c.customer_key,
				c.first_name,
				c.last_name,
				SUM(f.sales_amount) AS total_sales
		
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key

GROUP BY c.customer_key, c.first_name,c.last_name
ORDER BY SUM(f.sales_amount) 

-- Similarly 
-- Find the 3 customers who have generated the lowest revenue
SELECT TOP 3	c.customer_key,
				c.first_name,
				c.last_name,
				SUM(f.sales_amount) AS total_sales,
				RANK() OVER( ORDER BY SUM(f.sales_amount) ) AS sales_rank
		
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name,c.last_name
