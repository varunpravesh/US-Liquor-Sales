--Updating the table with standardized Store Names

UPDATE liquor_sales_us
SET store_name = ssn.store_name_replaced
FROM          -- Since snowflake wouldn't allow an update statement after CTE we have to wrap the entire thing in a subquery
(
    WITH store_info AS          -- We count the duplicate store names having the same store number 
    (
        SELECT
            store_number,
            store_name,
            ROW_NUMBER() OVER (PARTITION BY store_number ORDER BY COUNT(*) DESC) AS rn
        FROM liquor_sales_us
        GROUP BY store_number, store_name
        ORDER BY store_number
    ),
    
    --SELECT * FROM store_info
    
    top_store_names AS (                  -- We take the most used store names and use that value to fill the duplicate ones
        SELECT 
            store_number,
            store_name AS top_store_name
        FROM store_info
        WHERE rn = 1
    )
    SELECT 
        A.store_name,
        A.store_number,
        CASE 
            WHEN A.rn > 1 THEN B.top_store_name
            ELSE A.store_name
        END AS store_name_replaced
    FROM store_info A
    LEFT JOIN top_store_names B
        ON A.store_number = B.store_number
) AS ssn
WHERE liquor_sales_us.store_number = ssn.store_number


--Updating the table with standardized Vendor Names

UPDATE liquor_sales_us
SET vendor_name = svn.vendor_name_replaced
FROM          -- Since snowflake wouldn't allow an update statement after CTE we have to wrap the entire thing in a subquery
(
    WITH vendor_info AS          -- We count the duplicate vendor names having the same vendor number 
    (
        SELECT
            vendor_number,
            vendor_name,
            ROW_NUMBER() OVER (PARTITION BY vendor_number ORDER BY COUNT(*) DESC) AS rn
        FROM liquor_sales_us
        GROUP BY vendor_number, vendor_name
        ORDER BY vendor_number
    ),
    
    --SELECT * FROM vendor_info
    
    top_vendor_names AS (                  -- We take the most used vendor names and use that value to fill the duplicate ones
        SELECT 
            vendor_number,
            vendor_name AS top_vendor_name
        FROM vendor_info
        WHERE rn = 1
    )
    SELECT 
        A.vendor_name,
        A.vendor_number,
        CASE 
            WHEN A.rn > 1 THEN B.top_vendor_name
            ELSE A.vendor_name
        END AS vendor_name_replaced
    FROM vendor_info A
    LEFT JOIN top_vendor_names B
        ON A.vendor_number = B.vendor_number
) AS svn
WHERE liquor_sales_us.vendor_number = svn.vendor_number;


--Updating the table with standardized Category Names

UPDATE liquor_sales_us
SET category_name = scn.category_name_replaced
FROM          -- Since snowflake wouldn't allow an update statement after CTE we have to wrap the entire thing in a subquery
(
    WITH category_info AS          -- We count the duplicate category names having the same category 
    (
        SELECT
            category,
            category_name,
            ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS rn
        FROM liquor_sales_us
        GROUP BY category, category_name
        ORDER BY category
    ),
    
    --SELECT * FROM category_info
    
    top_category_names AS (                  -- We take the most used category names and use that value to fill the duplicate ones
        SELECT 
            category,
            category_name AS top_category_name
        FROM category_info
        WHERE rn = 1
    )
    SELECT 
        A.category_name,
        A.category,
        CASE 
            WHEN A.rn > 1 THEN B.top_category_name
            ELSE A.category_name
        END AS category_name_replaced
    FROM category_info A
    LEFT JOIN top_category_names B
        ON A.category = B.category
) AS scn
WHERE liquor_sales_us.category = scn.category;


-- Standaradizing the address, city, county, category name, vendor name, item description by capitalizing the first letter of each word
UPDATE liquor_sales_us
SET 
    address = INITCAP(address),
    city = INITCAP(city),
    county = INITCAP(county),
    category_name = INITCAP(category_name),
    vendor_name = INITCAP(vendor_name),
    item_description = INITCAP(item_description)
