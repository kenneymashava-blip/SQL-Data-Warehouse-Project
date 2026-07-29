/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DDL Script: Create Gold Layer Views
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Script Purpose:
	To create the views for the gold layer in the data warehouse.
	The gold layer consists of two 'dimension views'  and one 'fact view'.

	Dimension Views:   gold.dim_customers  and gold.dim_products
	Fact Views:        gold.sales_fact
	
	The purpose of each view:
			transform and join tables from the silver layer to produce
			the final: cleaned, enriched and bussiness ready dataset.
Usage:
	These views may be querried directly for data analytics and reporting.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Create Dimension: gold.dim_customers
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key, -- surrogate key creation
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,

	CASE  WHEN ci.cst_gndr IN ('Female', 'Male') THEN ci.cst_gndr
		  ELSE COALESCE(ca.gen,'n/a') 
	END AS gender,

	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
	
	
FROM silver.crm_cust_info AS ci

LEFT JOIN silver.erp_cust_az12 AS ca
ON		  ci.cst_key = ca.cid 

LEFT JOIN silver.erp_loc_a101 AS la
ON		  ci.cst_key = la.cid 

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Create Dimension: gold.dim_products
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
GO
IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
	DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY cpi.prd_start_dt, cpi.prd_key) AS product_key, -- Surrogate key
	cpi.prd_id		AS product_id, 
	cpi.prd_key		AS product_number,
	cpi.prd_nm		AS product_name,
	cpi.cat_id		As category_id,
	pc.cat			As category,
	pc.subcat		AS subcategory,
	pc.maintenance,
	cpi.prd_cost		As cost,
	cpi.prd_line		As product_line,
	cpi.prd_start_dt	AS start_date

FROM silver.crm_prd_info AS cpi

LEFT JOIN silver.erp_cat_g1v2 AS pc
ON		cpi.cat_id = pc.id

WHERE prd_end_dt IS NULL -- Filter Out All Historical Data

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Create Dimension: gold.fact_sales
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
GO
IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num AS order_number, 
	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details AS sd

LEFT JOIN gold.dim_products AS pr
ON  sd.sls_prd_key = pr.product_number

LEFT JOIN gold.dim_customers AS cu
ON sd.sls_cust_id = cu.customer_id

