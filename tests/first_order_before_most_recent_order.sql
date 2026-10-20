SELECT
    customer_id,
    first_order,
    most_recent_order
FROM {{ ref('customers') }}
WHERE first_order > most_recent_order
