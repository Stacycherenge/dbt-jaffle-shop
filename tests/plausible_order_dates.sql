SELECT
    order_id,
    order_date
FROM {{ ref('orders') }}
-- Fail if an order date is ahead of the current calendar day or before the year 2010
WHERE order_date > CURRENT_DATE OR order_date < '2010-01-01'
