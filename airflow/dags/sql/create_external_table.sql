CREATE EXTERNAL TABLE spectrum.songs (
    artist_id VARCHAR(100),
    artist_latitude DOUBLE PRECISION,
    artist_location VARCHAR(100),
    artist_longitude DOUBLE PRECISION,
    artist_name VARCHAR(100),
    danceability DOUBLE PRECISION,
    duration DOUBLE PRECISION,
    energy DOUBLE PRECISION,
    key BIGINT,
    key_confidence DOUBLE PRECISION,
    loudness DOUBLE PRECISION,
    mode BIGINT,
    mode_confidence DOUBLE PRECISION,
    release VARCHAR(100),
    song_hotttnesss DOUBLE PRECISION,
    song_id VARCHAR(100),
    tempo DOUBLE PRECISION,
    title VARCHAR(100),
    track_id VARCHAR(100),
    year BIGINT
) STORED AS PARQUET LOCATION '{{ params.s3_path }}';