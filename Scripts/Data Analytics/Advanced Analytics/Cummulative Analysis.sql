-- Cummulative Analysis:
--     calculate products yearly total revenue and yearly average price
--     cummulatively track total revenue and average price over the years 

WITH sales_summary AS 
(
SELECT  YEAR(order_date) AS order_year,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
)
SELECT 
       order_year,
       total_sales,
       SUM(total_sales) OVER(ORDER BY order_year) AS running_total_sales,
       avg_price,
       AVG(avg_price)OVER(ORDER BY order_year) AS moving_avg_price
FROM sales_summary
