{{ config(materialized = 'table') }} 
WITH songs AS (
    SELECT MAX(artist_id) AS artist_id,
        MAX(artist_latitude) AS latitude,
        MAX(artist_longitude) AS longitude,
        MAX(artist_location) AS location,
        REPLACE(REPLACE(artist_name, '"', ''), '\\', '') AS name
    FROM {{ ref('songs') }}
    GROUP BY artist_name
    UNION ALL
    SELECT 'NNNNNNNNNNNNNNN',
        0,
        0,
        'NA',
        'NA'
),
final AS (
    SELECT {{ dbt_utils.surrogate_key(['artist_id']) }} AS artist_key,
        *
    FROM songs
)
select *
from final