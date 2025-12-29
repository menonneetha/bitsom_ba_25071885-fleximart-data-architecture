-- Query 1: Customer Purchase History
-- Business Question:

Business Question: "Generate a detailed report showing each customer's name, email, total number of orders placed, and total amount spent. Include only customers who have placed at least 2 orders and spent more than ₹5,000. Order by total amount spent in descending order."

Requirements:

Must join: customers, orders, order_items tables
Use GROUP BY with HAVING clause
Calculate aggregates: COUNT of orders, SUM of amounts
Expected Output Columns:

customer_name | email | total_orders | total_spent

-- Expected to return customers with 2+ orders and >5000 spent
customer_name | email                   | total_orders | total_spent
Rahul Sharma    rahul.sharma@gmail.com    5              919980.00
Priya Patel     priya.patel@yahoo.com     4              415976.00




SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.total_amount), 2) AS total_spent
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
HAVING COUNT(DISTINCT o.order_id) >= 2 
   AND SUM(o.total_amount) > 5000
ORDER BY total_spent DESC;

----------------------------------------------------------------------------------------------------------------------------------------
-- Query 2: Product Sales Analysis
-- Business Question:

Query 2: Product Sales Analysis (5 marks)

Business Question: "For each product category, show the category name, number of different products sold, total quantity sold, and total revenue generated. Only include categories that have generated more than ₹10,000 in revenue. Order by total revenue descending."

Requirements:

Must join: products, order_items tables
Use GROUP BY with HAVING clause
Calculate: COUNT(DISTINCT), SUM aggregates
Expected Output Columns:

category | num_products | total_quantity_sold | total_revenue



-- Expected to return categories with >10000 revenue

category     | num_products | total_quantity_sold | total_revenue
Electronics    9              25                    550775.00
Fashion        7              22                    63878.00
Groceries      4              42                    18601.00


SELECT 
    p.category,
    COUNT(DISTINCT p.product_id) AS num_products,
    SUM(oi.quantity) AS total_quantity_sold,
    ROUND(SUM(oi.subtotal), 2) AS total_revenue
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
HAVING SUM(oi.subtotal) > 10000
ORDER BY total_revenue DESC;

----------------------------------------------------------------------------------------------------------------------------------------

-- Query 3: Monthly Sales Trend
-- Business Question: 

Business Question: "Show monthly sales trends for the year 2024. For each month, display the month name, total number of orders, total revenue, and the running total of revenue (cumulative revenue from January to that month)."

Requirements:

Use window function (SUM() OVER) for running total OR use subquery
Extract month from order_date
Group by month
Order chronologically
Expected Output Columns:

month_name | total_orders | monthly_revenue | cumulative_revenue


-- Expected to show monthly and cumulative revenue
month_name | total_orders | monthly_revenue | cumulative_revenue
January      17             262433.00         262433.00
February     2              0.00              262433.00
March        9              106994.00         369427.00




WITH monthly_sales AS (
    SELECT 
        YEAR(o.order_date) AS year_num,
        MONTH(o.order_date) AS month_num,
        MONTHNAME(o.order_date) AS month_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.total_amount) AS monthly_revenue
    FROM orders o
    WHERE YEAR(o.order_date) = 2024
    GROUP BY YEAR(o.order_date), MONTH(o.order_date), MONTHNAME(o.order_date)
)
SELECT 
    month_name,
    total_orders,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER (ORDER BY year_num, month_num ROWS UNBOUNDED PRECEDING), 2) AS cumulative_revenue
FROM monthly_sales
ORDER BY year_num, month_num;

