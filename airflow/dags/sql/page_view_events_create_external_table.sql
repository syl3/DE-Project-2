CREATE EXTERNAL TABLE spectrum.{{params.event}} (
    ts TIMESTAMP,
    sessionId INTEGER,
    page VARCHAR,
    auth VARCHAR,
    method VARCHAR,
    status INTEGER,
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
    artist VARCHAR,
    song VARCHAR,
    duration DOUBLE PRECISION,
    year INTEGER
)
PARTITIONED BY (ts_partition CHAR(10)) 
STORED AS PARQUET LOCATION 's3://{{params.s3_bucket_name}}/{{ params.event }}';