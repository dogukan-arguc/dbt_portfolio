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

    -- do on yourself
),
allocated AS (





)

SELECT *
FROM order_items