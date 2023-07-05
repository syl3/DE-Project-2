CREATE TABLE IF NOT EXISTS dev.listen_events (
    -- Define your table columns here
    artist VARCHAR,
    song VARCHAR,
    duration DOUBLE PRECISION,
    ts TIMESTAMP,
    auth VARCHAR,
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
    registration INTEGER
)
PARTITION BY RANGE (DATE_TRUNC('hour', ts));