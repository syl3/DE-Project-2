CREATE EXTERNAL TABLE spectrum.{{params.event}} (
    artist VARCHAR,
    song VARCHAR,
    duration DOUBLE PRECISION,
    ts TIMESTAMP,
    sessionid INTEGER,
    auth VARCHAR,
    level VARCHAR,
    "itemInSession" INTEGER,
    city VARCHAR,
    zip INTEGER,
    state VARCHAR,
    "userAgent" VARCHAR,
    lon DOUBLE PRECISION,
    lat DOUBLE PRECISION,
    "userId" BIGINT,
    "lastName" VARCHAR,
    "firstName" VARCHAR,
    gender VARCHAR,
    registration BIGINT,
    year INTEGER
)
PARTITIONED BY (ts_partition CHAR(10)) 
STORED AS PARQUET LOCATION 's3://{{params.s3_bucket_name}}/{{ params.event }}';