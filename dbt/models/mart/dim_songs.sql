{{ config (materialized = 'table') }} 
WITH songs AS (
    SELECT 
        artist_id,
        song_id,
        REPLACE(REPLACE(artist_name, '"', ''), '\\', '') AS artist_name,
        duration,
        key,
        key_confidence,
        loudness,
        song_hotttnesss,
        tempo,
        title,
        year
    FROM {{ ref ('stg_songs') }}
    UNION ALL
    (
        SELECT 
            'NNNNNNNNNNNNNNNNNNN',
            'NNNNNNNNNNNNNNNNNNN',
            'NA',
            0,
            -1,
            -1,
            -1,
            -1,
            -1,
            'NA',
            0
    )
),
final AS (
    SELECT {{ dbt_utils.surrogate_key (['song_id','artist_id']) }} AS song_key,
        *
    FROM songs
)
SELECT *
FROM final