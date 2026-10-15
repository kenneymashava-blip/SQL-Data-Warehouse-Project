# Data Warehouse and Analystics project

Welcome to the **data warehouse and Analytics project** repository!

This project is divided into three sections:
- **SQL Data Warehouse development**.
- **SQL Exploratory Data Analysis(EDA)** and Advanced Data Analysis.
- **PowerBI Dashboard Development**.

## SQL Data Warehouse development.
This section of the project is about building a data warehouse using SQL Server Management Studio. The **Medallion Data Architecture** is employed to develop the datasets ready for business reporting, SQL quirries and PowerBI dashboards development. 
SQL Data Warehouse development showcases the following: 
- **Data Architecture:** Design Data Warehouse using the Medallion Data Architecture: **Bronze Layer, Silver Layer and Gold layer**.
- **ETL Pipelines:** Data extraxtion ,transformation and loading the csv files from source systems into the  Data Warehouse.
- **Data Modelling** Developing business ready SQL datasets: **Dimension_Product View, Dimension_Customer View and Fact View**, geared towards direct queries for Data Analytics and Reporting.

## SQL Exploratory Data Analysis(EDA) and Advanced Data Analysis

This section is concerned with performing Exploratory Data Analysis(EDA) and Advanced Data Analysis using the **Dimension_Product View, Dimension_Customer View and Fact View**  developed in the Data Warehouse development section.

The Exploratory Data Analysis(EDA) subsection showcases the following:
- Database Exploration
- Dimensions Exploration
- Dates exploration
- Measures
- Magnitude
- Ranking

Whereas, the Advanced Data Analysis includes:
- Cummulative Analysis
- Perfomance Analysis
- Change-Over-Time Analysis
- Part-to-whole Analysis
- Data segmentation
- Reporting: whereby SQL **Customer_Report View** and **Product_report View** are developed to consolidate the key customers and products metrics and behaviors.

##  **PowerBI Dashboard Development**
This is the final stage of the project. 
The datasets **Dimension_Product View, Dimension_Customer View ,Fact View, Customer_Report View and Product_report View** developed in the previous two stages are converted back to csv files and loaded into PowerBI. The star schema model is developed inside PowerBI by connecting the primary keys from the dimension views (Dimension_Product View, Dimension_Customer View) to the fact views (Fact View, Customer_Report View and Product_report View). 
Finally two Dashboards: **Product Report Overview** and **Customer Report Overview** are developed using PowerBI.
