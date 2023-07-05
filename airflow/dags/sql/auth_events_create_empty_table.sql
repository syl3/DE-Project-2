CREATE TABLE IF NOT EXISTS dev.auth_events (
    -- Define your table columns here
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
)
PARTITION BY RANGE (DATE_TRUNC('hour', ts));