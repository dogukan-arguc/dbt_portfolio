WITH products AS (

    SELECT *
    FROM {{ ref('stg_olist__products') }}

),
translations AS (

    SELECT *
    FROM {{ ref('stg_olist__product_category_name_translation') }}

),
products_english_categories AS (

    SELECT
    	p.product_id,
        coalesce(t.product_category_name_english, 'unknown') as product_category_name,
        p.product_name_length,
        p.product_description_length,
        p.product_photos_qty,
        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm
    FROM
        products p
    LEFT JOIN translations t
        ON p.product_category_name = t.product_category_name

)

SELECT *
FROM products_english_categories