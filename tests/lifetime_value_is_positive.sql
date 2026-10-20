SELECT
    customer_id,
    customer_lifetime_value
FROM {{ ref('customers') }}
WHERE customer_lifetime_value < 0
