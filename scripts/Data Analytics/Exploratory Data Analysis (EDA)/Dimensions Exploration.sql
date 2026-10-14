/* Dimensions Exploration 

	Identify the unique values(or categories) in each dimension.
	Recorgnize how data might be grouped or segmented.
*/   
SELECT *
FROM gold.dim_customers

SELECT distinct country
FROM gold.dim_customers

SELECT *
FROM gold.dim_products

SELECT DISTINCT category,subcategory,product_name
FROM gold.dim_products
ORDER BY 1,2,3

SELECT DISTINCT category,subcategory,product_name
FROM gold.dim_products
WHERE category = 'components'
ORDER BY 1,2,3

