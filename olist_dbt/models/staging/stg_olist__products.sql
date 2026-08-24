WITH source AS (
    SELECT *
    FROM {{ source("olist","products")}}
),
renamed AS (

    SELECT
        CAST(product_id AS VARCHAR) as product_id,
        CAST(TRIM(product_category_name) AS VARCHAR) as product_category_name,
        CAST(product_name_lenght AS SMALLINT) as product_name_length,
        CAST(product_description_lenght AS INT) as product_description_length,
        CAST(product_photos_qty AS SMALLINT) as product_photos_qty,
        CAST(product_weight_g AS INT) as product_weight_g,
        CAST(product_length_cm AS SMALLINT) as product_length_cm,
        CAST(product_height_cm AS SMALLINT) as product_height_cm,
        CAST(product_width_cm AS SMALLINT) as product_width_cm
    FROM
        source

)

select * from renamed