WITH order_items AS (

    SELECT 
        {{ dbt_utils.generate_surrogate_key([
            'order_id',
            'order_item_id'
        ]) }} AS order_item_key,
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_timestamp,
        order_item_price,
        order_item_freight_value,
        order_item_price + order_item_freight_value AS line_total

    
    FROM {{ ref('stg_olist__order_items') }}

),
order_payments AS (
    SELECT
        order_id,
        total_payment
    FROM {{ ref('int_olist__order_payments') }}
),
weighted AS (
    SELECT
        oi.*,
        op.total_payment,
        SUM(oi.line_total) OVER (PARTITION BY oi.order_id) AS order_line_total,
        ROW_NUMBER() OVER ( PARTITION BY oi.order_id ORDER BY oi.order_item_id DESC) AS rn_desc
    FROM order_items oi
    LEFT JOIN order_payments op ON oi.order_id = op.order_id 
),
allocated AS (
    




)

SELECT *
FROM order_items