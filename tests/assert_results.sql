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
