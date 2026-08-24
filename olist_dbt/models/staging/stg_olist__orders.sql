WITH source AS (
    SELECT *
    FROM {{ source('olist', 'orders') }}

),
renamed AS (

    SELECT
        CAST(order_id AS VARCHAR) as order_id,
        CAST(customer_id AS VARCHAR) as customer_id,
        CAST(TRIM(order_status) AS VARCHAR) as order_status,
        CAST(order_purchase_timestamp AS TIMESTAMP) as order_purchase_timestamp,
        CAST(order_approved_at AS TIMESTAMP) as order_approved_at_timestamp,
        CAST(order_delivered_carrier_date AS TIMESTAMP) as order_delivered_carrier_timestamp,
        CAST(order_delivered_customer_date AS TIMESTAMP) as order_delivered_customer_timestamp,
        CAST(order_estimated_delivery_date AS DATE) as order_estimated_delivery_date
    FROM 
        source
)

select * from renamed