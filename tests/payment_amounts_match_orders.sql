WITH staging_totals AS (
    SELECT 
        order_id,
        SUM(amount) AS total_stg_amount
    FROM {{ ref('stg_payments') }}
    GROUP BY order_id
)

SELECT 
    o.order_id,
    o.amount AS mart_amount,
    s.total_stg_amount
FROM {{ ref('orders') }} o
JOIN staging_totals s ON o.order_id = s.order_id
-- Fail if the amount computed in the final table differs from the staging view components
WHERE o.amount != s.total_stg_amount
