{{ config (MATERIALIZED = 'table') }} 
WITH listen_events AS (
    SELECT *
    FROM {{ ref ('stg_listen_events') }}
),
state_codes AS (
    SELECT *
    FROM {{ ref('stg_state_codes') }}
),
_merge AS (
    SELECT distinct city,
        COALESCE(state_codes.state_code, 'NA') as state_code,
        COALESCE(state_codes.state_name, 'NA') as state_name,
        lat as latitude,
        lon as longitude
    FROM listen_events
        LEFT JOIN state_codes ON listen_events.state = state_codes.state_code
    UNION ALL
    SELECT 'NA',
        'NA',
        'NA',
        0.0,
        0.0
),
final AS (
    SELECT {{ dbt_utils.surrogate_key (['latitude', 'longitude', 'city', 'state_name']) }} AS location_key,
        *
    FROM _merge
)
SELECT *
FROM final