-- Step 1: Find each customer's first order date
WITH first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
),

-- Step 2: Check if customer made another purchase within 30 days
repeat_orders AS (
    SELECT
        f.customer_id,
        f.first_order_date,
        MIN(o.order_date) AS repeat_order_date
    FROM first_orders f
    JOIN orders o
        ON f.customer_id = o.customer_id
        AND o.order_date > f.first_order_date
        AND o.order_date <= f.first_order_date + INTERVAL '30 day'
    GROUP BY f.customer_id, f.first_order_date
)

-- Step 3: Calculate retention rate
SELECT
    COUNT(DISTINCT f.customer_id) AS total_customers,
    COUNT(DISTINCT r.customer_id) AS retained_customers,
    ROUND(
        COUNT(DISTINCT r.customer_id)::numeric
        / COUNT(DISTINCT f.customer_id),
        3
    ) AS retention_rate_30d
FROM first_orders f
LEFT JOIN repeat_orders r
    ON f.customer_id = r.customer_id;
