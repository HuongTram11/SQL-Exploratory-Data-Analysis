--SQL for Exploratory Data Analysis

--use database
USE SALES
GO
--

/************** WHAT is EDA? **************/
-- An approach of analyzing data sets to summarize their main characteristics
-- Often using statistical graphics
-- Help us to understand what the data can tell us beyond the formal modeling or hypothesis testing task

--> So what the data can tell us through EDA?
-- Missing values
-- Outliers: Data is out of the range values
--

/************** STEPS of EDA? **************/
--Step1: Check For Missing Data
--Step2: Exploring Basic Descriptions of Data with Statistics
--Step3: Identify Quartiles and Box plots
--Step4: Identify Significant Correlations


/**GO TO DETAIL FOR EACH STEP**/

--STEP 1: Check For Missing Data

---- check first 10 rows to see what data we have
SELECT TOP 10 * FROM dbo.Sales

---- check how many rows
SELECT COUNT(*) AS 'Nb of row' FROM dbo.Sales;

---- Missing Values Check for only one column
SELECT * FROM dbo.Sales WHERE order_id IS NULL

---- Check number of row for each column: In this data, all column has the same number of row because I have made the constraint 'NOT NULL' when I created table
SELECT COUNT(order_id) AS 'order_id',
	COUNT(customer_id) AS 'customer_id',
	COUNT(staff_name) AS 'staff_name',
	COUNT(order_date) AS 'order_date',
	COUNT(priority_levels) AS 'priority_levels',
	COUNT(product_id) AS 'product_id',
	COUNT(amount) AS 'amount',
	COUNT(price) AS 'price',
	COUNT(discount) AS 'discount',
	COUNT(transport_fee) AS 'transport_fee',
	COUNT(type_transport) AS 'type_transport',
	COUNT(package) AS 'package',
	COUNT(transport_date) AS 'transport_date'
FROM dbo.Sales

---- Check number of missing values for each column (When we were known the exact number of row, you can use it instead of COUNT(*))

SELECT COUNT(*) - COUNT(order_id) AS 'order_id',
	COUNT(*) - COUNT(customer_id) AS 'customer_id',
	COUNT(*) - COUNT(staff_name) AS 'staff_name',
	COUNT(*) - COUNT(order_date) AS 'order_date',
	COUNT(*) - COUNT(priority_levels) AS 'priority_levels',
	COUNT(*) - COUNT(product_id) AS 'product_id',
	COUNT(*) - COUNT(amount) AS 'amount',
	COUNT(*) - COUNT(price) AS 'price',
	COUNT(*) - COUNT(discount) AS 'discount',
	COUNT(*) - COUNT(transport_fee) AS 'transport_fee',
	COUNT(*) - COUNT(type_transport) AS 'type_transport',
	COUNT(*) - COUNT(package) AS 'package',
	COUNT(*) - COUNT(transport_date) AS 'transport_date'
FROM dbo.Sales


-- STEP 2: Exploring Basic Descriptions of Data with Statistics
---- 1.  what kind of data? Numerical or categorical features? And how many?
------There are 3 continuous features,2 discrete features, and 6 categorical features, 2 date features
---- 2. Why does classifying features help us?
------=> we can choose the correct visualizations of EDA and statistical methods for each feature. There are some visualizations cannot display on continous, discrete or categorical data
---- 3. Descriptions
---- for countinous or discrete features: detemine some basis desriptive statistics information: average, min, max, range value, percentiles, median,etc.


-------> Summary of field Amount:
-- Discrete Feature
-- Values are between 1 and 50. Average value is 25. Median value is 26. Mode value is 31.
-- Data is not missing 

/*min, max, average amount*/
SELECT MIN(amount) AS min_amount,
	MAX(amount) AS max_amount,
	AVG(amount) AS avg_amount
FROM dbo.Sales

/*Which customer ordered the lagest amount?*/
SELECT TOP 1 order_id, customer_id, order_date, product_id, amount
FROM dbo.Sales
ORDER BY amount DESC

