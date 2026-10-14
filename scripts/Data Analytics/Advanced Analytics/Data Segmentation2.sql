-- Group Data based on specific range


-- Segment products into cost ranges and 
-- count how many products fall into each segment

WITH Cost_Range AS
(
SELECT product_key,
	   product_name,
	   CASE 
			WHEN cost <100 THEN 'Below 100'
			WHEN cost BETWEEN 100 AND 500 THEN '100-500'
			WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
			WHEN cost BETWEEN 1000 AND 1500 THEN '1000-1500'
	        ELSE 'Above 1500'
       END AS cost_range
FROM gold.dim_products
)
SELECT cost_range,
	   COUNT(cost_range) AS total_range_products
FROM Cost_Range
GROUP BY cost_range
ORDER BY COUNT(cost_range) DESC