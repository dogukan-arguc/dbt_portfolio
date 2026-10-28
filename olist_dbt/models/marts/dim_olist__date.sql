with date_table as (
    select *
    from {{ ref('stg_olist__date') }}
),
orders as (
    select * 
    from {{ ref('stg_olist__orders') }}
)