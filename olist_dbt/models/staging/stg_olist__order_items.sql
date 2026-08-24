WITH source AS (
    SELECT *
    FROM {{source("olist","order_items")}}
),
renamed AS (

    SELECT
        CAST(order_id AS VARCHAR) as order_id,
        CAST(order_item_id AS SMALLINT) as order_item_id,
        CAST(product_id AS VARCHAR) as product_id,
        CAST(seller_id AS VARCHAR) as seller_id,
        CAST(shipping_limit_date AS TIMESTAMP) as shipping_limit_timestamp,
        CAST(price AS DOUBLE) as order_item_price,
        CAST(freight_value AS DOUBLE) as order_item_freight_value
    FROM
        source

)

select * from renamed