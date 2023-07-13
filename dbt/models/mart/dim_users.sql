{{ config (materialized = 'table') }} 
-- level column in the users dimension is considered to be a SCD2 change. Just for the purpose of learning to write SCD2 change queries.
-- The below query is constructed to accommodate changing levels from free to paid and maintaining the latest state of the user along with
-- historical record of the user's level
WITH listen_events AS (
    -- Select distinct state of user in each timestamp
    SELECT DISTINCT
        user_id,
        first_name,
        last_name,
        gender,
        registration,
        level,
        ts AS date
    FROM
        {{ ref ('stg_listen_events') }}
    WHERE
        user_id <> 0
),
listen_events__where_level_change AS (
    -- Lag the level and see where the user changes level from free to paid or otherwise
    SELECT
        *,
        CASE WHEN LAG(level, 1) OVER (PARTITION BY user_id,
            first_name,
            last_name,
            gender ORDER BY date) <> level 
        THEN
            1
        ELSE
            0
        END AS lagged
    FROM
        listen_events
)
,
listen_events__group AS (
    -- Create distinct group of each level change to identify the change in level accurately
    SELECT
        *,
        SUM(lagged) OVER (PARTITION BY user_id,
            first_name,
            last_name,
            gender ORDER BY date
            rows between unbounded preceding and current row) AS grouped
    FROM
        listen_events__where_level_change
)
,
listen_events__find_min_date_within_group AS (
    -- Find the earliest date available for each free/paid status change
    SELECT
        user_id,
        first_name,
        last_name,
        gender,
        registration,
        level,
        grouped,
        cast(min(date) AS date) AS mindate
    FROM
        listen_events__group
    GROUP BY
        user_id,
        first_name,
        last_name,
        gender,
        registration,
        level,
        grouped
)
,
listen_events__assign_flag__activation_date__expiration_date AS (
    SELECT
        CAST(user_id AS bigint) AS user_id,
        first_name,
        last_name,
        gender,
        level,
        CAST(registration AS bigint) AS registration,
        mindate AS row_activation_date,
        -- Choose the start date from the next record and add that as the expiration date for the current record
        CASE WHEN LEAD(minDate, 1) OVER (PARTITION BY user_id,
            first_name,
            last_name,
            gender ORDER BY grouped) IS NULL THEN '9999-12-31'
            WHEN LEAD(minDate, 1) OVER (PARTITION BY user_id,
            first_name,
            last_name,
            gender ORDER BY grouped) IS NOT NULL THEN LEAD(minDate, 1) OVER (PARTITION BY user_id,
            first_name,
            last_name,
            gender ORDER BY grouped)
        END AS row_expiration_date,
        -- Assign a flag indicating which is the latest row for easier select queries
        CASE WHEN RANK() OVER (PARTITION BY user_id,
            first_name,
            last_name,
            gender ORDER BY grouped DESC) = 1 THEN
            1
        ELSE
            0
        END AS current_row
    FROM
        listen_events__find_min_date_within_group
),
final AS (
    SELECT
        md5(cast(coalesce(cast(user_id as varchar), '') || '-' || coalesce(cast(row_activation_date as varchar), '') || '-' || coalesce(cast(level as varchar), '') as varchar)) AS user_key,
        *
    FROM
        listen_events__assign_flag__activation_date__expiration_date
)
SELECT
    *
FROM
    final
