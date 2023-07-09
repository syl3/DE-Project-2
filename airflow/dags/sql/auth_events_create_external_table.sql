CREATE EXTERNAL TABLE spectrum.{{params.event}} (
    ts TIMESTAMP,
    "sessionId" INTEGER,
    level VARCHAR,
    "itemInSession" INTEGER,
    city VARCHAR,
    zip INTEGER,
    state VARCHAR,
    "userAgent" VARCHAR,
    lon DOUBLE PRECISION,
    lat DOUBLE PRECISION,
    "userId" INTEGER,
    "lastName" VARCHAR,
    "firstName" VARCHAR,
    gender VARCHAR,
    registration BIGINT,
    success BOOLEAN,
    year INTEGER
) STORED AS PARQUET LOCATION 's3://{{params.s3_bucket_name}}/{{ params.event }}';