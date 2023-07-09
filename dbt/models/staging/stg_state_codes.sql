WITH source AS (
    SELECT
        *
    FROM
        {{ ref ('state_codes') }}
),
staged AS (
    SELECT
        "stateCode" AS state_code,
        "stateName" AS state_name
    FROM
        source
)
SELECT
    *
FROM
    staged
