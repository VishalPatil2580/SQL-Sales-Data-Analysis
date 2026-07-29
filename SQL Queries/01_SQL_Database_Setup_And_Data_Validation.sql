-- Create Database.
CREATE DATABASE IF NOT EXISTS sales;

USE SALES;

-- Tables are imported from csv file. Data is cleaned in excel. So we will just analyze data here.

-- Showing table names that are present
SHOW TABLES;


-- Shows data present in table.
SELECT * FROM customers;
SELECT * FROM products LIMIT 135;
SELECT * FROM orders;


-- Count the rows present in table.
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;


-- Count columns present in table.
SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='customers';
SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='products';
SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='orders';


-- Show columns names. 
DESCRIBE customers;
DESCRIBE products;
DESCRIBE orders;


-- Change data type, because while importing data from excel data types are not perfect. So Changes are required.
ALTER TABLE customers
MODIFY COLUMN customer_id VARCHAR(50),
MODIFY COLUMN first_name VARCHAR(50),
MODIFY COLUMN last_name VARCHAR(50),
MODIFY COLUMN city VARCHAR(50),
MODIFY COLUMN state VARCHAR(50),
MODIFY COLUMN signup_date DATE,
MODIFY COLUMN segment VARCHAR(50);

ALTER TABLE orders
MODIFY COLUMN order_id VARCHAR(50),
MODIFY COLUMN order_date DATE,
MODIFY COLUMN customer_id VARCHAR(50),
MODIFY COLUMN product_id VARCHAR(50),
MODIFY COLUMN quantity INT,
MODIFY COLUMN discount DECIMAL(4,2),
MODIFY COLUMN sales DECIMAL(10,2);

ALTER TABLE products
MODIFY COLUMN product_id VARCHAR(50),
MODIFY COLUMN product_name VARCHAR(50),
MODIFY COLUMN category VARCHAR(50),
MODIFY COLUMN subcategory VARCHAR(50),
MODIFY COLUMN brand VARCHAR(50),
MODIFY COLUMN price DECIMAL(10,2),
MODIFY COLUMN cost DECIMAL(10,2);

-- Now we need to give Primary Key to customer_id, order_id and product_id.
-- For customers table.
-- First we check for duplicates data before giving PK. If present then we need to remove it.
SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Now we need to check for null values. If present then we need some action.
SELECT *
FROM customers
WHERE customer_id IS NULL;

-- Now we can Give Primary Key to customer_id As it does not contain Duplicates and Null Values.
ALTER TABLE customers
ADD PRIMARY KEY (customer_id);


-- For orders table.
-- Check for duplicates data, So after that we can give primary key to particular colums.
SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check for null values. If present then we need some action.
SELECT *
FROM orders
WHERE order_id IS NULL;

-- Now we can Give Primary Key to order_id As it does not contain Duplicates and Null Values.
ALTER TABLE orders
ADD PRIMARY KEY (order_id);


-- For products table.
-- Check for duplicates data, So after that we can give primary key to particular colums.
SELECT product_id, COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Check for null values. If present then we need some action according to business needs.
SELECT *
FROM products
WHERE product_id IS NULL;

-- Now we can Give Primary Key to product_id As it does not contain Duplicates and Null Values.
ALTER TABLE products
ADD PRIMARY KEY (product_id);


-- Now we have to give Foreign Key to customer_id and product_id in orders table.
-- For orders table.
-- First check for values(customer_id) that present in orders table and doesn't exist in parent table.
SELECT DISTINCT o.customer_id
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Now we can give Foreign Key to customer_id.
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);


-- First check for values(product_id) that present in orders table and doesn't exist in parent table.
SELECT DISTINCT o.product_id
FROM orders o
LEFT JOIN products p
ON o.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Now we can give Foreign Key to customer_id.
ALTER TABLE orders
ADD CONSTRAINT fk_orders_products
FOREIGN KEY (product_id)
REFERENCES products(product_id);

