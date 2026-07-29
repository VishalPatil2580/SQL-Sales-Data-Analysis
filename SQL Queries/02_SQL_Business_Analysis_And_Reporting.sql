/* Valuable Customers.
Write a query to display:
customer_id, first_name, Total number of orders, Total sales
Show only customers who have placed at least 3 orders and whose total sales are greater than the 
average sales of all orders. Sort the result by total sales in descending order. */



SELECT * FROM orders;
SELECT 
	c.customer_id AS Customer_ID,
	c.first_name AS Customer_Name,
	COUNT(o.order_id) AS Total_Orders,
	SUM(o.sales) AS Total_Sales
FROM customers AS c
INNER JOIN orders AS o
ON c.customer_id=o.customer_id
GROUP BY c.customer_id, c.first_name
HAVING COUNT(o.order_id) >= 3 AND SUM(o.sales) > 
	(
		SELECT AVG(sales) FROM orders
	)
ORDER BY Total_Sales DESC;


/* Customer Spending Analysis to identify best customers.
Write a query to display:
customer_id, first_name, city, total_orders, total_sales, average_order_value
Conditions:
Consider only customers who have placed at least 2 orders.
Show only those customers whose average order value is greater than the overall average sales of all orders.
Sort the result by:
total_sales (Descending)
If two customers have the same total_sales, then sort by average_order_value (Descending).*/

SELECT 
	c.customer_id,
    c.first_name,
    c.city,
    COUNT(o.order_id) AS Total_Orders,
    SUM(o.sales) AS Total_Sales,
    AVG(o.sales) AS AVG_Order_Value
FROM customers AS c
INNER JOIN orders AS o
ON c.customer_id=o.customer_id
GROUP BY c.customer_id, c.first_name, c.city
HAVING COUNT(o.order_id) >= 2 AND AVG(o.sales) > (SELECT AVG(sales) FROM orders)
ORDER BY Total_Sales DESC, AVG_Order_Value DESC;

/* Highest Spending Customer in each city.
Write a query to display:
city, customer_id, first_name, total_sales
Requirements
Calculate each customer's total sales.
For each city, find the customer with the highest total sales.
If two customers have the same highest total sales in a city, show both customers.
Sort the final result by: city (A–Z), total_sales (Descending)*/

WITH customer_totals AS (
    SELECT 
        c.city,
        c.customer_id,
        c.first_name,
        SUM(o.sales) AS total_sales,
        DENSE_RANK() OVER (
            PARTITION BY c.city 
            ORDER BY SUM(o.sales) DESC
        ) AS city_rank
    FROM customers AS c
    INNER JOIN orders AS o 
        ON c.customer_id = o.customer_id
    GROUP BY c.city, c.customer_id, c.first_name
)
SELECT 
    city,
    customer_id,
    first_name,
    total_sales
FROM customer_totals
WHERE city_rank = 1
ORDER BY city ASC, total_sales DESC;

/* Monthly Sales Performance.
Write a query to display:
Year, Month, Total Monthly Sales, Previous Month's Total Sales and 
Sales Difference (Current Month Sales - Previous Month Sales)*/

WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS Year,
        MONTH(order_date) AS Month_No,
        MONTHNAME(order_date) AS Month,
        SUM(sales) AS Total_Sales
    FROM orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date),
        MONTHNAME(order_date)
)
SELECT
    Year,
    Month,
    Total_Sales,
    LAG(Total_Sales) OVER (
        ORDER BY Year, Month_No
    ) AS Previous_Month_Sales,
    Total_Sales -
    LAG(Total_Sales) OVER (
        ORDER BY Year, Month_No
    ) AS Sales_Difference
FROM monthly_sales
ORDER BY
    Year,
    Month_No;


-- CUSTOMER ANALYSIS.
-- 1. Top 10 Customers with Highest Revenue.
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    SUM(o.sales) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 2. Bottom 10 Customers with Lowest Revenue
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    SUM(o.sales) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_revenue
LIMIT 10;

-- 3. Customers Who Never Ordered
SELECT
    c.*
FROM customers c
WHERE NOT EXISTS
(
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
    );

-- 4. Repeat Customers.
SELECT
	customer_id,
	COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(*)>1
ORDER BY total_orders DESC;

-- 5. Average Revenue per Customer
SELECT
	AVG(customer_revenue) average_customer_revenue
FROM
	(
		SELECT
		customer_id,
		SUM(sales) customer_revenue
		FROM orders
		GROUP BY customer_id
	) revenue;

-- PRODUCT ANALYSIS.
-- 1. Best Selling Product
SELECT
	p.product_name,
	SUM(o.quantity) total_quantity
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.product_name
ORDER BY total_quantity DESC
LIMIT 1;

-- 2. Worst Selling Product
SELECT
	p.product_name,
	SUM(o.quantity) total_quantity
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.product_name
ORDER BY total_quantity
LIMIT 1;

-- 3. Highest Revenue Product
SELECT
	p.product_name,
	SUM(o.sales) revenue
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 1;

-- 4. Most Profitable Product
SELECT
	p.product_name,
	SUM(o.sales - (p.cost * o.quantity)) AS total_profit
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.product_name
ORDER BY total_profit DESC
LIMIT 1;

-- CATEGORY ANALYSIS.
-- 1. Revenue by Category.
SELECT
	p.category,
	SUM(o.sales) revenue
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- 2. Profit by Category.
SELECT
	p.category,
	SUM(o.sales - (p.cost * o.quantity)) AS total_profit
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.category
ORDER BY total_profit DESC;

-- 3. Quantity by Category.
SELECT
	p.category,
	SUM(o.quantity) quantity
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.category;

-- BRAND ANALYSIS.
-- 1. Revenue by Brand
SELECT
	brand,
	SUM(o.sales) revenue
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY brand
ORDER BY revenue DESC;

-- 2. Top Brand.
SELECT
	brand,
	SUM(o.sales) revenue
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY brand
ORDER BY revenue DESC
LIMIT 1;

-- LOCATION ANALYSIS.
-- 1. Revenue by State.
SELECT
	c.state,
	SUM(o.sales) revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY c.state
ORDER BY revenue DESC;

-- 2. Revenue by City.
SELECT
	c.city,
	SUM(o.sales) revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY c.city
ORDER BY revenue DESC;

-- 3. Customers by State.
SELECT
	state,
	COUNT(*) total_customers
FROM customers
GROUP BY state
ORDER BY total_customers DESC;

-- TIME ANALYSIS.
-- 1. Monthly Revenue.
SELECT
	YEAR(order_date) year,
	MONTH(order_date) month_no,
	MONTHNAME(order_date) month,
	SUM(sales) revenue
FROM orders
GROUP BY
	YEAR(order_date),
	MONTH(order_date),
	MONTHNAME(order_date)
ORDER BY
	year,
	month_no;

-- 2. Quarterly Revenue.
SELECT
	YEAR(order_date) year,
	QUARTER(order_date) quarter,
	SUM(sales) revenue
FROM orders
GROUP BY
YEAR(order_date),
QUARTER(order_date);

-- 3. Yearly Revenue
SELECT
	YEAR(order_date) year,
	SUM(sales) revenue
FROM orders
GROUP BY YEAR(order_date);