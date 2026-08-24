SELECT
    CAST(order_id AS VARCHAR(100)) as order_id,
    CAST(customer_id AS VARCHAR(100)) as customer_id,
    CAST(TRIM(order_status) AS VARCHAR(50)) as order_status,
    CAST(order_purchase_timestamp AS TIMESTAMP) as order_purchase_timestamp,
    CAST(order_approved_at AS TIMESTAMP) as order_approved_at_timestamp,
    CAST(order_delivered_carrier_date AS TIMESTAMP) as order_delivered_carrier_timestamp,
    CAST(order_delivered_customer_date AS TIMESTAMP) as order_delivered_customer_timestamp,
    CAST(order_estimated_delivery_date AS DATE) as order_estimated_delivery_date
from {{ source('olist', 'orders') }}