SELECT
    CAST(review_id AS VARCHAR(100)) as review_id,
    CAST(order_id AS VARCHAR(100)) as order_id,
    CAST(review_score AS SMALLINT) as review_score,
    CAST(TRIM(review_comment_title) AS TEXT) as review_comment_title,
    CAST(review_comment_message AS TEXT) as review_comment_message,
    CAST(review_creation_date AS DATE) as review_creation_date,
    CAST(review_answer_timestamp AS TIMESTAMP) as review_answer_timestamp
FROM
    {{ source("olist","order_reviews") }}