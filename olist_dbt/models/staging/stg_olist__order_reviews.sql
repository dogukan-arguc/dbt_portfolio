SELECT
    review_id,
    order_id,
    review_score,
    TRIM(UPPER(review_comment_title)) as review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM
    {{ source("olist","order_reviews") }}