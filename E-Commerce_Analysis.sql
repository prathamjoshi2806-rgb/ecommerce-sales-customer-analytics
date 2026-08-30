-- ============================================================
-- E-COMMERCE SALES ANALYSIS
-- SQL DATA ANALYST PROJECT
-- ============================================================


-- ============================================================
-- SECTION 1: DATA VALIDATION
-- QUERIES 1-5
-- ============================================================


-- Query 1: Check NULL Values

SELECT
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(product_id IS NULL) AS null_product_id,
    SUM(order_date IS NULL) AS null_order_date,
    SUM(order_status IS NULL) AS null_order_status,
    SUM(quantity IS NULL) AS null_quantity,
    SUM(sales_amount IS NULL) AS null_sales_amount
FROM orders;


-- Query 2: Check Duplicate Order IDs

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- Query 3: Check Invalid Quantities

SELECT *
FROM orders
WHERE quantity <= 0;


-- Query 4: Check Invalid Sales Amounts

SELECT *
FROM orders
WHERE sales_amount <= 0;


-- Query 5: Order Status Distribution

SELECT
    order_status,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;



-- ============================================================
-- SECTION 2: BASIC BUSINESS ANALYSIS
-- QUERIES 6-10
-- ============================================================


-- Query 6: Total Revenue

SELECT
    SUM(sales_amount) AS total_revenue
FROM orders;


-- Query 7: Average Order Value

SELECT
    AVG(sales_amount) AS average_order_value
FROM orders;


-- Query 8: Minimum and Maximum Order Value

SELECT
    MIN(sales_amount) AS min_order_value,
    MAX(sales_amount) AS max_order_value
FROM orders;


-- Query 9: Revenue by Order Status

SELECT
    order_status,
    SUM(sales_amount) AS total_revenue
FROM orders
GROUP BY order_status
ORDER BY total_revenue DESC;


-- Query 10: Number of Orders by Status

SELECT
    order_status,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;



-- ============================================================
-- SECTION 3: CUSTOMER ANALYSIS
-- QUERIES 11-16
-- ============================================================


-- Query 11: Revenue by City

SELECT
    c.city,
    SUM(o.sales_amount) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY total_revenue DESC;


-- Query 12: Top 10 Customers by Revenue

SELECT
    c.customer_id,
    c.customer_name,
    SUM(o.sales_amount) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC
LIMIT 10;


-- Query 13: Top 10 Customers by Number of Orders

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_orders DESC
LIMIT 10;


-- Query 14: Repeat Customers

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;


-- Query 15: One-Time Customers

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) = 1
ORDER BY c.customer_id;


-- Query 16: Customers With No Orders

SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) = 0;



-- ============================================================
-- SECTION 4: PRODUCT & CATEGORY ANALYSIS
-- QUERIES 17-22
-- ============================================================


-- Query 17: Revenue by Category

SELECT
    p.category,
    SUM(o.sales_amount) AS total_revenue
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- Query 18: Orders by Category

SELECT
    p.category,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_orders DESC;


-- Query 19: Units Sold by Product

SELECT
    p.product_id,
    p.product_name,
    SUM(o.quantity) AS total_units_sold
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_units_sold DESC
LIMIT 10;


-- Query 20: Top 10 Products by Revenue

SELECT
    p.product_id,
    p.product_name,
    SUM(o.sales_amount) AS total_revenue
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 10;


-- Query 21: Product Revenue and Units Sold

SELECT
    p.product_id,
    p.product_name,
    SUM(o.sales_amount) AS total_revenue,
    SUM(o.quantity) AS total_units_sold
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;


-- Query 22: Revenue and Units Sold by Category

SELECT
    p.category,
    SUM(o.sales_amount) AS total_revenue,
    SUM(o.quantity) AS total_units_sold
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;



-- ============================================================
-- SECTION 5: SUBQUERIES & CTEs
-- QUERIES 23-27
-- ============================================================


-- Query 23: Orders Above Average Order Value

SELECT *
FROM orders
WHERE sales_amount > (
    SELECT AVG(sales_amount)
    FROM orders
);


-- Query 24: Products Above Their Category Average Price
-- Correlated Subquery

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.selling_price
FROM products p
WHERE p.selling_price > (
    SELECT AVG(p2.selling_price)
    FROM products p2
    WHERE p2.category = p.category
);


-- Query 25: Customers Above 50,000 Revenue
-- CTE

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.sales_amount) AS total_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT *
FROM customer_revenue
WHERE total_revenue > 50000
ORDER BY total_revenue DESC;


-- Query 26: Top 5 Customers by Revenue
-- CTE

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COUNT(o.order_id) AS total_orders,
        SUM(o.sales_amount) AS total_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT *
FROM customer_revenue
ORDER BY total_revenue DESC
LIMIT 5;


-- Query 27: Highest-Priced Product in Each Category
-- Correlated Subquery

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.selling_price
FROM products p
WHERE p.selling_price = (
    SELECT MAX(p2.selling_price)
    FROM products p2
    WHERE p2.category = p.category
);



-- ============================================================
-- SECTION 6: WINDOW FUNCTIONS
-- QUERIES 28-32
-- ============================================================


