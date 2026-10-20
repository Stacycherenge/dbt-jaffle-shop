-- This test will FAIL if the total calculated revenue does not match the raw seed files.
WITH mart_revenue AS (
    SELECT SUM(amount) AS total_amount FROM {{ ref('orders') }}
),

seed_revenue AS (
    SELECT SUM(amount) / 100.0 AS total_amount FROM {{ ref('raw_payments') }}
)

SELECT 
    mart_revenue.total_amount AS final_mart,
    seed_revenue.total_amount AS raw_seed
FROM mart_revenue
CROSS JOIN seed_revenue
-- The rule: These values MUST be identical. 
-- We filter for where they are NOT equal to find errors.
WHERE mart_revenue.total_amount != seed_revenue.total_amount

WITH check_negative_ltv AS (
    SELECT 
        'Negative LTV Found' AS error_type,
        customer_id AS record_id
    FROM {{ ref('customers') }}
    WHERE lifetime_value < 0
),

check_timeline_anomaly AS (
    SELECT 
        'Timeline Anomaly: First Order After Last Order' AS error_type,
        customer_id AS record_id
    FROM {{ ref('customers') }}
    WHERE first_order_date > most_recent_order_date
),

check_returned_order_payments AS (
    SELECT 
        'Returned Order Has Active Payment' AS error_type,
        order_id AS record_id
    FROM {{ ref('orders') }}
    WHERE status = 'returned' AND payment_amount > 0
)

SELECT * FROM check_negative_ltv
UNION ALL
SELECT * FROM check_timeline_anomaly
UNION ALL
SELECT * FROM check_returned_order_payments
