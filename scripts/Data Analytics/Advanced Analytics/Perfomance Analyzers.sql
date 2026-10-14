/* Comparing current value to the target value.
   Helps to Measure success and compare perfomance
       current - target
	   current sales - average sales
	   current year sales - previous year sales YoY Analysis
       current sales - minimum/maximum
*/


--  Analyze the yearly perfomance of products by comparing each product's sales
--  to both its average sales peformance and the previous years's sales. 


WITH yearly_product_sales AS (
  SELECT	YEAR(sa.order_date) AS order_year,
			sa.product_key,
			pr.product_name,
			SUM(sa.sales_amount) AS current_sales
FROM gold.fact_sales AS sa
LEFT JOIN gold.dim_products AS pr
ON sa.product_key = pr.product_key

WHERE order_date IS NOT NULL
GROUP BY YEAR(sa.order_date), sa.product_key, pr.product_name
)
SELECT order_year,
	   product_key,
	   product_name,
	   current_sales,
	   AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
	   current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
	   CASE
			WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above_Avg'
			WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN  'Below_Avg'
	   ELSE 'Avg' END AS avg_change,

	   -- year over year Analyser  (yoy)
	   LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS py_sales,
	   current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_py,
	   CASE
			WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
			WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN  'Decrease'
	   ELSE 'No Change' END AS py_change
FROM yearly_product_sales



-- similarly month over month anayser (mom)


