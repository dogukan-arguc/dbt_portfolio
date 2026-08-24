SELECT
    CAST(seller_id AS VARCHAR) as seller_id,
    CAST(seller_zip_code_prefix AS VARCHAR) as seller_zip_code_prefix,
    CAST(TRIM(seller_city) AS VARCHAR) as seller_city,
    CAST(TRIM(seller_state) AS VARCHAR) as seller_state
FROM
    {{ source("olist","sellers") }}