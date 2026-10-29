with date_table as (
    select date_key, date_day
    from {{ ref('stg_olist__date') }}
),
orders as (
    select order_id, order_purchase_timestamp
    from {{ ref('fct_olist__orders') }}
),
final as (

    select
        dt.date_day,
        dt.date_key,
        o.order_id,
        o.order_purchase_timestamp
    from date_table dt
    left join orders o on CAST(o.order_purchase_timestamp AS DATE) = dt.date_day
)

select * from final