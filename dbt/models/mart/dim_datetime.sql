{{ config(materialized = 'table') }}

WITH date_series AS (
    SELECT
        *
    FROM
        generate_series('2020-10-01'::timestamp, '2025-01-01'::timestamp, '1 hour') AS date
)
SELECT
    extract(epoch FROM date) AS date_key,
    date,
    extract(dow FROM date) AS day_of_week,
    extract(day FROM date) AS day_of_month,
    extract(week FROM date) AS week_of_year,
    extract(month FROM date) AS month,
    extract(year FROM date) AS year,
    CASE WHEN extract(dow FROM date) IN (6, 7) THEN
        TRUE
    ELSE
        FALSE
    END AS weekend_flag
FROM
    date_series

