{{ config(materialized='table') }}

with dates as (

    select cast(d as date) as date_day
    from generate_series(
        cast('{{ var("dim_date_start") }}' as date),
        cast('{{ var("dim_date_end") }}' as date),
        interval 1 day
    ) as t(d)

),
date_table as (

    select
        year(date_day) * 10000 + month(date_day) * 100 + day(date_day) as date_key,
        date_day,
        year(date_day)                                  as year,
        quarter(date_day)                               as quarter,
        month(date_day)                                 as month,
        monthname(date_day)                             as month_name,
        day(date_day)                                   as day_of_month,
        dayofyear(date_day)                             as day_of_year,
        isodow(date_day)                                as day_of_week,   -- 1=Monday
        dayname(date_day)                               as day_name,
        isoyear(date_day)                               as iso_year,
        weekofyear(date_day)                            as iso_week,
        cast(date_trunc('week', date_day) as date)      as week_start,
        cast(date_trunc('month', date_day) as date)     as month_start,
        last_day(date_day)                              as month_end,
        cast(date_trunc('quarter', date_day) as date)   as quarter_start,
        cast(date_trunc('year', date_day) as date)      as year_start,
        strftime(date_day, '%Y-%m')                     as year_month,
        isodow(date_day) in (6, 7)                      as is_weekend,
        date_day = last_day(date_day)                   as is_month_end
    from dates
)

select * from date_table