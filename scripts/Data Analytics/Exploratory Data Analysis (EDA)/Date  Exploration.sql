/*-- Date Exploration 

	    Identify the earliest and latest dates (Date boundaries)
		understand the scop of datat and time span.
*/


-- Find the date of the first and last order.
-- How many years of sales are available
-- How many months of sales are available

SELECT MIN(order_date) AS first_order_date,
	   MAX(order_date) AS last_order_date,
	   DATEDIFF(YEAR,MIN(order_date),MAX(order_date)) AS order_range_years,
	   DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS order_range_months
FROM gold.fact_sales


-- find the yongest and the oldest customer

SELECT MAX(birthdate) AS youngest_customer, 
	   DATEDIFF(YEAR,MAX(birthdate),GETDATE()) AS youngest_age,
	   MIN(birthdate) AS lodest_customer,
	   DATEDIFF(YEAR,MIN(birthdate),GETDATE()) AS oldest_age
FROM gold.dim_customers