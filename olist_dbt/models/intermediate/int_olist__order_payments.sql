WITH order_payments AS (
    SELECT
        order_id,
        payment_type,
        payment_installments,
        payment_value
    FROM {{ ref('stg_olist__order_payments') }}
)


SELECT
    order_id,
    SUM(payment_value) AS total_payment,
    COUNT(payment_type) AS payment_count,
    SUM(CASE WHEN payment_type = 'credit_card' THEN payment_value ELSE 0 END) AS credit_card_amount,
    SUM(CASE WHEN payment_type = 'voucher' THEN payment_value ELSE 0 END) AS voucher_amount,
    SUM(CASE WHEN payment_type = 'debit_card' THEN payment_value ELSE 0 END) AS debit_card_amount
FROM order_payments
GROUP BY order_id