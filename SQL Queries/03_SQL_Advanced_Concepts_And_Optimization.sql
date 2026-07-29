-- BUSINESS INSIGHTS.
-- 1. Shows complete Sales Details.
SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    p.product_name,
    p.category,
    p.brand,
    o.quantity,
    o.discount,
    o.sales
FROM orders o
INNER JOIN customers c
ON o.customer_id = c.customer_id
INNER JOIN products p
ON o.product_id = p.product_id;

-- 2. Total Revenue by Customer.
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    SUM(o.sales) AS total_revenue
FROM customers c
INNER JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- 3. Revenue by Product.
SELECT
    p.product_name,
    SUM(o.sales) AS total_revenue
FROM products p
INNER JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- 4. Revenue by Category.
SELECT
    p.category,
    SUM(o.sales) AS total_revenue
FROM products p
INNER JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 5. Revenue by Brand.
SELECT
    p.brand,
    SUM(o.sales) AS total_revenue
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.brand
ORDER BY total_revenue DESC;

-- 6. Revenue by State.
SELECT
    c.state,
    SUM(o.sales) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY c.state
ORDER BY total_revenue DESC;

-- 7. Revenue by City.
SELECT
    c.city,
    SUM(o.sales) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY c.city
ORDER BY total_revenue DESC;

-- 8.  Revenue by Customer Segment
SELECT
    c.segment,
    SUM(o.sales) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY c.segment
ORDER BY total_revenue DESC;


-- BUSINESS KPIs.
-- 1. Total Revenue.
SELECT
SUM(sales) AS total_revenue
FROM orders;

-- 2. Total Orders.
SELECT
COUNT(*) AS total_orders
FROM orders;

-- 3. Total Quantity Sold.
SELECT
SUM(quantity) AS total_quantity
FROM orders;

-- 4. Average Order Value.
SELECT
AVG(sales) AS average_order_value
FROM orders;

-- 5. Total Profit.
SELECT
SUM(
o.sales - (p.cost * o.quantity)
) AS total_profit
FROM orders o
JOIN products p
ON o.product_id = p.product_id;

-- 6. Average Discount.
SELECT
AVG(discount) AS average_discount
FROM orders;

-- 7. Highest Sales.
SELECT
MAX(sales) AS highest_sale
FROM orders;

-- 8. Lowest Sales.
SELECT
MIN(sales) AS lowest_sale
FROM orders;


-- DATE ANALYSIS
-- 1. Revenue by Year.
SELECT
YEAR(order_date) AS year,
SUM(sales) AS revenue
FROM orders
GROUP BY YEAR(order_date)
ORDER BY year;

-- 2. Revenue by Month.
SELECT
MONTH(order_date) month_no,
MONTHNAME(order_date) month,
SUM(sales) revenue
FROM orders
GROUP BY
MONTH(order_date),
MONTHNAME(order_date)
ORDER BY month_no;

-- 3. Revenue by Quarter.
SELECT
QUARTER(order_date) quarter,
SUM(sales) revenue
FROM orders
GROUP BY QUARTER(order_date);

-- 4. Revenue by Weekday.
SELECT
DAYNAME(order_date) weekday,
SUM(sales) revenue
FROM orders
GROUP BY DAYNAME(order_date);


-- WINDOW FUNCTIONS.
-- 1. ROW NUMBER Function. Revenue by Products.
SELECT
p.product_name,
SUM(o.sales) revenue,
ROW_NUMBER()
OVER(
ORDER BY SUM(o.sales) DESC
) `row_number`
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.product_name;

-- 2. Rank Function.
SELECT
p.product_name,
SUM(o.sales) revenue,
RANK()
OVER(
ORDER BY SUM(o.sales) DESC
) ranking
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.product_name;

-- 3. DENSE RANK Function.
SELECT
p.product_name,
SUM(o.sales) revenue,
DENSE_RANK()
OVER(
ORDER BY SUM(o.sales) DESC
) `dense_rank`
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.product_name;

-- 4. NTILE Function. Divides the result into Given parts.
SELECT
p.product_name,
SUM(o.sales) revenue,
NTILE(4)
OVER(
ORDER BY SUM(o.sales) DESC
) quartile
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.product_name;

-- CASE.
-- 1. Categorize Orders Based on Sales.
SELECT
    order_id,
    sales,
    CASE
        WHEN sales >= 30000 THEN 'High Value'
        WHEN sales >= 15000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS sales_category
FROM orders;

-- 2. Categorize Products Based on Price.
SELECT
    product_name,
    price,
    CASE
        WHEN price >= 40000 THEN 'Premium'
        WHEN price >= 20000 THEN 'Mid Range'
        ELSE 'Budget'
    END AS price_category
FROM products;


