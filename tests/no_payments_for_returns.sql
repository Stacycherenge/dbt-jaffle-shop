SELECT
    order_id,
    status,
    amount
FROM {{ ref('orders') }}
WHERE status = 'returned' AND amount > 0
