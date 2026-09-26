{% test assert_no_future_dates(model, column_name) %}

with validation as (
    select
        {{ column_name }} as date_col,
    
    from 
        {{ model}}



),
validation_errors as (

    select
        date_col,
        case when date_col > current_date then 1 else 0 end as is_future_date
    from validation

)

select *
from validation_errors
where is_future_date = 1

{% endtest %}