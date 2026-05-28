-- Superstore Sales Analysis — SQL Queries
-- Author: Dhilna Kurisingal Mathew

-- Q1: Total Sales by Category
SELECT category, 
       ROUND(SUM(sales)::numeric, 2) as total_sales
FROM sales
GROUP BY category
ORDER BY total_sales DESC;

-- Q2: Top 5 Customers by Revenue
SELECT customer_name, 
       ROUND(SUM(sales)::numeric, 2) as total_spent
FROM sales
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 5;

-- Q3: Monthly Sales Ranking (Window Function)
SELECT month_name,
       ROUND(SUM(sales)::numeric, 2) as total_sales,
       RANK() OVER (ORDER BY SUM(sales) DESC) as sales_rank
FROM sales
GROUP BY month_name
ORDER BY sales_rank;

-- Q4: Running Total of Sales by Month (Window Function)
SELECT month_name,
       month,
       ROUND(SUM(sales)::numeric, 2) as total_sales,
       ROUND(SUM(SUM(sales)) OVER (ORDER BY month)::numeric, 2) as running_total
FROM sales
GROUP BY month_name, month
ORDER BY month;

-- Q5: Best Performing Sub-Category per Region (CTE)
WITH regional_sales AS (
    SELECT region,
           sub_category,
           ROUND(SUM(sales)::numeric, 2) as total_sales
    FROM sales
    GROUP BY region, sub_category
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) as rnk
    FROM regional_sales
)
SELECT region, sub_category, total_sales
FROM ranked
WHERE rnk = 1
ORDER BY total_sales DESC;

-- Q6: Customer Purchase Frequency vs Revenue (CTE + CASE WHEN)
WITH customer_stats AS (
    SELECT customer_name,
           COUNT(DISTINCT order_id) as total_orders,
           ROUND(SUM(sales)::numeric, 2) as total_revenue
    FROM sales
    GROUP BY customer_name
),
categorised AS (
    SELECT *,
           CASE 
               WHEN total_orders >= 10 THEN 'High Frequency'
               WHEN total_orders >= 5  THEN 'Mid Frequency'
               ELSE 'Low Frequency'
           END as frequency_category
    FROM customer_stats
)
SELECT frequency_category,
       COUNT(*) as customer_count,
       ROUND(AVG(total_revenue)::numeric, 2) as avg_revenue
FROM categorised
GROUP BY frequency_category
ORDER BY avg_revenue DESC;