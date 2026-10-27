select
    count(*) as row_count,
    count(distinct order_id) as distinct_order_count

from {{ ref('fct_olist__orders') }}

having count(*) != count(distinct order_id)