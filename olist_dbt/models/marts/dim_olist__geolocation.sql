
WITH
geolocation AS (
    SELECT * FROM {{ ref('stg_olist__geolocation') }}
),
coordinates AS (
    SELECT
        geolocation_zip_code_prefix,
        MEDIAN(geolocation_lat) as geolocation_lat,
        MEDIAN(geolocation_lng) as geolocation_lng,
    FROM geolocation
    GROUP BY geolocation_zip_code_prefix
),
city_counts AS (
    SELECT
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state,
        COUNT(*) as city_count
    FROM geolocation
    GROUP BY geolocation_zip_code_prefix, geolocation_city, geolocation_state    
),
canonical_city AS (
    SELECT
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state,
    FROM
        city_counts
    qualify ROW_NUMBER() OVER (PARTITION BY geolocation_zip_code_prefix ORDER BY city_count DESC) = 1
)

SELECT
    coordinates.geolocation_zip_code_prefix,
    coordinates.geolocation_lat,
    coordinates.geolocation_lng,
    canonical_city.geolocation_city,
    canonical_city.geolocation_state
FROM coordinates
LEFT JOIN canonical_city
    ON coordinates.geolocation_zip_code_prefix = canonical_city.geolocation_zip_code_prefix

