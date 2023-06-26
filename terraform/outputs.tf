output "kafka_ip" {
  value = aws_instance.kafka.public_ip
}

output "bucket_name" {
  description = "S3 bucket name."
  value       = aws_s3_bucket.proj-data-lake.id
}