/* Median */
--To get the last value in the top 50 percent of rows….
SELECT TOP 1 Sales.product_id, product_name, amount
FROM dbo.Sales 
JOIN dbo.Products 
ON Products.product_id = Sales.product_id
WHERE amount IN (SELECT TOP 50 PERCENT amount 
					FROM dbo.Sales
					ORDER BY amount ASC)
ORDER BY amount DESC

/* Mode*/
-- What is the most frequence of products? 
-- We can see the product 'Xe đạp' is are the months which have most number of confirmed case
SELECT TOP 1 s.amount
FROM   dbo.Sales s
WHERE  s.amount IS Not NULL
GROUP  BY s.amount
ORDER  BY COUNT(*) DESC

/*Out of Range Values (0,45)*/

SELECT * FROM dbo.Sales
WHERE amount<0 AND amount>45

-------> Summary of field type_transport:
-- Categorical Feature
-- Assumes four values: 'Tàu', 'Máy bay', 'Xe tải'
-- The value counts of 'Tàu', 'Máy bay', 'Xe tải' are 4209, 6741, 1744 => Máy bay is the most used means of transportation
-- Data is not missing 


--What types of transportation:
SELECT type_transport, COUNT(*) FROM dbo.Sales
GROUP BY type_transport

-------> Summary of field transport_fee:
-- Continuous Feature
-- Values are between 0.49 and 164.73. Average value is 12,89
-- Data is not missing 

/*min, max, average amount*/
SELECT MIN(transport_fee) AS min_fee,
	MAX(transport_fee) AS max_fee,
	ROUND(AVG(transport_fee),2) AS avg_fee
FROM dbo.Sales

----we can do the same for other columns

--STEP3: Identify Quartiles and Box plots

---- Firstly, we add column revenue and calculate revenue = amount*price*(1-discount)
ALTER TABLE dbo.Sales
ADD revenue FLOAT;

UPDATE dbo.Sales
SET revenue = ROUND(amount*price*(1-discount),2)

----check min, max, average value of revenue
SELECT MIN(revenue) AS min_revenue,
	MAX(revenue) AS max_revenue,
	ROUND(AVG(revenue),2) AS avg_revenue,
	COUNT(*) AS nb_of_order
FROM dbo.Sales
--- Percentile 50, 90, 95
SELECT
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY revenue) OVER() AS percentitles_50_revenue,
	PERCENTILE_DISC(0.9) WITHIN GROUP(ORDER BY revenue) OVER() AS percentitles_90_revenue,
	PERCENTILE_DISC(0.95) WITHIN GROUP(ORDER BY revenue) OVER() AS percentitles_95_revenue
FROM dbo.Sales

--QUARTILE 1 (25%) = 133.64
SELECT MAX(revenue) FROM dbo.Sales
WHERE revenue in (SELECT TOP(25) PERCENT revenue
				FROM dbo.Sales 
				ORDER BY revenue)

--QUARTILE 3 (75%) = 1692.75
SELECT MIX(revenue) FROM dbo.Sales
WHERE revenue in (SELECT TOP(25) PERCENT revenue
				FROM dbo.Sales 
				ORDER BY revenue DESC)

--IRQ (Inter Quartile Range) = 3rd - 1st = 1692.75 - 133.64 = 1559.11
---> we can find out the outliers that are not in IRQ 

--STEP4: Identify Significant Correlations

/* check the correlation between amount and revenue*/
/* we can see that there is low correlation between amount and revenue 0.2357. So we can check more correlation between other variables*/
SELECT ((Avg(amount * revenue) - (Avg(amount) * Avg(revenue))) / (StDev(amount) * StDev(revenue))) AS 'Cor_amount_revenue'
FROM dbo.Sales

------There is one step we need to do in EDA. That is visualization the data distribution but SQL servel does not support so you can do it in excel or other programs