-- 3. Profit Status of Products. 
SELECT
    product_name,
    price,
    cost,
    (price - cost) AS profit_per_unit,
    CASE
        WHEN (price - cost) > 15000 THEN 'High Profit'
        WHEN (price - cost) > 10000 THEN 'Medium Profit'
        ELSE 'Low Profit'
    END AS profit_category
FROM products;

-- 4. Discount Category.
SELECT
    order_id,
    discount,
    CASE
        WHEN discount >= 0.30 THEN 'High Discount'
        WHEN discount >= 0.15 THEN 'Medium Discount'
        ELSE 'Low Discount'
    END AS discount_category
FROM orders;

-- SUB QUERIES.
-- 1. Products Costing More Than Average Price.
SELECT *
FROM products
WHERE price >
(
    SELECT AVG(price)
    FROM products
);

-- 2. Products Costing Less Than Average Price
SELECT *
FROM products
WHERE price <
(
    SELECT AVG(price)
    FROM products
);

-- 3. Customers Who Have Placed Orders
SELECT *
FROM customers
WHERE customer_id IN
(
    SELECT customer_id
    FROM orders
);

-- 4. Customers Who Never Placed Orders.
SELECT
c.*
FROM customers c
WHERE NOT EXISTS
(
SELECT 1
FROM orders o
WHERE o.customer_id = c.customer_id
);

-- 5. Products Never Sold.
SELECT
p.*
FROM products p
WHERE NOT EXISTS
(
SELECT 1
FROM orders o
WHERE o.product_id = p.product_id
);

-- 6. Orders Above Average Sales
SELECT *
FROM orders
WHERE sales >
(
    SELECT AVG(sales)
    FROM orders
);

-- 7. Products With Maximum Price
SELECT *
FROM products
WHERE price =
(
    SELECT MAX(price)
    FROM products
);

-- 8. Products With Minimum Cost
SELECT *
FROM products
WHERE cost =
(
    SELECT MIN(cost)
    FROM products
);

-- 9. Customers Having Revenue Greater Than Average Customer Revenue.
SELECT
    customer_id,
    SUM(sales) AS total_revenue
FROM orders
GROUP BY customer_id
HAVING SUM(sales) >
(
    SELECT AVG(customer_revenue)
    FROM
    (
        SELECT
            customer_id,
            SUM(sales) AS customer_revenue
        FROM orders
        GROUP BY customer_id
    ) AS revenue_summary
);


-- CTE (COMMON TABLE EXPRESSION).
-- 1. Revenue by Product. 
WITH product_revenue AS
(
    SELECT
        p.product_name,
        SUM(o.sales) AS revenue
    FROM products p
    JOIN orders o
        ON p.product_id = o.product_id
    GROUP BY p.product_name
)
SELECT *
FROM product_revenue
ORDER BY revenue DESC;

-- 2. Products Above Average Revenue
WITH product_revenue AS
(
    SELECT
        p.product_name,
        SUM(o.sales) AS revenue
    FROM products p
    JOIN orders o
        ON p.product_id = o.product_id
    GROUP BY p.product_name
)
SELECT *
FROM product_revenue
WHERE revenue >
(
    SELECT AVG(revenue)
    FROM product_revenue
);

-- 3. Customer Revenue
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS revenue
    FROM orders
    GROUP BY customer_id
)
SELECT *
FROM customer_sales
ORDER BY revenue DESC;

-- 4. Monthly Revenue
WITH monthly_sales AS
(
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sales) AS revenue
    FROM orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
)
SELECT *
FROM monthly_sales
ORDER BY
    order_year,
    order_month;

-- CORRELATED SUBQUERY.
-- 1. Products Costing More Than Their Category Average.
SELECT
    p1.product_name,
    p1.category,
    p1.price
FROM products p1
WHERE p1.price >
(
    SELECT AVG(p2.price)
    FROM products p2
    WHERE p1.category = p2.category
);

-- 2. Customers Having More Orders Than Average.
SELECT
    customer_id,
    COUNT(*) AS total_orders
FROM orders o1
GROUP BY customer_id
HAVING COUNT(*) >
(
    SELECT AVG(order_count)
    FROM
    (
        SELECT
            customer_id,
            COUNT(*) AS order_count
        FROM orders
        GROUP BY customer_id
    ) AS customer_orders
);

-- 	VIEWS (Virtual Table) : Created from multiple columns of 2 or more tables. Hides complex joins.
-- 1. Sales Summary View.
CREATE VIEW vw_sales_summary AS
SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    c.city,
    c.state,
    c.segment,
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.brand,
    p.price,
    p.cost,
    o.quantity,
    o.discount,
    o.sales
FROM orders o
JOIN customers c
ON o.customer_id=c.customer_id
JOIN products p
ON o.product_id=p.product_id;

-- 2. Customer Revenue View.
CREATE VIEW vw_customer_revenue AS
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) customer_name,
    c.city,
    c.state,
    SUM(o.sales) total_revenue,
    SUM(o.quantity) total_quantity,
    COUNT(o.order_id) total_orders
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    c.state;

