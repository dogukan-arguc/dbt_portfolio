SELECT
    CAST(customer_id AS VARCHAR) as customer_id,
    CAST(customer_unique_id AS VARCHAR) as customer_unique_id,
    CAST(TRIM(customer_zip_code_prefix) AS VARCHAR) as customer_zip_code_prefix,
    CAST(TRIM(customer_city) AS VARCHAR) as customer_city,
    CAST(TRIM(customer_state) AS VARCHAR) as customer_state
FROM
    {{ source("olist","customers") }}