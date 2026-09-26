{% test is_positive(model, column_name) %}

with validation as (
    select
        {{ column_name }} as value,
        case when value > 0 then 1 else 0 end as is_positive
    from
        {{ model }}
),
validation_errors as (
    select *
    from validation
    where is_positive = 0
)

select *
from validation_errors

{% endtest %}