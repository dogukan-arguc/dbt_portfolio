WITH source AS (
    SELECT *
    FROM {{ source("olist","order_reviews") }}

),
renamed AS (
    SELECT
        CAST(review_id AS VARCHAR) as review_id,
        CAST(order_id AS VARCHAR) as order_id,
        CAST(review_score AS SMALLINT) as review_score,
        CAST(TRIM(review_comment_title) AS TEXT) as review_comment_title,
        CAST(review_comment_message AS TEXT) as review_comment_message,
        CAST(review_creation_date AS DATE) as review_creation_date,
        CAST(review_answer_timestamp AS TIMESTAMP) as review_answer_timestamp
    FROM
        source
)

select * from renamed