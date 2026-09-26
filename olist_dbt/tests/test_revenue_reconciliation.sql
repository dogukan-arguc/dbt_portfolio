
{{
    config(
        severity='error',
        warn_if='>10',
        error_if='>100',
        store_failures=true
    )

}}

WITH order_total_price as (

    SELECT 

        order_id, 
        SUM(order_item_price) as sum_item_price,
        SUM(order_item_freight_value) as sum_freight_val,
        SUM(order_item_price)+SUM(order_item_freight_value) as total

    FROM {{ref('stg_olist__order_items')}}

    GROUP BY order_id
),
order_payments as (
    
    SELECT
    
        order_id,
        SUM(payment_value) as total_payment
    
    FROM 
        {{ref('stg_olist__order_payments')}}
    
    GROUP BY order_id

),
wrong_payments as (
    
    SELECT
        op.order_id,
        op.total_payment,
        oi.total
    FROM order_payments op
    JOIN order_total_price oi
        ON oi.order_id = op.order_id
    WHERE op.total_payment != oi.total
)

SELECT *
FROM wrong_payments
