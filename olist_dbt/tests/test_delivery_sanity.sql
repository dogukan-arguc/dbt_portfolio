WITH back_to_the_future AS (
    SELECT
        order_id,
        order_purchase_timestamp,
        order_delivered_customer_timestamp,
    FROM
        {{ref('stg_olist__orders')}}
    WHERE order_purchase_timestamp > order_delivered_customer_timestamp
)

SELECT *
FROM back_to_the_future