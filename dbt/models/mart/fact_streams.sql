{{ config(materialized = 'table') }}

WITH listen_events AS (
    SELECT *
    FROM {{ ref('stg_listen_events') }}
),
SELECT
    dim_users.user_key,
    dim_artists.artist_key,
    dim_songs.song_key,
    dim_datetime.date_key,
    dim_location.location_key,
    listen_events.ts
 FROM listen_events
  LEFT JOIN {{ ref('dim_users') }}
    ON listen_events.user_id = dim_users.user_id AND CAST(listen_events.ts AS DATE) >= dim_users.row_activation_date AND CAST(listen_events.ts AS DATE) < dim_users.row_expiration_date
  LEFT JOIN {{ ref('dim_artists') }}
    ON REPLACE(REPLACE(listen_events.artist, '"', ''), '\\', '') = dim_artists.name
  LEFT JOIN {{ ref('dim_songs') }}
    ON REPLACE(REPLACE(listen_events.artist, '"', ''), '\\', '') = dim_songs.artist_name AND listen_events.song = dim_songs.title
  LEFT JOIN {{ ref('dim_location') }}
    ON listen_events.city = dim_location.city AND listen_events.state = dim_location.state_code AND listen_events.lat = dim_location.latitude AND listen_events.lon = dim_location.longitude
  LEFT JOIN {{ ref('dim_datetime') }}
    ON dim_datetime.date = to_char(listen_events.ts, 'YYYY-MM-DD HH24:00:00.000')::timestamp