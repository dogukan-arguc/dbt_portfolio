WITH order_items AS (

    SELECT 
        oi.seller_id,
        oi.order_id,
        MIN(o.order_approved_at_timestamp) as first_order_approved_at_timestamp,
        SUM(oi.order_item_price) as total_order_item_price
    FROM {{ref("int_olist__order_items_category_seller")}}  as oi
    JOIN {{ref("stg_olist__orders")}} as o
        ON o.order_id = oi.order_id
    GROUP BY oi.seller_id, oi.order_id

),
first_last_shipping AS (
    SELECT
        seller_id,
        COUNT(DISTINCT order_id) as order_count,
        MIN(first_order_approved_at_timestamp) as first_order_approved_at_timestamp,
        MAX(first_order_approved_at_timestamp) as last_order_approved_at_timestamp,
        SUM(total_order_item_price) as total_order_item_price
    FROM order_items
    GROUP BY seller_id
),
stg_sellers AS (
    SELECT
        *
    FROM {{ref("stg_olist__sellers")}}
)

SELECT
    s.seller_id,
    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state,
    fls.order_count,
    fls.first_order_approved_at_timestamp,
    fls.last_order_approved_at_timestamp,
    fls.total_order_item_price
FROM stg_sellers as s
LEFT JOIN first_last_shipping as fls
    ON s.seller_id = fls.seller_id