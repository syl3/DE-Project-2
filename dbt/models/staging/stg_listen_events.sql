WITH source AS (
    SELECT
        *
    FROM
        {{ source ('dbt_example', 'listen_events') }}
),
staged AS (
    SELECT
        -- IDs
        artist,
        song,
        duration,
        ts,
        sessionid,
        auth,
        level,
        "itemInSession" AS item_in_session,
        city,
        zip,
        state,
        "userAgent" AS user_agent,
        lon,
        lat,
        "userId" AS user_id,
        "lastName" AS last_name,
        "firstName" AS first_name,
        gender,
        registration,
        year
    FROM
        source
)
SELECT
    *
FROM
    staged
