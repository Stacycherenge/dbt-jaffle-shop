SELECT 
    c.customer_id,
    c.number_of_orders AS compiled_count,
    COUNT(o.order_id) AS raw_count
FROM {{ ref('customers') }} c
JOIN {{ ref('orders') }} o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.number_of_orders
-- Fail if the pre-computed count doesn't match reality
HAVING c.number_of_orders != COUNT(o.order_id)