-- 3. Product Performance View.
CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
p.product_id,
p.product_name,
p.category,
p.brand,
SUM(o.quantity) AS total_quantity,
SUM(o.sales) AS total_sales,
SUM(
o.sales - (p.cost * o.quantity)
) AS total_profit
FROM products p
JOIN orders o
ON p.product_id = o.product_id
GROUP BY
p.product_id,
p.product_name,
p.category,
p.brand;

    
    
-- TEMPORARY TABLE. 
-- 1. Top Customers.
CREATE TEMPORARY TABLE temp_top_customers
SELECT
	customer_id,
	SUM(sales) total_revenue
FROM orders
GROUP BY customer_id;
    
-- 2. Top Products.
CREATE TEMPORARY TABLE temp_top_products
SELECT
    product_id,
    SUM(sales) total_sales
FROM orders
GROUP BY product_id;


-- STORED PROCEDURES.
-- 1. Monthly Revenue Report.
DELIMITER $$
CREATE PROCEDURE GetMonthlyRevenue()
BEGIN
SELECT
    YEAR(order_date) Year,
    MONTHNAME(order_date) Month,
    SUM(sales) Revenue
FROM orders
GROUP BY
YEAR(order_date),
MONTH(order_date),
MONTHNAME(order_date)
ORDER BY
YEAR(order_date),
MONTH(order_date);
END$$
DELIMITER ;
CALL GetMonthlyRevenue();

-- 2. Customer Revenue Report.
DELIMITER $$
CREATE PROCEDURE GetCustomerRevenue()
BEGIN
SELECT
customer_id,
SUM(sales) revenue
FROM orders
GROUP BY customer_id
ORDER BY revenue DESC;
END$$
DELIMITER ;
CALL GetCustomerRevenue();


-- INDEXES.
-- Index on customer_id.
CREATE INDEX idx_customer
ON orders(customer_id);

-- Index on product_id.
CREATE INDEX idx_product
ON orders(product_id);

-- Shows Index.
SHOW INDEX
FROM orders;

-- Drop Index.
DROP INDEX idx_customer
ON orders;


-- EXPLAIN is a diagnostic tool for developers and DBAs to see how SQL queries are executed and optimize them for better performance.
EXPLAIN
SELECT *
FROM orders
WHERE customer_id='C00123';


-- BUSINESS QUESTIONS.
-- 1. Top 10 Customers.
SELECT
customer_id,
SUM(sales) revenue
FROM orders
GROUP BY customer_id
ORDER BY revenue DESC
LIMIT 10;

-- 2. Bottom 10 Customers.
SELECT
customer_id,
SUM(sales) revenue
FROM orders
GROUP BY customer_id
ORDER BY revenue
LIMIT 10;

-- 3. Highest Revenue State.
SELECT
c.state,
SUM(o.sales) revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY c.state
ORDER BY revenue DESC;

-- 4. Highest revenue City.
SELECT
c.city,
SUM(o.sales) revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY c.city
ORDER BY revenue DESC;

-- 5. Highest Revenue Product.
SELECT
p.product_name,
SUM(o.sales) revenue
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 1;

-- 6. Highest Selling Category.
SELECT
p.category,
SUM(o.sales) revenue
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- 7. Highest Selling Brand.
SELECT
p.brand,
SUM(o.sales) revenue
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.brand
ORDER BY revenue DESC;

-- 8. Average Selling Price by Category.
SELECT
category,
AVG(price) average_price
FROM products
GROUP BY category;

-- 9. Most Ordered Product.
SELECT
p.product_name,
SUM(o.quantity) total_quantity
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.product_name
ORDER BY total_quantity DESC;

-- 10. Total Profit by category.
SELECT
p.category,
SUM(o.sales - (p.cost * o.quantity)) AS total_profit
FROM products p
JOIN orders o
ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY total_profit DESC;

-- 11. Revenue by Segment.
SELECT
c.segment,
SUM(o.sales) revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY c.segment;

-- 12. Revenue by Brand.
SELECT
p.brand,
SUM(o.sales) revenue
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.brand;

-- 13. Monthly Revenue Trend.
SELECT
YEAR(order_date) year,
MONTHNAME(order_date) month,
SUM(sales) revenue
FROM orders
GROUP BY
YEAR(order_date),
MONTH(order_date),
MONTHNAME(order_date)
ORDER BY
YEAR(order_date),
MONTH(order_date);

-- 14. Average Discount by Category.
SELECT
p.category,
AVG(o.discount) average_discount
FROM products p
JOIN orders o
ON p.product_id=o.product_id
GROUP BY p.category;

-- 15. Products Never Sold.
SELECT
p.product_name
FROM products p
WHERE NOT EXISTS
(
SELECT 1
FROM orders o
WHERE o.product_id = p.product_id
);
