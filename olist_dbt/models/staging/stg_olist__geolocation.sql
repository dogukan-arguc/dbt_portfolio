WITH geolocation AS (
    SELECT 
        *
    FROM 
        {{ source("olist","geolocation") }}
),
renamed AS (

    SELECT
        CAST(TRIM(geolocation_zip_code_prefix) AS VARCHAR) as geolocation_zip_code_prefix,
        CAST(geolocation_lat AS DOUBLE) as geolocation_lat,
        CAST(geolocation_lng AS DOUBLE) as geolocation_lng,
        CAST(TRIM(geolocation_city) AS VARCHAR) as geolocation_city,
        CAST(TRIM(geolocation_state) AS VARCHAR) as geolocation_state
    FROM
        geolocation

)

select * from renamed