WHERE 
    address != INITCAP(address)
    OR city != INITCAP(city)
    OR county != INITCAP(county)
    OR category_name != INITCAP(category_name)
    OR vendor_name != INITCAP(vendor_name)
    OR item_description != INITCAP(item_description);

    
-- Splitting the store_location column into Longitude and Latitude
-- SELECT 
-- store_location,
-- --REPLACE(REPLACE(store_location,'POINT (',''),')','') AS replaced,
-- SPLIT_PART(REPLACE(REPLACE(store_location,'POINT (',''),')',''),' ',1) AS longitude,
-- SPLIT_PART(REPLACE(REPLACE(store_location,'POINT (',''),')',''),' ',2) AS latitude
-- FROM liquor_sales_us 
-- LIMIT 1000

-- Creating a transactions table (Fact Table)
CREATE OR REPLACE TABLE liquor_sales AS 
SELECT 
invoice_item_number,
date,
store_number,
category,
vendor_number,
item_number,
item_description,
bottle_volume_ml,
state_bottle_cost,
state_bottle_retail,
bottles_sold,
sale_dollars,
volume_sold_liters,
volume_sold_gallons
FROM liquor_sales_us
WHERE category IS NOT NULL AND vendor_number IS NOT NULL 

SELECT * FROM liquor_sales
WHERE category IS NULL

-- Creating a store_info table that contains the details of each store (Dim Table)
CREATE OR REPLACE TABLE store_info AS 
SELECT
    store_number,
    MAX(store_name) as store_name,      --This will give you one unique row per STORE_NUMBER, picking the "maximum"                                                    (alphabetically or numerically highest) value for each other column. This is                                                 because there are multiple records for some store numbers where some of the                                                  records have null values in some columns. By using the max aggregate function we                                             technically perform a merge where the null values are "filled" with the values                                               from the records which aren't null
    MAX(address) as address,
    MAX(city) as city,
    MAX(zip_code) as zip_code,
    MAX(store_location) as store_location,
    MAX(SPLIT_PART(REPLACE(REPLACE(store_location,'POINT (',''),')',''),' ',1)) AS longitude,
    MAX(SPLIT_PART(REPLACE(REPLACE(store_location,'POINT (',''),')',''),' ',2)) AS latitude,
    MAX(county_number) as county_number,
    MAX(county) as county
FROM
    store_info
GROUP BY
    store_number

-- Creating a category_info table (Dim Table)
CREATE OR REPLACE TABLE category_info AS
SELECT 
DISTINCT(category),
category_name
FROM liquor_sales_us
WHERE category IS NOT NULL


--Creating a vendor_info table (Dim Table)
CREATE OR REPLACE TABLE vendor_info AS
SELECT 
DISTINCT(vendor_number),
vendor_name
FROM liquor_sales_us
WHERE vendor_number IS NOT NULL

-- Creating a date table
CREATE OR REPLACE TABLE DATE_TABLE AS
SELECT 
    DATEADD(DAY, SEQ4(), (SELECT MIN(date) FROM liquor_sales)) AS DATE,
    EXTRACT(YEAR FROM DATEADD(DAY, SEQ4(), (SELECT MIN(date) FROM liquor_sales))) AS YEAR,
    EXTRACT(MONTH FROM DATEADD(DAY, SEQ4(), (SELECT MIN(date) FROM liquor_sales))) AS MONTH_NUM,
    MONTHNAME(DATEADD(DAY, SEQ4(), (SELECT MIN(date) FROM liquor_sales))) AS MONTH_NAME,
    EXTRACT(DAY FROM DATEADD(DAY, SEQ4(), (SELECT MIN(date) FROM liquor_sales))) AS DAY,
    WEEK(DATEADD(DAY, SEQ4(), (SELECT MIN(date) FROM liquor_sales))) AS WEEK_NUM,
    QUARTER(DATEADD(DAY, SEQ4(), (SELECT MIN(date) FROM liquor_sales))) AS QUARTER
FROM TABLE(GENERATOR(ROWCOUNT => 4018))
WHERE DATEADD(DAY, SEQ4(), (SELECT MIN(date) FROM liquor_sales)) <= (SELECT MAX(date) FROM liquor_sales)
ORDER BY MONTH_NUM ASC, MONTH_NAME DESC;

