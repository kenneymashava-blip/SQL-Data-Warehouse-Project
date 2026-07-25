/*
************************************************************
Stored Procedure: Load Silver Layer (Bronze -> Silver)
************************************************************
Script Purpose: 
    This procedure performs the ETL (Extract Transform & Load) process
    to insert data into the 'silver' schema tables, using the data from 
    the 'bronze' schema tables.

Actions Perfomed:
    - Truncate silver tables.
    - Transformed and cleaned data from the bronze tables.
    - insert the cleaned and transformed data into the silver tables.

parameters: None
          This procedure does not accept any parameters nor return any values.

Usage Example: 
    EXEC silver.load_silver_layer

*/

CREATE OR ALTER PROCEDURE silver.load_silver_layer AS
BEGIN
	
	DECLARE @start_time DATETIME,
			@end_time DATETIME,
			@layer_start_time DATETIME,
			@layer_end_time DATETIME;
	
	BEGIN TRY
	
	SET @layer_start_time = GETDATE();
	PRINT('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
	PRINT('LOADING THE SILVER LAYER');
	PRINT('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
	
	PRINT('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
	PRINT('LOADING CRM TABLES');
	PRINT('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
	PRINT('-------------------------------------------------------');

	SET @start_time = GETDATE();

	PRINT '<<<<< Truncating: silver.crm_cust_info';
	TRUNCATE TABLE silver.crm_cust_info;
	PRINT '>>>>> Inserting Data into: silver.crm_cust_info';

	INSERT INTO silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date )

	SELECT 
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Maried'
			 ELSE 'n\a'
		END AS cst_marital_status,

		CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			 ELSE 'n\a'
		END AS cst_gndr,
		cst_create_date
	FROM
	(
	SELECT *,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS Flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
	) AS cte
	WHERE Flag_last =1;
	
	SET @end_time = GETDATE();
	PRINT('..... loading duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' Seconds');
	PRINT('--------------------------------------------------------');
	


	SET @start_time = GETDATE();

	PRINT '<<<<< Truncating: silver.crm_sales_details';
	TRUNCATE TABLE silver.crm_sales_details;
	PRINT '>>>>> Inserting Data into: silver.crm_sales_details'

	INSERT INTO silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price )
	SELECT
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE
			WHEN sls_order_dt = 0 OR LEN(sls_order_dt)!=8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS NVARCHAR) AS DATE)
		END AS sls_order_dt,

		CASE
			WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt)!=8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS NVARCHAR) AS DATE)
		END AS sls_ship_dt,

		CASE
			WHEN sls_due_dt = 0 OR LEN(sls_due_dt)!=8 THEN NULL
			ELSE CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE)
		END AS sls_due_dt,

		CASE WHEN sls_sales<=0 
				  OR sls_sales IS NULL 
				  OR sls_sales != sls_quantity*ABS(sls_price)
				  THEN sls_quantity*ABS(sls_price)
				  ELSE sls_sales
		END AS sls_sales,
		sls_quantity,

		CASE WHEN sls_price IS NULL OR sls_price = 0 THEN sls_sales/NULLIF(sls_quantity,0)
			 WHEN sls_price < 0 THEN ABS(sls_price)
			 ELSE sls_price
		END AS sls_price
	FROM bronze.crm_sales_details ;

	SET @end_time = GETDATE();
	PRINT '....loading duration: ' +CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' Seconds';
	PRINT('--------------------------------------------------------');


	SET @start_time = GETDATE();

	PRINT '<<<<< Truncating: silver.crm_prd_info';
	TRUNCATE TABLE silver.crm_prd_info;
	PRINT '>>>>> Inserting Data into: silver.crm_prd_info';

	INSERT INTO silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt )
	SELECT
		prd_id,
		REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
		SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
		prd_nm,
		ISNULL(prd_cost,0) AS prd_cost,
		CASE UPPER(TRIM(prd_line))
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Raod'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END AS prd_line,
		CAST(prd_start_dt AS date) AS prd_start_dt,
		CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt ASC)-1 AS date ) AS prd_end_dt
	FROM bronze.crm_prd_info;

	SET @end_time = GETDATE();
	PRINT '....loading duration: ' +CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' Seconds';
	PRINT('--------------------------------------------------------');


	PRINT('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
	PRINT('LOADING ERP TABLES');
	PRINT('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
	PRINT('-------------------------------------------------------');


	SET @start_time = GETDATE();

	PRINT '<<<<< Truncating:silver.erp_cust_az12 ';
	TRUNCATE TABLE silver.erp_cust_az12;
	PRINT '>>>>> Inserting Data into: silver.erp_cust_az12'

	INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen )
	SELECT 
			CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
				 ELSE CID
			END AS cid,

			CASE WHEN BDATE>GETDATE() THEN NULL
				ELSE BDATE
			END AS bdate,
		
			CASE WHEN LOWER(TRIM(GEN)) IN ('f','female') THEN 'Female'
				 WHEN LOWER(TRIM(GEN)) IN ('m','male') THEN 'Male'
				 ELSE 'n/a'
			END AS gen
	FROM bronze.erp_cust_az12;

	SET @end_time = GETDATE();
	PRINT '....loading duration: ' +CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' Seconds';
	PRINT('--------------------------------------------------------');


	SET @start_time = GETDATE()

	PRINT '<<<<< Truncating: silver.erp_cat_g1v2';
	TRUNCATE TABLE silver.erp_cat_g1v2;
	PRINT '>>>>> Inserting Data into: silver.erp_cat_g1v2'

	INSERT INTO silver.erp_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance)

	select  ID as id,
			CAT as cat,
			SUBCAT as subcat,
			MAINTENANCE as maintenance
	from bronze.erp_cat_g1v2;

	SET @end_time = GETDATE();
	PRINT '....loading duration: ' +CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' Seconds';
	PRINT('--------------------------------------------------------');


	SET @start_time = GETDATE();

	PRINT '<<<<< Truncating: silver.erp_loc_a101';
	TRUNCATE TABLE silver.erp_loc_a101;
	PRINT '>>>>> Inserting Data into: silver.erp_loc_a101'

	INSERT INTO silver.erp_loc_a101(cid,cntry)
	SELECT REPLACE(CID,'-','') as cid, 
			CASE WHEN UPPER(TRIM(CNTRY)) ='DE' THEN 'Germany'
				 WHEN UPPER(TRIM(CNTRY)) IN ('US','USA') THEN 'United States'
				 WHEN TRIM(CNTRY) IS NULL OR TRIM(CNTRY)='' THEN 'n/a'
				 ELSE TRIM(CNTRY)
			END AS cntry
	FROM bronze.erp_loc_a101;

	SET @end_time = GETDATE();
	PRINT '....loading duration: ' +CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' Seconds';
	PRINT('--------------------------------------------------------');

	SET @layer_end_time = GETDATE();
	PRINT('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
	PRINT 'SILVER LAYER LOADING COMPLETED';
	PRINT '....Total Load Duration: ' + CAST(DATEDIFF(second,@layer_start_time,@layer_end_time) AS NVARCHAR) + ' Seconds';
	PRINT('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
	
	END TRY
	BEGIN CATCH
		PRINT('--------------------------------------------------');
		PRINT('ERROR OCCURED DURRING SILVER LAYER LOADING');
		PRINT('--------------------------------------------------');
		PRINT('Error Message: '+	ERROR_MESSAGE());
		PRINT('Error Message: '+	CAST(ERROR_NUMBER() AS NVARCHAR));
		PRINT('Error Message: '+	CAST(ERROR_STATE() AS NVARCHAR));
	END CATCH
END
