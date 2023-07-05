CREATE EXTERNAL TABLE spectrum.{{params.event}}_{{ logical_date.strftime("%m%d%H") }} (
    ts TIMESTAMP,
    level VARCHAR,
    city VARCHAR,
    state VARCHAR,
    "userAgent" VARCHAR,
    lon DOUBLE PRECISION,
    lat DOUBLE PRECISION,
    "userId" INTEGER,
    "lastName" VARCHAR,
    "firstName" VARCHAR,
    gender VARCHAR,
    registration INTEGER,
    success BOOLEAN
) STORED AS PARQUET LOCATION 's3://{{params.s3_bucket_name}}/{{ params.event }}/month={{ logical_date.strftime("%-m") }}/day={{ logical_date.strftime("%-d") }}/hour={{ logical_date.strftime("%-H") }}';