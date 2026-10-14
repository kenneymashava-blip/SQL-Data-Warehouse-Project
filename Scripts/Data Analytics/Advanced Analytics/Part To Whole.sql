-- Which category contribute the most to the overall sales ?


WITH cte AS 
(
SELECT
	   dp.category,
	   SUM(fs.sales_amount) AS total_sales 
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON dp.product_key = fs.product_key

GROUP BY dp.category
)
SELECT category,
	   total_sales,
	   SUM(total_sales)OVER() AS overall_sales,
	   CONCAT(ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales)OVER())*100,2),'%') AS perc_sales

FROM cte
ORDER BY total_sales DESC


--  breakdown sales of the most dorminant category into  its subcategories ?

WITH bikes_category AS 
(
SELECT
	   dp.category,
	   dp.subcategory,
	   SUM(fs.sales_amount) AS total_sales 
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON dp.product_key = fs.product_key

WHERE dp.category = 'Bikes'
GROUP BY dp.category, dp.subcategory
)
SELECT
		category,
		subcategory,
		total_sales,
		SUM(total_sales)OVER() AS overall_sales,
		CONCAT(ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales)OVER())*100,2),'%') AS perc_sales

FROM bikes_category
ORDER BY total_sales DESC