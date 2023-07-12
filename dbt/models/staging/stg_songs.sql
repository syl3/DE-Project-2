{{ config(materialized='view', bind=False) }}
WITH source AS (
    SELECT
        *
    FROM
        {{ source ('redshift_spectrum', 'songs') }}
),
staged AS (
    SELECT
    artist_id,
    artist_latitude,
    artist_location,
    artist_longitude,
    artist_name,
    danceability,
    duration,
    energy,
    key,
    key_confidence,
    loudness,
    mode,
    mode_confidence,
    release,
    song_hotttnesss,
    song_id,
    tempo,
    title,
    track_id,
    year
    FROM
        source
)
SELECT
    *
FROM
    staged
