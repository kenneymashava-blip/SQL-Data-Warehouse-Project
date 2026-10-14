-- Trends and Changes Overtime

SELECT  YEAR(order_date) AS order_year,
		MONTH(order_date) AS order_month,
		SUM(sales_amount) AS total_sales,
		COUNT(DISTINCT customer_key) AS total_customers,
		COUNT(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date is not null
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date),MONTH(order_date)


-- similarly using datetrunc function

SELECT  DATETRUNC(YEAR,order_date) AS order_date,
		DATETRUNC(MONTH,order_date) AS order_month,
		SUM(sales_amount) AS total_sales,
		COUNT(DISTINCT customer_key) AS total_customers,
		COUNT(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date is not null
GROUP BY DATETRUNC(YEAR,order_date),DATETRUNC(MONTH,order_date)
ORDER BY DATETRUNC(YEAR,order_date),DATETRUNC(MONTH,order_date)


-- similarly using the date format function

SELECT  FORMAT(order_date,'yyyy-MMM') AS order_date,
		SUM(sales_amount) AS total_sales,
		COUNT(DISTINCT customer_key) AS total_customers,
		COUNT(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date is not null
GROUP BY FORMAT(order_date,'yyyy-MMM')
ORDER BY FORMAT(order_date,'yyyy-MMM')
