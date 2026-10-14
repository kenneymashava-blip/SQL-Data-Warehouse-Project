/*
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Stored Procedure: Load Bronze Layer (Source -> Bronze Schema)
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Procedure Purpose:	
	This procedure loads data from external csv files sources into the 'bronze' schema.
	It perfoms the following actions:
		- Truncate the bronze tables before loading new data
		- uses the 'BULK INSERT' command to load data

Parameters: None.
	This stored procedure does not accept any parameters or return any values.

Usage Example:
	EXEC bronze.load_bronze;

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze_layer AS
BEGIN
	DECLARE @start_time DATETIME,
			@end_time DATETIME,
			@layer_start_time DATETIME,
			@layer_end_time DATETIME;

	BEGIN TRY

	SET @layer_start_time = GETDATE();
	PRINT('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
	PRINT('LOADING THE BRONZE LAYER');
	PRINT('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');

	PRINT('------------------------------------------------------');
	PRINT('loading tables from: Source_crm');
	PRINT('------------------------------------------------------');

	SET @start_time = GETDATE();
	PRINT('....Truncating the bronze.crm_cust_info table');
	TRUNCATE TABLE bronze.crm_cust_info;


	PRINT('.... Bulk inserting Data into: bronze.crm_cust_info');
	BULK INSERT bronze.crm_cust_info
	FROM 'C:\Users\KENNETH\Desktop\DWH Project\source_crm\cust_info.csv'
	WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK );
	SET @end_time = GETDATE();
	PRINT('>> loading duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' Seconds');
	PRINT('--------------------------------------------------------');

	SET @start_time = GETDATE();
	PRINT('.... Truncating the bronze.crm_prd_info');
	TRUNCATE TABLE bronze.crm_prd_info;

	PRINT('.... Bulk inserting Data into: bronze.crm_prd_info');
	BULK INSERT bronze.crm_prd_info
	FROM 'C:\Users\KENNETH\Desktop\DWH Project\source_crm\prd_info.csv'
	WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT('>> loading duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' Seconds');
	PRINT('--------------------------------------------------------');

	SET @start_time = GETDATE();
	PRINT('.... Truncating the bronze.crm_sales_details table');
	TRUNCATE TABLE bronze.crm_sales_details;

	PRINT('.... Bulk inserting Data into: bronze.crm_sales_details');
	BULK INSERT bronze.crm_sales_details
	FROM 'C:\Users\KENNETH\Desktop\DWH Project\source_crm\sales_details.csv'
	WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT('>> loading duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' Seconds');
	PRINT('--------------------------------------------------------');


	PRINT('------------------------------------------------------');
	PRINT('loading tables from: source_erp');
	PRINT('------------------------------------------------------');

	SET @start_time = GETDATE();
	PRINT('.... Truncating the bronze.erp_cat_g1v2 table');
	TRUNCATE TABLE bronze.erp_cat_g1v2;

	PRINT('Bulk inserting Data into: bronze.erp_cat_g1v2 table');
	BULK INSERT bronze.erp_cat_g1v2
	FROM 'C:\Users\KENNETH\Desktop\DWH Project\source_erp\px_cat_g1v2.csv'
	WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT('>> loading duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' Seconds');
	PRINT('--------------------------------------------------------');

	SET @start_time = GETDATE();
	PRINT('.... Truncating the bronze.erp_cust_az12 table');
	TRUNCATE TABLE bronze.erp_cust_az12;

	PRINT('.... Bulk inserting Data into: bronze.erp_cust_az12');
	BULK INSERT bronze.erp_cust_az12
	FROM 'C:\Users\KENNETH\Desktop\DWH Project\source_erp\cust_az12.csv'
	WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT('>> loading duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' Seconds');
	PRINT('--------------------------------------------------------');

	SET @start_time = GETDATE();
	PRINT('.... Truncating the bronze.erp_loc_a101 table');
	TRUNCATE TABLE bronze.erp_loc_a101;

	PRINT('.... Bulk inserting Data into: bronze.erp_loc_a101');
	BULK INSERT bronze.erp_loc_a101
	FROM 'C:\Users\KENNETH\Desktop\DWH Project\source_erp\loc_a101.csv'
	WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK 
		);
	SET @end_time = GETDATE();
	PRINT('>> loading duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' Seconds');
	PRINT('--------------------------------------------------------');
	
	SET @layer_end_time = GETDATE();
	PRINT('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
	PRINT 'BRONZE LAYER LOADING COMPLETED';
	PRINT ' - Total Load Duration: ' + CAST(DATEDIFF(second,@layer_start_time,@layer_end_time) AS NVARCHAR) + ' Seconds';
	PRINT('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
	END TRY
	BEGIN CATCH
		PRINT('--------------------------------------------------');
		PRINT('ERROR OCCURED DURRING BRONZE LAYER LOADING');
		PRINT('--------------------------------------------------');
		PRINT('Error Message'+	ERROR_MESSAGE());
		PRINT('Error Message'+	CAST(ERROR_NUMBER() AS NVARCHAR));
		PRINT('Error Message'+	CAST(ERROR_STATE() AS NVARCHAR));
	END CATCH
END
