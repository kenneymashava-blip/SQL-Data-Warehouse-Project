/* Measures Exloration
	 Calculate the key metrics of the business (Big Numbers)

*/

-- find the total sales
SELECT SUM(sales_amount) AS total_sales
FROM gold.fact_sales

-- find how many items are sold
SELECT SUM(quantity) AS total_items_sold
FROM gold.fact_sales

-- find the average selleing price
SELECT AVG(distinct price) AS average_price
FROM gold.fact_sales

-- find the total number of orders
SELECT COUNT(distinct order_number) as total_oders
FROM gold.fact_sales

-- find the total number of products
SELECT COUNT(distinct product_id) AS total_products
FROM gold.dim_products

-- find the total number of customers
select COUNT(distinct customer_id) As total_customers
from gold.dim_customers

-- find the total number of customers that have placed an order
SELECT COUNT(distinct customer_key) AS total_customers
FROM gold.fact_sales


-- Generate a report that shows all key metrics of the business

SELECT 'Total Sales'  AS measure_name, SUM(sales_amount) AS value_measure
FROM gold.fact_sales

UNION ALL
SELECT 'Total Quantity', SUM(quantity)
FROM gold.fact_sales

UNION ALL
SELECT 'Average Price', AVG(distinct price) 
FROM gold.fact_sales

UNION ALL
SELECT 'Total Number of Orders',COUNT(distinct order_number)
FROM gold.fact_sales

UNION ALL
SELECT 'Total Number of Products',COUNT(distinct product_id)
FROM gold.dim_products

UNION ALL
SELECT 'Total Number of Customers',COUNT(distinct customer_id)
FROM gold.dim_customers


