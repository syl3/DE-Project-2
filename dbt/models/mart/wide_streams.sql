{{ config(
    materialized = 'view'
) }}
SELECT 
fact_streams.user_key,
    fact_streams.artist_key,
    fact_streams.song_key,
    fact_streams.date_key,
    fact_streams.location_key,
    fact_streams.ts AS timestamp,
    dim_users.first_name,
    dim_users.last_name ,
    dim_users.gender,
    dim_users.level,
    dim_users.user_id,
    dim_users.current_row as current_user_row,
    dim_songs.duration AS song_duration,
    dim_songs.tempo,
    dim_songs.title AS song_name,
    dim_location.city,
    dim_location.state_name AS state,
    dim_location.latitude,
    dim_location.longitude,
    dim_datetime.date AS date_hour,
    dim_datetime.day_of_month,
    dim_datetime.day_of_week,
    dim_artists.latitude AS artist_latitude,
    dim_artists.longitude AS artist_longitude,
    dim_artists.name AS artist_name
FROM {{ ref('fact_streams') }}
    JOIN {{ ref('dim_users') }} ON fact_streams.user_key = dim_users.user_key
    JOIN {{ ref('dim_songs') }} ON fact_streams.song_key = dim_songs.song_key
    JOIN {{ ref('dim_location') }} ON fact_streams.location_key = dim_location.location_key
    JOIN {{ source ('redshift_spectrum', 'datetime') }} ON fact_streams.date_key = dim_datetime.date_key
    JOIN {{ ref('dim_artists') }} ON fact_streams.artist_key = dim_artists.artist_key