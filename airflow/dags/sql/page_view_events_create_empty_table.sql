CREATE TABLE IF NOT EXISTS dev.page_view_events (
    -- Define your table columns here
    ts TIMESTAMP,
    page VARCHAR,
    auth VARCHAR,
    method VARCHAR,
    status INTEGER,
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
    artist VARCHAR,
    song VARCHAR,
    duration DOUBLE PRECISION
)
PARTITION BY RANGE (DATE_TRUNC('hour', ts));