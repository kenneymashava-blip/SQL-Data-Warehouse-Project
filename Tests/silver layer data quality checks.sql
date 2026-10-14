/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Nulls and duplicates in the primary keys.
    - Unwanted spaces in string columns.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after executing the Silver Layer loading procedure.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================

-- Check for Nulls and Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    cst_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) !=1 OR cst_id IS NULL;

-- Unwanted Spaces Check in the String Columns
-- Expectation: No Results
SELECT 
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key)
     OR cst_firstname!=TRIM(cst_firstname)
     OR cst_lastname !=TRIM(cst_lastname)
     OR cst_marital_status!=TRIM(cst_marital_status)
     OR cst_gndr != TRIM(cst_gndr);

-- Data Standardization & Consistency
SELECT DISTINCT 
    cst_marital_status,cst_gndr
FROM silver.crm_cust_info;


-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================

-- Check for Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    prd_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces in String Columns
-- Expectation: No Results
SELECT 
     cat_id,
     prd_key,
     prd_nm,
     prd_line
FROM silver.crm_prd_info
WHERE cat_id != TRIM(cat_id)
   OR prd_key != TRIM(prd_key)
   OR prd_nm != TRIM(prd_nm)
   OR prd_line != TRIM(prd_line);

-- Check for Nulls and Negative Values in Cost
-- Expectation: No Results
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT 
    prd_start_dt,
    prd_end_dt
FROM silver.crm_prd_info
WHERE  prd_start_dt>prd_end_dt;



-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================

-- Check for Unwanted Spaces in String Columns
-- Expectation: No Results
SELECT 
	  sls_ord_num,sls_prd_key	
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)
   OR sls_prd_key != TRIM(sls_prd_key)


-- Check for Invalid Dates (date>2050-01-01 or Date<1900-01-01)
-- Expectation: No Invalid Dates
SELECT 
     sls_order_dt,
     sls_ship_dt,
     sls_due_dt
FROM silver.crm_sales_details
WHERE 
       sls_order_dt > CAST(CAST(20500101 AS char(8)) AS DATE)
    OR sls_order_dt < CAST(CAST(19000101 AS char(8)) AS DATE)
    OR sls_ship_dt  > CAST(CAST(20500101 AS char(8)) AS DATE)
    OR sls_ship_dt  < CAST(CAST(19000101 AS char(8)) AS DATE)
    OR sls_due_dt   > CAST(CAST(20500101 AS char(8)) AS DATE)
    OR sls_due_dt   < CAST(CAST(19000101 AS char(8)) AS DATE);


-- Check for Invalid Dates (Order Date > Shipping Date > Due Dates)
-- Expectation: No Results
SELECT 
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt
   OR sls_ship_dt > sls_due_dt

-- Check for Nulls and Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0


-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================

-- Identify Out-of-Range Birth-Dates (Between 1916-01-01 and Today)
-- Expectation: No results 
SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1916-01-01' 
   OR bdate > GETDATE();

-- Data Standardization & Consistency
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;


-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================

-- Data Standardization & Consistency
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;


-- ================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ================================================================

-- Check for Unwanted Spaces in the String Columns
-- Expectation: No Results

SELECT 
    cat,
    subcat,
    maintenance 
FROM silver.erp_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);


-- Data Standardization & Consistency
SELECT DISTINCT 
    maintenance 
FROM silver.erp_cat_g1v2;

-- Data Standardization & Consistency
SELECT DISTINCT 
    cat 
FROM silver.erp_cat_g1v2;

-- Data Standardization & Consistency
SELECT DISTINCT 
    subcat 
FROM silver.erp_cat_g1v2;

