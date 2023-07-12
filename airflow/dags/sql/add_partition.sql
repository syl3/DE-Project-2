ALTER TABLE spectrum.{{ params.event }} ADD
PARTITION (ts_partition={{ logical_date.strftime("%Y%m%d%H") }}) LOCATION 's3://{{params.s3_bucket_name}}/{{ params.event }}/month={{ logical_date.strftime("%-m") }}/day={{ logical_date.strftime("%-d") }}/hour={{ logical_date.strftime("%-H") }}';