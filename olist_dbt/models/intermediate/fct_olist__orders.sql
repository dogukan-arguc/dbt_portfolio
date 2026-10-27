WITH order_items_category_seller AS (
    SELECT 
        order_id,
        COUNT(*) AS item_count,
        SUM(order_item_price) AS total_item_price,
        SUM(order_item_freight_value) AS total_freight,
    FROM {{ ref('int_olist__order_items_category_seller')}}
    GROUP BY order_id
),
order_payments AS (
    SELECT 
        order_id,
        SUM(total_payment)
    FROM {{ ref('int_olist__order_payments') }}
    GROUP BY order_id
),
orders AS (
    SELECT 
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at_timestamp,
        order_approved_at_timestamp - order_purchase_timestamp AS order_approval_lag,
        order_delivered_carrier_timestamp,
        order_delivered_customer_timestamp,
        order_delivered_customer_timestamp - order_purchase_timestamp AS order_delivery_days,
        order_estimated_delivery_date,
        CASE
            WHEN order_estimated_delivery_date > order_delivered_customer_timestamp THEN 'early'
            WHEN order_estimated_delivery_date = order_delivered_customer_timestamp THEN 'on time'
            WHEN order_estimated_delivery_date < order_delivered_customer_timestamp THEN 'late'
            ELSE 'unknown'
        END AS delivery_early_late_ontime
        
    FROM {{ ref('stg_olist__orders')}}
),
order_reviews AS (
    SELECT
        order_id,
        MAX(review_score) as review_score
    FROM {{ ref('stg_olist__order_reviews') }}
    GROUP BY order_id

),
final AS (
    SELECT *
    FROM orders o
    JOIN order_items_category_seller oi
        ON oi.order_id = o.order_id
    JOIN order_payments op
        ON op.order_id = o.order_id
    JOIN order_reviews orr
        ON orr.order_id = o.order_id
)

SELECT *
FROM final
