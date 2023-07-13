{{ config(materialized='view', bind=False) }}

WITH source AS (
    SELECT
        *
    FROM
        {{ source ('redshift_spectrum', 'datetime') }}
)
SELECT
    *
FROM
    source
