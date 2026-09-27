WITH order_items AS (

    SELECT *
    FROM {{ ref("stg_olist__order_items") }}


),
translations AS (

    SELECT *
    FROM {{ref("stg_olist__product_category_name_translation")}}

),
sellers AS (

    SELECT *
    FROM {{ref("stg_olist__sellers")}}

),
products AS (

    SELECT 
        product_id,
        product_category_name
    FROM
        {{ref("stg_olist__products")}}

),
merged AS (

    SELECT
        oi.order_id,
        oi.order_item_id,
        oi.product_id,
        oi.seller_id,
        oi.shipping_limit_timestamp,
        oi.order_item_price,
        oi.order_item_freight_value,
        p.product_category_name,
        t.product_category_name_english,
        s.seller_zip_code_prefix
    FROM order_items oi
    LEFT JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN translations t
        ON p.product_category_name = t.product_category_name
    LEFT JOIN sellers s
        ON oi.seller_id = s.seller_id
)


SELECT *
FROM merged