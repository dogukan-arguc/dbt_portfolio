WITH source AS (

    SELECT *
    FROM {{ source("olist","product_category_name_translation") }}

),
renamed AS (

    SELECT
        CAST(product_category_name AS VARCHAR) as product_category_name,
        CAST(product_category_name_english AS VARCHAR) as product_category_name_english
    FROM
        source    

)

select * from source