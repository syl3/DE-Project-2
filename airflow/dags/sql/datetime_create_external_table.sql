CREATE EXTERNAL TABLE spectrum.datetime (
    date_key BIGINT,
    date TIMESTAMP,
    day_of_week INTEGER,
    day_of_month INTEGER,
    week_of_year INTEGER,
    month INTEGER,
    year INTEGER,
    weekend_flag BOOLEAN
) STORED AS PARQUET LOCATION '{{ params.s3_path }}';