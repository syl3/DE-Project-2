CREATE EXTERNAL TABLE spectrum.datetime (
    date_key BIGINT,
    date TIMESTAMP,
    day_of_week BIGINT,
    day_of_month BIGINT,
    week_of_year BIGINT,
    month BIGINT,
    year BIGINT,
    weekend_flag BIGINT
) STORED AS PARQUET LOCATION '{{ params.s3_path }}';