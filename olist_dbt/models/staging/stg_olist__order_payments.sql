SELECT
    CAST(order_id AS VARCHAR) as order_id,
    CAST(payment_sequential AS SMALLINT) as payment_sequential,
    CAST(TRIM(payment_type) AS VARCHAR) as payment_type,
    CAST(payment_installments AS SMALLINT) as payment_installments,
    CAST(payment_value AS DOUBLE) as payment_value
FROM
    {{ source("olist","order_payments") }}