with orders as (

    select * from {{ ref('stg_olist__orders') }}

),

customers as (
    
    select * from {{ ref('stg_olist__customers') }}

),
order_payments as (

    select * from {{ ref('int_olist__order_payments') }}

),
customer_orders as (
    select
        c.customer_unique_id,
        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state,
        o.order_id,
        o.order_purchase_timestamp,
        op.total_payment
    from customers c
    inner join orders o
        on o.customer_id = c.customer_id
    left join order_payments op
        on op.order_id = o.order_id
),
latest_attributes as (
    select
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state
    from customer_orders
    qualify row_number() over (
        partition by customer_unique_id
        order by order_purchase_timestamp desc
    ) = 1
),
aggregates as (
    select
        customer_unique_id,
        min(order_purchase_timestamp)      as first_order_timestamp,
        max(order_purchase_timestamp)      as last_order_timestamp,
        count(distinct order_id)           as lifetime_orders,
        coalesce(sum(total_payment), 0)    as lifetime_value
    from customer_orders
    group by 1
)

select
    a.customer_unique_id,
    l.customer_zip_code_prefix,
    l.customer_city,
    l.customer_state,
    a.first_order_timestamp,
    a.last_order_timestamp,
    a.lifetime_orders,
    a.lifetime_value
from aggregates a
inner join latest_attributes l
    on l.customer_unique_id = a.customer_unique_id