-- Query 28: Rank Customers by Revenue

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.sales_amount) AS total_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_revenue,
    DENSE_RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM customer_revenue
ORDER BY revenue_rank;


-- Query 29: Rank Products Within Each Category

WITH product_revenue AS (
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        SUM(o.sales_amount) AS total_revenue
    FROM products p
    JOIN orders o
        ON p.product_id = o.product_id
    GROUP BY
        p.category,
        p.product_id,
        p.product_name
)
SELECT
    category,
    product_id,
    product_name,
    total_revenue,
    DENSE_RANK() OVER (
        PARTITION BY category
        ORDER BY total_revenue DESC
    ) AS category_rank
FROM product_revenue
ORDER BY category, category_rank;


-- Query 30: Top 3 Products in Each Category

WITH product_revenue AS (
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        SUM(o.sales_amount) AS total_revenue
    FROM products p
    JOIN orders o
        ON p.product_id = o.product_id
    GROUP BY
        p.category,
        p.product_id,
        p.product_name
),
ranked_products AS (
    SELECT
        category,
        product_id,
        product_name,
        total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM product_revenue
)
SELECT *
FROM ranked_products
WHERE revenue_rank <= 3
ORDER BY category, revenue_rank;


-- Query 31: Monthly Running Revenue

WITH monthly_revenue AS (
    SELECT
        YEAR(order_date) AS revenue_year,
        MONTH(order_date) AS revenue_month,
        SUM(sales_amount) AS monthly_revenue
    FROM orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
)
SELECT
    revenue_year,
    revenue_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        ORDER BY revenue_year, revenue_month
    ) AS cumulative_revenue
FROM monthly_revenue
ORDER BY revenue_year, revenue_month;


-- Query 32: Previous Month Revenue

WITH monthly_revenue AS (
    SELECT
        YEAR(order_date) AS revenue_year,
        MONTH(order_date) AS revenue_month,
        SUM(sales_amount) AS monthly_revenue
    FROM orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
)
SELECT
    revenue_year,
    revenue_month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (
        ORDER BY revenue_year, revenue_month
    ) AS previous_month_revenue
FROM monthly_revenue
ORDER BY revenue_year, revenue_month;



-- ============================================================
-- SECTION 7: DATE ANALYSIS
-- QUERIES 33-37
-- ============================================================


-- Query 33: Orders by Year

SELECT
    YEAR(order_date) AS order_year,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY YEAR(order_date)
ORDER BY order_year;


-- Query 34: Revenue by Year

SELECT
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_revenue
FROM orders
GROUP BY YEAR(order_date)
ORDER BY order_year;


-- Query 35: Monthly Revenue

SELECT
    YEAR(order_date) AS revenue_year,
    MONTH(order_date) AS revenue_month,
    SUM(sales_amount) AS total_revenue
FROM orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    revenue_year,
    revenue_month;


-- Query 36: Month-over-Month Revenue Change

WITH monthly_revenue AS (
    SELECT
        YEAR(order_date) AS revenue_year,
        MONTH(order_date) AS revenue_month,
        SUM(sales_amount) AS monthly_revenue
    FROM orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
),
revenue_comparison AS (
    SELECT
        revenue_year,
        revenue_month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (
            ORDER BY revenue_year, revenue_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    revenue_year,
    revenue_month,
    monthly_revenue,
    previous_month_revenue,
    monthly_revenue - previous_month_revenue AS revenue_change
FROM revenue_comparison
ORDER BY revenue_year, revenue_month;


-- Query 37: Year-to-Date Revenue

WITH monthly_revenue AS (
    SELECT
        YEAR(order_date) AS revenue_year,
        MONTH(order_date) AS revenue_month,
        SUM(sales_amount) AS monthly_revenue
    FROM orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
)
SELECT
    revenue_year,
    revenue_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        PARTITION BY revenue_year
        ORDER BY revenue_month
    ) AS ytd_revenue
FROM monthly_revenue
ORDER BY revenue_year, revenue_month;



-- ============================================================
-- SECTION 8: FINAL BUSINESS ANALYSIS
-- QUERIES 38-40
-- ============================================================


-- Query 38: Category Revenue Contribution

SELECT
    p.category,
    SUM(o.sales_amount) AS total_revenue,
    ROUND(
        SUM(o.sales_amount) * 100.0 /
        (SELECT SUM(sales_amount) FROM orders),
        2
    ) AS revenue_percentage
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- Query 39: Repeat Customer Revenue

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.sales_amount) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING COUNT(o.order_id) > 1
ORDER BY total_revenue DESC;


-- Query 40: Customer Revenue and Order Performance

WITH customer_analysis AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        c.state,
        COUNT(o.order_id) AS total_orders,
        SUM(o.quantity) AS total_units,
        SUM(o.sales_amount) AS total_revenue,
        AVG(o.sales_amount) AS average_order_value
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.city,
        c.state
)
SELECT
    customer_id,
    customer_name,
    city,
    state,
    total_orders,
    total_units,
    total_revenue,
    average_order_value,
    DENSE_RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM customer_analysis
ORDER BY revenue_rank;