-- Checking Null Values in customers table.
SELECT
    COUNT(CASE WHEN customer_id IS NULL THEN 1 END) AS null_customer_id,
    COUNT(CASE WHEN first_name IS NULL THEN 1 END) AS null_first_name,
    COUNT(CASE WHEN last_name IS NULL THEN 1 END) AS null_last_name,
    COUNT(CASE WHEN city IS NULL THEN 1 END) AS null_city,
    COUNT(CASE WHEN state IS NULL THEN 1 END) AS null_state,
    COUNT(CASE WHEN signup_date IS NULL THEN 1 END) AS null_signup_date,
    COUNT(CASE WHEN segment IS NULL THEN 1 END) AS null_segment
FROM customers;

-- Checking for Blank Values check.
SELECT
    SUM(CASE WHEN TRIM(customer_id) = '' THEN 1 ELSE 0 END) AS blank_customer_id,
    SUM(CASE WHEN TRIM(first_name) = '' THEN 1 ELSE 0 END) AS blank_first_name,
    SUM(CASE WHEN TRIM(last_name) = '' THEN 1 ELSE 0 END) AS blank_last_name,
    SUM(CASE WHEN TRIM(city) = '' THEN 1 ELSE 0 END) AS blank_city,
    SUM(CASE WHEN TRIM(state) = '' THEN 1 ELSE 0 END) AS blank_state,
    SUM(CASE WHEN TRIM(signup_date) = '' THEN 1 ELSE 0 END) AS blank_signup_date,
    SUM(CASE WHEN TRIM(segment) = '' THEN 1 ELSE 0 END) AS blank_segment
FROM customers;

-- Disctinct Values Analysis.
SELECT DISTINCT state
FROM customers
ORDER BY state;

SELECT DISTINCT city
FROM customers
ORDER BY city;

SELECT DISTINCT segment
FROM customers
ORDER BY segment;

-- Numerical Columns Validation.
-- Negative Price.
SELECT *
FROM products
WHERE price < 0;

-- Negative Cost
SELECT *
FROM products
WHERE cost < 0;

-- Cost Graeter than Price
SELECT *
FROM products
WHERE cost > price;

-- Negatiev Quantity.
SELECT *
FROM orders
WHERE quantity < 0;

-- Zero Quantity
SELECT *
FROM orders
WHERE quantity = 0;

-- Negative Sales
SELECT *
FROM orders
WHERE sales < 0;

-- Negative Discount
SELECT *
FROM orders
WHERE discount < 0;

-- Discount Greater than 100.
SELECT *
FROM orders
WHERE discount > 1;


-- Date Validation
-- Earliest Signup Date
SELECT
MIN(signup_date) AS earliest_signup
FROM customers;

-- Latest Signup Date
SELECT
MAX(signup_date) AS latest_signup
FROM customers;

-- customers with Null Signup Date.
SELECT *
FROM customers
WHERE signup_date IS NULL;

-- String Functions
-- Convert into Upper, Lower Case.
SELECT
    customer_id,
    LOWER(first_name) AS lower_case,
    UPPER(first_name) AS upper_case
FROM customers;

-- Concat : combines 2 columns. 
SELECT
    customer_id,
    CONCAT(first_name,' ',last_name) AS full_name
FROM customers;

-- Length : Count the number of characters present.
SELECT
    first_name,
    LENGTH(first_name) AS total_characters
FROM customers;

-- Trim : removes Leading and Trailing Spaces.
SELECT
    customer_id,
    TRIM(first_name) AS first_name
FROM customers;

-- Replace : Used for replace value with another value.
SELECT
    customer_name,
    REPLACE(customer_name,'Sam','Sai') AS Correct_Customer_Name
FROM products;

-- Left, Right : For extracting specific portion from left or right side.
SELECT
    product_name,
    LEFT(product_name,3) AS first_three_letters,
    Right(product_name,3) AS last_three_letters
FROM products;

-- Substring : Extract character within range.
SELECT
    product_name,
    SUBSTRING(product_name,1,5) AS extracted_text
FROM products;

-- Date Functions.
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS month_number,
    MONTHNAME(order_date) AS month_name,
    QUARTER(order_date) AS quarter,
    DAYNAME(order_date) AS weekday,
    COUNT(*) AS total_orders
FROM orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date),
    MONTHNAME(order_date),
    QUARTER(order_date),
    DAYNAME(order_date)
ORDER BY
    order_year,
    month_number;

-- Days difference.
SELECT
    customer_id,
    DATEDIFF(CURDATE(), signup_date) AS days_since_signup
FROM customers;